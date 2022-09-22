#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig8 of the following manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020

set -e

#--- BART ---
if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.5.00"

#--- Config ---
GPU=-g
#GPU=""
RO=384
SP=3
PAR=14
FR=2300
FRred=5922

source ../ssa_fary_utils/data_loc.sh
DATA="${DATA_LOC}"/SoS/Vol6_SupFig8


#--- kspace ---
bart transpose 2 13 $DATA/ksp _k0
bart reshape $(bart bitmask 0 1 2 10) 1 $RO 1 $(($SP * $FR)) _k0 _k1
bart resize 10 $FRred _k1 k

#--- Traj ---
# topts="-x$RO -y$SP -t$FR -G -s7 -D -m$PAR -c -R-18"
# bart traj $topts _ta
# bart reshape $(bart bitmask 2 10) 1 $(($SP * $FR)) _ta _tb
# bart resize 10 $FRred _tb _t

# #--- RING ---
# bart slice 13 7 _t _t1
# bart resize 10 50 _t1 _tGD
# bart transpose 10 2 _tGD _tGD1

# bart slice 13 7 k _ks
# bart resize 10 50 _ks _kGD
# bart transpose 10 2 _kGD _kGD1
# GD=$(DEBUG_LEVEL=0 bart estdelay -R _tGD1 _kGD1); echo $GD

# bart traj $topts -O -q$GD _tGDa
# bart reshape $(bart bitmask 2 10) 1 $(($SP * $FR)) _tGDa _tGDb
# bart resize 10 $FRred _tGDb tGD


#--- Remove frequency ---
bart resize -c 1 1 k _kDC
bart resize -c 13 6 _kDC _kDCz
bart resize -c 13 6 $DATA/traj _tz
bart rmfreq _tz _kDCz kc

rm _*.{cfl,hdr}


#--- SSA-FARY ---
# Prepare auto-calibration region
bart transpose 2 13 kc _kc1
bart reshape $(bart bitmask 2 3) 1 180 _kc1 _kc2
bart transpose 3 13 _kc2 _ac
bart squeeze _ac _ac1
bart creal _ac1 _acreal
bart scale -- -1i _ac1 _ac2
bart creal _ac2 _acimag
bart join 1 _acreal _acimag ac

for w in 51 91; do

	bart ssa -w$w ac  EOF_$w S_$w
done

w=51
r0=1
r1=2
bart slice 1 $r0 EOF_$w _eof_r0
bart slice 1 $r1 EOF_$w _eof_r1

w=91
c0=7
c1=8
bart slice 1 $c0 EOF_$w _eof_c0
bart slice 1 $c1 EOF_$w _eof_c1

bart join 1 _eof_r{0,1} _eof_c{0,1} _tmp
bart transpose 1 11 _tmp _tmp1
bart transpose 0 10 _tmp1 eof

#--- Binning ---
R=9
C=25
bart bin -r0:1 -R$R -c2:3 -C$C -a600 eof $DATA/traj_cor tsg
bart bin -r0:1 -R$R -c2:3 -C$C -x card -a600 eof k ksg

#--- Sensitivity calculation (ENLIVE) ---
ro=200
os=2
bart reshape $(bart bitmask 2 10 11 13) $(($C * $R * $PAR * $(bart show -d2 ksg))) 1 1 1 ksg _ksg1
bart cc -p10 -A _ksg1 _ksg_cc
bart reshape $(bart bitmask 2 10 11 13) $(bart show -d2 ksg) $C $R $PAR _ksg_cc _ksg_cc2
bart fftmod $(bart bitmask 13) _ksg_cc2 ksg_sh

rm ksg.{cfl,hdr} _ksg*.{cfl,hdr}


for ((i=0; i<$R; i+=1)); do

	echo "Respiration-state: " $i "/" $R

	bart slice 11 $i ksg_sh _ksg
	bart slice 11 $i tsg _tsg
	bart resize -c 1 $ro _ksg _ksg1
	bart resize -c 1 $ro _tsg _tsg1

	dim=$(($ro * $os))

	bart scale $os _tsg1 _tsg1os
	bart resize 10 7 _tsg1os _tsg1os_crop
	bart resize 10 7 _ksg1 _ksg1_crop
	bart rtnlinv -s -A -x${dim}:${dim}:1 -m1 $GPU -d5 -t _tsg1os_crop _ksg1_crop _srec_r$i _ssens_r$i
	bart resize -c 0 $ro 1 $ro _srec_r$i srec_rs_r$i
	bart resize -c 0 $ro 1 $ro _ssens_r$i _ssens1_rs_r$i
	bart fft -u $(bart bitmask 0 1) _ssens1_rs_r$i _ssens1k_rs_r$i
	bart resize -c 0 $RO 1 $RO _ssens1k_rs_r$i _ssens1krs_rs_r$i
	bart fft -u -i $(bart bitmask 0 1) _ssens1krs_rs_r$i ssens_rs_r$i

	rm _ssens*.{cfl,hdr}
	rm _srec_*.{cfl,hdr}
done

bart join 11 $(seq -f "srec_rs_r%1g" 0 $(($R-1))) rec1


for ((i=0; i<$R; i+=1)); do

	bart slice 10 6 ssens_rs_r$i _ssens_r$i
done

bart join 11 $(seq -f "_ssens_r%1g" 0 $((R-1))) _sens
bart fftmod $(bart bitmask 13) _sens sens

rm _*.{cfl,hdr}
rm srec_rs*.{cfl,hdr} ssens_rs*.{cfl,hdr}

#--- PICS reconstruction ---
bart pattern ksg_sh pat

for W in 0.00008; do
for Tr in 0.0009; do
for Tc in 0.005; do
for Ts in 0.0005; do

	echo "W=" $W " Tr=" $Tr
	scaling=0.008737

	bart pics -M -d5 -m -i80  -w $scaling -p pat \
		-R W:$(bart bitmask 0 1):0:$W \
		-R T:$(bart bitmask 11):0:$Tr \
		-R T:$(bart bitmask 10):0:$Tc \
		-R T:$(bart bitmask 13):0:$Ts \
		-t tsg  ksg_sh sens pics_W${W}_Tr${Tr}_Tc${Tc}_Ts${Ts}_sc$scaling

done; done; done; done;

bart resize -c 0 192 1 192 pics_W${W}_Tr${Tr}_Tc${Tc}_Ts${Ts}_sc$scaling pics_rs

#--- Gating ---
python3 ../ssa_fary_utils/gating_analysis.py > Gating.txt


#--- Clean Up ---
rm pics_W${W}_Tr${Tr}_Tc${Tc}_Ts${Ts}_sc$scaling*.{cfl,hdr}
rm k*.{cfl,hdr} rec1*.{cfl,hdr} t*.{cfl,hdr} eof.{cfl,hdr} pat*.{cfl,hdr} sens*.{cfl,hdr} ac*.{cfl,hdr} card*.{cfl,hdr}




