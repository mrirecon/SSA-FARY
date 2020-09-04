#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SupFig4 of the following manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020

set -e

#--- BART ---
export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then

        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi

#--- Config ---
RO=384
SP=5
PAR=1
FR=3800
FRred=19000
# same "full" k-space as for Fig4
DATA=../data/SS/Fig3-4/

#--- kspace ---
bart reshape $(bart bitmask 0 1 2 10) 1 $RO 1 $(($SP * $FR)) $DATA/ksp _k1
bart resize 10 $FRred _k1 k

#--- Trajectory ---
aopts="-G -s7 -D"
topts="-x$RO -y1 -t$FRred -m$PAR $aopts -c -R-22"
bart traj $topts t

#--- RING ---
bart resize 10 50 t _tGD
bart transpose 10 2 _tGD _tGD1

bart resize 10 50 k _kGD
bart transpose 10 2 _kGD _kGD1
GD=$(bart estdelay -R _tGD1 _kGD1); echo $GD

bart traj $topts -O -q$GD tGD

bart resize -c 1 1 k _kDC
bart rmfreq t _kDC kc

rm _*.{cfl,hdr}

#--- SSA-FARY ---
# Prepare auto-calibration region
bart squeeze kc _kc1
bart transpose 0 1 _kc1 _ac1
bart creal _ac1 _acreal
bart scale -- -1i _ac1 _ac2
bart creal _ac2 _acimag
bart join 1 _acreal _acimag ac

for w in 751; do

	bart ssa -w$w ac EOF_$w S_$w
done

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
R=3
C=25
bart bin -r0:1 -R$R -c2:3 -C$C -a3500 eof k ksg
bart bin -r0:1 -R$R -c2:3 -C$C -a3500 eof tGD tsg

#--- Gridding ---
bart rss 1 tsg ramlak
bart fmac ramlak ksg ksg_filt
bart nufft -a tsg ksg_filt nufft
bart rss 8 nufft rss


#--- PCA ---
# SSA with w=1
bart ssa -w1 ac PCA S_PCA

rm _*.{cfl,hdr}
rm eof.{cfl,hdr} k*.{cfl,hdr} ram*.{cfl,hdr} t*.{cfl,hdr} nufft*.{cfl,hdr}
