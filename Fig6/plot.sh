#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig6 of the following manuscript:
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
endexp=2
slice=08
enddia=4
endsys=13

bart slice 11 $endexp pics_rs _pics3
bart slice 13 $slice _pics3 _pics4
bart slice 10 $enddia _pics4 _enddia
bart slice 10 $endsys _pics4 _endsys

for i in "_enddia" "_endsys"; do

	cfl2png -F X -u 0.2 -z4 $i{,}
done

#--- Export 2 ---
for slice in 6 8 10; do

	bart slice 13 $slice _pics3 _pics4
	bart slice 10 $enddia _pics4 _enddia_s
	bart slice 10 $endsys _pics4 _endsys_s

	for i in "_enddia_s" "_endsys_s"; do

		if [ $slice -eq 6 ]; then

			cfl2png -F Z -u 0.13 -z4 $i ${i}_slice$slice

		elif [ $slice -eq 8 ]; then

			cfl2png -F Z -u 0.20 -z4 $i ${i}_slice$slice

		elif [ $slice -eq 10 ]; then

			cfl2png -F Z -u 0.28 -z4 $i ${i}_slice$slice
		fi

		mv ${i}_slice${slice}.png ECG

	done
done


#--- Plot ---
python3 plot_data.py
python3 ../utils/figcreator.py -t "LTh:a)" _out.png _a.png

python3 plot_data2.py
python3 ../utils/figcreator.py -t "LTh:b)" _out2.png _b.png


#--- Process Images ---
enddia=4
endsys=13
s0=6
s1=8
s2=10

s0_1based=$(($s0 + 1))
s1_1based=$(($s1 + 1))
s2_1based=$(($s2 + 1))

# SSA-FARY
python3 ../utils/figcreator.py -t "TCh:Slice $s0_1based" ECG/_enddia_s_slice${s0}.png __cTop0.png
python3 ../utils/figcreator.py -t "LCv:end-diastole   " __cTop0.png _cTop0.png
python3 ../utils/figcreator.py -t "TCh:Slice $s1_1based" ECG/_enddia_s_slice${s1}.png _cTop1.png
python3 ../utils/figcreator.py -t "TCh:Slice $s2_1based" ECG/_enddia_s_slice${s2}.png _cTop2.png
python3 ../utils/figcreator.py --tile 1x3 _cTop{0,1,2}.png _cTop.png

python3 ../utils/figcreator.py -t "LCv:end-systole" ECG/_endsys_s_slice${s0}.png _cBottom0.png
python3 ../utils/figcreator.py --tile 1x3 _cBottom0.png ECG/_endsys_s_slice${s1}.png ECG/_endsys_s_slice${s2}.png  _cBottom.png

python3 ../utils/figcreator.py --tile 2x1 _cTop.png _cBottom.png _c1.png
python3 ../utils/figcreator.py --resize "x:1614:iso" _c1.png _c2.png
python3 ../utils/figcreator.py -t "TCh:SSA-FARY" _c2.png _c3.png
python3 ../utils/figcreator.py -t "LTh:c)" _c3.png _c.png

# ECG
python3 ../utils/figcreator.py -t "LCv:end-diastole   " ECG/ECG-dia-cor${s0}.png _dTop0.png
python3 ../utils/figcreator.py --tile 1x3 _dTop0.png ECG/ECG-dia-cor${s1}.png  ECG/ECG-dia-cor${s2}.png _dTop.png

python3 ../utils/figcreator.py -t "LCv:end-systole" ECG/ECG-sys-cor${s0}.png _dBottom0.png
python3 ../utils/figcreator.py --tile 1x3 _dBottom0.png ECG/ECG-sys-cor${s1}.png ECG/ECG-sys-cor${s2}.png  _dBottom.png

python3 ../utils/figcreator.py --tile 2x1 _dTop.png _dBottom.png _d1.png
python3 ../utils/figcreator.py --resize "x:1614:iso" _d1.png _d2.png
python3 ../utils/figcreator.py -t "TCh:ECG-CINE" _d2.png _d3.png
python3 ../utils/figcreator.py -t "LTh:d)" _d3.png _d.png


#--- Join ---
python3 ../utils/figcreator.py --tile 3x1 _a.png _b.png _c.png _abc.png
python3 ../utils/figcreator.py --tile 2x1 --spacing 35 _abc.png _d.png _SoS.png


python3 ../utils/figcreator.py --arrow 1008:816:40:45:4:9 _SoS.png _SoS.png
python3 ../utils/figcreator.py --arrow 305:140:40:120:4:9 _SoS.png Fig6_SoS.png

rm _*.png
rm ECG/_end*.png
rm _*.{cfl,hdr}
