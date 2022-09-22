#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Mov6 of the following manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.5.00"

bart resize -c 0 192 1 192 SMS3 _a

# Cardiac motion
for Rstate in 5 2; do

	bart slice 11 $Rstate _a _b
	cfl2png -F X -u0.51 _b SMS_R${Rstate}
done

for Rstate in 5 2; do
	for i in {0000..0024}; do

		python3 ../ssa_fary_utils/figcreator.py --tile 1x3 SMS_R${Rstate}_frame_${i}_u_0002.png SMS_R${Rstate}_frame_${i}_u_0001.png SMS_R${Rstate}_frame_${i}_u_0000.png SMS_R${Rstate}_${i}.png
	done
done

for i in {0000..0024}; do

	python3 ../ssa_fary_utils/figcreator.py --tile 2x1 SMS_R5_${i}.png SMS_R2_${i}.png SMS_${i}.png
done

ffmpeg -r 25 -f image2 -i SMS_%4d.png -b 3500k -vcodec wmv2 -pix_fmt yuv420p Mov6_SMS_card.wmv

rm _*.{cfl,hdr}
rm SMS_*.png

