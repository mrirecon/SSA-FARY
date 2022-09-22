#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig5-6 of the following manuscript:
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
# AC region
bart resize -c 10 100 KDC _kDC_res
bart transpose 3 10 _kDC_res _kDC_res1
cfl2png -z8 -l 0.09 -u 0.255 -C G _kDC_res1 SupFig5a_AC

bart resize -c 10 100 Kc _kc_res
bart transpose 3 10 _kc_res _kc_res1
cfl2png -z8 -l 0.09 -u 0.255 -C G _kc_res1 SupFig5b_AC-corr

rm _*.{cfl,hdr}

bart resize -c 0 192 1 192 SS _pics

endsys=0
enddia=11
endexh=7
inter=4
endinh=2

bart slice 10 $endsys _pics _endsys
bart slice 11 $endexh _endsys _endsys_endexh
bart slice 11 $endinh _endsys _endsys_endinh
bart slice 11 $inter _endsys _endsys_inter

bart slice 10 $enddia _pics _enddia
bart slice 11 $endexh _enddia _enddia_endexh
bart slice 11 $endinh _enddia _enddia_endinh
bart slice 11 $inter _enddia _enddia_inter

cfl2png -u 0.48 -z 3.6 -F X _endsys_endexh{,}
cfl2png -u 0.48 -z 3.6 -F X _endsys_inter{,}
cfl2png -u 0.48 -z 3.6 -F X _endsys_endinh{,}
cfl2png -u 0.48 -z 3.6 -F X _enddia_endexh{,}
cfl2png -u 0.48 -z 3.6 -F X _enddia_inter{,}
cfl2png -u 0.48 -z 3.6 -F X _enddia_endinh{,}


#--- Plots ---
python3 plot.py

#--- Process Images ---
# Diastole
python3 ../ssa_fary_utils/figcreator.py -t "LCv:end-systole" _endsys_endinh.png _endsys_inh1.png
python3  ../ssa_fary_utils/figcreator.py --tile 1x3 _endsys_inh1.png _endsys_inter.png _endsys_endexh.png _sys.png

# Systole
python3 ../ssa_fary_utils/figcreator.py -t "TCh:end-expiration" _enddia_endexh.png _enddia_exh1.png
python3 ../ssa_fary_utils/figcreator.py -t "TCh: " _enddia_inter.png _enddia_inter1.png
python3 ../ssa_fary_utils/figcreator.py -t "TCh:end-inspiration" _enddia_endinh.png _enddia_inh1.png

python3 ../ssa_fary_utils/figcreator.py -t "LCv:end-diastole    " _enddia_inh1.png _enddia_inh2.png
python3  ../ssa_fary_utils/figcreator.py --tile 1x3 _enddia_inh2.png _enddia_inter1.png _enddia_exh1.png _dia.png


# Tile
python3  ../ssa_fary_utils/figcreator.py --spacing 20 --tile 2x1 _dia.png _sys.png _c1.png
convert -trim _c{1,2}.png
python3  ../ssa_fary_utils/figcreator.py --resize "x:2100:iso" _c2.png _c3.png

python3  ../ssa_fary_utils/figcreator.py -t "LTh:c)" _c3.png _c.png


#--- Plots ---
python3  ../ssa_fary_utils/figcreator.py --tile 1x2 _resp.png _card.png _SSA1.png
convert -trim _SSA{1,2}.png
python3  ../ssa_fary_utils/figcreator.py --resize "x:2100:iso" _SSA2.png _a1.png
python3  ../ssa_fary_utils/figcreator.py -t "LTh:a)" _a1.png _a.png

python3  ../ssa_fary_utils/figcreator.py --tile 1x2 _resp_PCA.png _card_PCA.png _PCA1.png
convert -trim _PCA{1,2}.png
python3  ../ssa_fary_utils/figcreator.py --resize "x:2100:iso" _PCA2.png _b1.png
python3  ../ssa_fary_utils/figcreator.py -t "LTh:b)" _b1.png _b.png

python3 ../ssa_fary_utils/figcreator.py --tile 3x1 _{a,b,c}.png SupFig6_SS.png

#--- AC region ---
python3 ../ssa_fary_utils/figcreator.py -t "LCv:Coils" SupFig5a_AC.png _a0.png
python3 ../ssa_fary_utils/figcreator.py -t "BCh:Time →" _a0.png _a1.png
python3 ../ssa_fary_utils/figcreator.py -t "LTh:a)" _a1.png _a.png

python3 ../ssa_fary_utils/figcreator.py -t "LCv:Coils" SupFig5b_AC-corr.png _b0.png
python3 ../ssa_fary_utils/figcreator.py -t "BCh:Time →" _b0.png _b1.png
python3 ../ssa_fary_utils/figcreator.py -t "LTh:b)" _b1.png _b.png

python3 ../ssa_fary_utils/figcreator.py --tile 1x2 _a.png _b.png _AC.png
convert -trim _AC.png SupFig5_AC.png

rm _*.{cfl,hdr,png}


