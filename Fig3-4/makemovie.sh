#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Mov1-2 of the following manuscript:
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


# Cardiac motion
for Rstate in 0 4; do

	bart slice 11 $Rstate SS _b
	cfl2png -F Y -u0.58 _b SS_R${Rstate}
done

for i in {0000..0024}; do

	python3 ../utils/figcreator.py --tile 1x2 SS_R0_frame_${i}.png SS_R4_frame_${i}.png SS_card_${i}.png
done


ffmpeg -r 25 -f image2 -i SS_card_%4d.png -b 1500k -vcodec wmv2 -pix_fmt yuv420p Mov1_SS-bssfp_card.wmv

rm SS_R*.png

# Respiratory motion
for Cstate in 18 7; do

	bart slice 10 $Cstate SS _b
	cfl2png -F Y -u0.505 _b SS_C${Cstate}
done

for j in {0..3}; do
for i in {0000..008}; do

	k=$(($i + ($j * 9)))
	echo $k
	python3 ../utils/figcreator.py --tile 1x2 SS_C18_s_${i}.png SS_C7_s_${i}.png SS_s_${k}.png
done
done

ffmpeg -r 5 -f image2 -i SS_s_%d.png -b 5000k -filter "minterpolate='fps=120'" -vcodec wmv2 -pix_fmt yuv420p Mov2_SS-bssfp_resp.wmv


rm _*.{cfl,hdr}
rm SS_C*.png SS_s_*.png SS_card*.png

