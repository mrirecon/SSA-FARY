#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig5 of the following manuscript:
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

#--- Extract images ---
bart resize -c 0 192 1 192 SMS3 _SMS3
endexp=5
bart slice 11 $endexp _SMS3 _SMS3_endexp

for b in 15 18 22; do # Diastole

	bart slice 10 $b _SMS3_endexp{,1}
	cfl2png -F X -u 0.60 _SMS3_endexp1 _SMS3_endexp_b$b
done

for b in 7 9; do # Systole

	bart slice 10 $b _SMS3_endexp{,1}
	cfl2png -F X -u 0.60 _SMS3_endexp1 _SMS3_endexp_b$b
done

# Real-time
bart slice 0 326 rec_rt _rec_rt
bart slice 13 1 _rec_rt _rec_rt1
bart transpose 1 10 _rec_rt1 _rec_rt2
bart extract 10 377 477 _rec_rt2 _rec_rt3
cfl2png -u 0.62 _rec_rt3 _SMS3_RT



#--- Process images ---
b1=22
b2=7
b3=9
b4=15
b5=18

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0000.png _SMS3_endexp_b${b2}_u_0000.png _SMS3_endexp_b${b3}_u_0000.png _SMS3_endexp_b${b4}_u_0000.png _SMS3_endexp_b${b5}_u_0000.png \
__SMS3_endexp_0.png
python3 ../utils/figcreator.py -t "LCv:Slice 1" __SMS3_endexp_0.png _a0.png

python3 ../utils/figcreator.py --stroke 308:178:308:338:4:8 _SMS3_endexp_b${b1}_u_0001.png _SMS3_endexp_b${b1}_u_0001-stroke.png

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0001-stroke.png _SMS3_endexp_b${b2}_u_0001.png _SMS3_endexp_b${b3}_u_0001.png _SMS3_endexp_b${b4}_u_0001.png _SMS3_endexp_b${b5}_u_0001.png \
__SMS3_endexp_1.png
python3 ../utils/figcreator.py -t "LCv:Slice 2" __SMS3_endexp_1.png _a1.png

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0002.png _SMS3_endexp_b${b2}_u_0002.png _SMS3_endexp_b${b3}_u_0002.png _SMS3_endexp_b${b4}_u_0002.png _SMS3_endexp_b${b5}_u_0002.png \
__SMS3_endexp_2.png

python3 ../utils/figcreator.py -t "LCv:Slice 3" __SMS3_endexp_2.png __a2.png
python3 ../utils/figcreator.py -t "BLh:Cardiac Cycle →" __a2.png _a2.png


python3 ../utils/figcreator.py --tile 3x1 _a0.png _a1.png _a2.png _a.png


# Respiration curve
python3 plot.py _SMS3_RT.png EOF_345 resp/resp3_full.resp _resp
convert -trim _resp.png _b3.png
python3 ../utils/figcreator.py --resize "x:1950:iso" _b3.png __b.png
python3 ../utils/figcreator.py --textpad 0.2 -t "LCh:Y" __b.png __b3.png
python3 ../utils/figcreator.py -t "BLh:Time →" __b3.png _b.png


# Join
python3 ../utils/figcreator.py -t "LTh:a)" _a.png __a.png
python3 ../utils/figcreator.py -t "LTh:b)" _b.png __b.png
python3 ../utils/figcreator.py --tile 2x1 __a.png __b.png Fig5_SMS.png

rm _*.png
rm _*.{cfl,hdr}

