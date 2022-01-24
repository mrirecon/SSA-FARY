#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig7 of the following manuscript:
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

#--- Extract Images ---
bart resize -c 0 192 1 192 SMS3 _SMS3
endexp=8
bart slice 11 $endexp _SMS3 _SMS3_endexp

for b in 3 17 21; do # Diastole

	bart slice 10 $b _SMS3_endexp{,1}
	cfl2png -F X -u 0.4 _SMS3_endexp1 _SMS3_endexp_b$b
done

for b in 11 14; do # Systole

	bart slice 10 $b _SMS3_endexp{,1}
	cfl2png -F X -u 0.4 _SMS3_endexp1 _SMS3_endexp_b$b
done

# Real-time

bart slice 0 323 rec_rt _rec_rt
bart slice 13 0 _rec_rt _rec_rt1
bart transpose 1 10 _rec_rt1 _rec_rt2
bart extract 10 357 457 _rec_rt2 _rec_rt3
cfl2png -u 0.77 _rec_rt3 _SMS3_RT

#--- Process Images ---
b1=3
b2=11
b3=14
b4=17
b5=21

# Images
python3 ../utils/figcreator.py --stroke 314:138:314:338:4:8 _SMS3_endexp_b${b1}_u_0000.png _SMS3_endexp_b${b1}_u_0000-stroke.png

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0000-stroke.png _SMS3_endexp_b${b2}_u_0000.png _SMS3_endexp_b${b3}_u_0000.png _SMS3_endexp_b${b4}_u_0000.png _SMS3_endexp_b${b5}_u_0000.png \
__SMS3_endexp_0.png
python3 ../utils/figcreator.py -t "LCv:Slice 1" __SMS3_endexp_0.png _a0.png

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0001.png _SMS3_endexp_b${b2}_u_0001.png _SMS3_endexp_b${b3}_u_0001.png _SMS3_endexp_b${b4}_u_0001.png _SMS3_endexp_b${b5}_u_0001.png \
__SMS3_endexp_1.png
python3 ../utils/figcreator.py -t "LCv:Slice 2" __SMS3_endexp_1.png _a1.png

python3 ../utils/figcreator.py --tile 1x5 \
_SMS3_endexp_b${b1}_u_0002.png _SMS3_endexp_b${b2}_u_0002.png _SMS3_endexp_b${b3}_u_0002.png _SMS3_endexp_b${b4}_u_0002.png _SMS3_endexp_b${b5}_u_0002.png \
__SMS3_endexp_2.png

python3 ../utils/figcreator.py -t "LCv:Slice 3" __SMS3_endexp_2.png __a2.png
python3 ../utils/figcreator.py -t "BLh:Cardiac Cycle →" __a2.png _a2.png


python3 ../utils/figcreator.py --tile 3x1 _a0.png _a1.png _a2.png _a.png


# Respiration curve
python3 plot.py _SMS3_RT.png EOF_345 resp/resp4_full.resp _resp
python3 ../utils/figcreator.py --arrow 1230:230:50:120:5:8 _resp.png _resp1.png
python3 ../utils/figcreator.py --arrow 1592:239:50:120:5:8 _resp1.png _resp2.png
python3 ../utils/figcreator.py --arrow 2144:225:50:120:5:8 _resp2.png _resp3.png
python3 ../utils/figcreator.py --arrow 203:230:50:120:5:8 _resp3.png _resp4.png

convert -trim _resp4.png _b3.png
python3 ../utils/figcreator.py --resize "x:1950:iso" _b3.png __b.png
python3 ../utils/figcreator.py --textpad 0.2 -t "LCh:Y" __b.png __b3.png
python3 ../utils/figcreator.py -t "BLh:Time →" __b3.png _b.png


# Join
python3 ../utils/figcreator.py -t "LTh:a)" _a.png __a.png
python3 ../utils/figcreator.py -t "LTh:b)" _b.png __b.png
python3 ../utils/figcreator.py --tile 2x1 __a.png __b.png SupFig7_SMS.png

rm _SMS3_e*.png
rm _*.{cfl,hdr,png}


