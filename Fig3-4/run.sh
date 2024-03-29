#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig3-4 of the following manuscript:
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
SP=5
PAR=1
FR=3800
FRred=7895

source ../ssa_fary_utils/data_loc.sh
DATA="${DATA_LOC}"/SS/Fig3-4

#--- k-space ---
bart reshape $(bart bitmask 0 1 2 10) 1 $RO 1 $(($SP * $FR)) ${DATA}/ksp _k1
bart resize 10 $FRred _k1 k


#--- Traj ---
aopts="-G -s7 -D"
topts="-x$RO -y1 -t$FRred -m$PAR $aopts -c -R-22"
bart traj $topts t

#--- RING ---
bart resize 10 50 t _tGD
bart transpose 10 2 _tGD _tGD1

bart resize 10 50 k _kGD
bart transpose 10 2 _kGD _kGD1
GD=$(DEBUG_LEVEL=0 bart estdelay -R _tGD1 _kGD1); echo $GD

bart traj $topts -O -q$GD tGD

bart resize -c 1 1 k KDC
bart rmfreq t KDC Kc
#OUTPUT KDC, Kc

rm _*.{cfl,hdr}

#--- SSA-FARY ---
# Prepare auto-calibration region
bart squeeze Kc _kc1
bart transpose 0 1 _kc1 _ac1
bart creal _ac1 _acreal
bart scale -- -1i _ac1 _ac2
bart creal _ac2 _acimag
bart join 1 _acreal _acimag ac

for w in 751; do

	bart ssa -w$w ac EOF_$w S_$w
done
#OUTPUT EOF_751, S_751

r0=0
r1=1
c0=2
c1=3
bart slice 1 $r0 EOF_$w _eof_r0
bart slice 1 $r1 EOF_$w _eof_r1
bart slice 1 $c0 EOF_$w _eof_c0
bart slice 1 $c1 EOF_$w _eof_c1

bart join 1 _eof_r{0,1} _eof_c{0,1} _tmp
bart transpose 1 11 _tmp _tmp1
bart transpose 0 10 _tmp1 eof


#--- Binning ---
R=9
C=25
bart bin -r0:1 -R$R -c2:3 -C$C -a3500 eof k ksg
bart bin -r0:1 -R$R -c2:3 -C$C -a3500 eof tGD tsg

#--- Sensitivity calculation (ENLIVE) ---
bart cc -p13 -A ksg ksg_cc
rm ksg.{cfl,hdr}

ro=200
os=2
for ((i=0; i<$R; i+=1)); do

	echo "Respiration-state: " $i "/" $R

	bart slice 11 $i ksg_cc _ksg
	bart slice 11 $i tsg _tsg
	bart resize -c 1 $ro _ksg _ksg1
	bart resize -c 1 $ro _tsg _tsg1

	dim=$(($ro * $os))

	bart scale $os _tsg1 _tsg1os
	bart resize 10 7 _tsg1os _tsg1os_crop
	bart resize 10 7 _ksg1 _ksg1_crop
	bart rtnlinv -x${dim}:${dim}:1 -m2 -A $GPU -d5 -t _tsg1os_crop _ksg1_crop _srec_r$i _ssens_r$i
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

bart join 11 $(seq -f "_ssens_r%1g" 0 $((R-1))) sens

rm _*.{cfl,hdr}
rm srec_rs*.{cfl,hdr} ssens_rs*.{cfl,hdr}

#--- PICS reconstruction ---
bart pattern ksg_cc pat

for W in 0.00002; do
for Tr in 0.0009; do
for Tc in 0.0015; do

	echo "W=" $W " Tr=" $Tr "Tc=" $Tc

	bart pics -i60 -d5 -m -p pat \
		-R W:$(bart bitmask 0 1):0:$W \
		-R T:$(bart bitmask 11):0:$Tr \
		-R T:$(bart bitmask 10):0:$Tc \
		-t tsg ksg_cc sens _pics_W${W}_Tr${Tr}_Tc${Tc}

	bart fmac _pics_W${W}_Tr${Tr}_Tc${Tc} sens _pics
	bart slice 4 0 _pics _pics0
	bart slice 4 1 _pics _pics1
	bart saxpy 1 _pics0 _pics1 _sum
	bart rss $(bart bitmask 3) _sum SS_W${W}_Tr${Tr}_Tc${Tc}

	rm _*.{cfl,hdr}

done; done; done;

bart resize -c 0 192 1 192 SS_W${W}_Tr${Tr}_Tc${Tc} _pics1
bart transpose 0 1 _pics1 SS
#OUTPUT: SS

#--- PCA ---
# SSA with w=1
bart ssa -w1 ac PCA S_PCA
#OUTPUT: PCA, S_PCA

#--- Clean up ---
rm _*.{cfl,hdr}
rm ac.{cfl,hdr} pat.{cfl,hdr} eof.{cfl,hdr} sens.{cfl,hdr}
rm SS_W*.{cfl,hdr} t*.{cfl,hdr} k*.{cfl,hdr} rec1*.{cfl,hdr}

