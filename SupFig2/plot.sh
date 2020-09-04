#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SupFig2 of the followin manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020


set -e


function plot {
	K="k_"$1
	echo "echo: " $K
 	osc1="osc_"${1}"1"
 	osc2="osc_"${1}"2"
 	EOF="EOF_"$1
 	S="S_"$1
 	U="U_"$1
 	python3 ../Fig2/plot_data.py --ylim $ylim --y2lim $y2lim -x $interval --eof $eof $K $S $EOF $U osc_sin1 osc_sin2 $1
}


# Simulation Parameters
interval="0:1000"


####################################
# Amplitude variations too high
####################################
spell_amp=3
noise_amp=7
trend_amp=7
var=2
ylim=8
y2lim=1.8


# Plot
eof="1:2:3:4"
plot "trend"

eof="0:1:4:5"
plot "spell"

eof="0:1:2:3"
for type in "noise" "sin"; do
	plot $type
done

# Post processing

# Remove white border
for i in *.png; do

	convert -trim $i $i
done

# Adjust size
h=$(convert _S_noise.png -print "%h\n" _tmp.png)
for i in _U*png _k*png _noise.png _trend.png _spell.png *noise_0*png *noise_2*.png *trend_0*png *trend_2*png *spell_0*png; do

	python3 ../utils/figcreator.py --resize "y:${h}:crop" $i $i
done

# Tile
for type in "noise" "spell" "trend"; do

	python3 ../utils/figcreator.py --tile '3x3' --spacing 40 \
	_${type}.png _k_${type}.png _S_${type}.png \
	_U_${type}_1.png _EOF_${type}_0_1.png _EOF_${type}_scatter_0_1.png \
	_U_${type}_2.png _EOF_${type}_2_3.png _EOF_${type}_scatter_2_3.png \
	_res_${type}.png
done


# Arrange
# a)
python3 ../utils/figcreator.py --tile '1x3' _osc_sin1.png _osc_sin2.png _k_sin.png   --spacing 40 _a.png
python3 ../utils/figcreator.py -t "LTh:a) " _a.png _a.png
w=$(convert _a.png -print "%w\n" _tmp.png)

# b)
python3 ../utils/figcreator.py -t "LTh:b) " _res_noise.png _b.png
python3 ../utils/figcreator.py --resize "x:${w}:crop" _b.png _b.png

# c)
python3 ../utils/figcreator.py -t "LTh:c) " _res_spell.png _c.png
python3 ../utils/figcreator.py --resize "x:${w}:crop" _c.png _c.png
# d)
python3 ../utils/figcreator.py -t "LTh:d) " _res_trend.png _d.png
python3 ../utils/figcreator.py --resize "x:${w}:crop" _d.png _d.png

# Join
python3 ../utils/figcreator.py --tile "4x1" --spacing 100 _a.png _b.png _c.png _d.png SupFig2_AmpVarEx.png

rm _*.png


