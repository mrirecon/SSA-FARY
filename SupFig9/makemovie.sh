#!/usr/bin/env bash

#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig9 of the following manuscript:
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

bart resize -c 0 192 1 192 pics_rs _a
bart slice 13 5 _a _a0
bart slice 13 6 _a _a1
bart slice 13 7 _a _a2
bart slice 13 8 _a _a3
bart slice 13 9 _a _a4
bart slice 13 10 _a _a5
bart join 13 _a{0,1,2,3,4,5} _b


# Cardiac motion
for Rstate in 3; do

	bart slice 11 $Rstate _b _c
	cfl2png -F X -u0.33 _c SoS_R${Rstate}
done

for Rstate in 3; do
	for i in {0000..0024}; do

		python3 ../ssa_fary_utils/figcreator.py --tile 1x6 SoS_R${Rstate}_frame_${i}_u_000{0,1,2,3,4,5}.png SoS_R${Rstate}_${i}.png
	done
done

ffmpeg -r 25 -f image2 -i SoS_R${Rstate}_%4d.png -b 9000k -vcodec wmv2 -pix_fmt yuv420p Mov14_SoS_V7.wmv

rm SoS_R*.png
rm _*.{cfl,hdr}

