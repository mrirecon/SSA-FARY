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

#--- Export Images ---
# Images
bart resize -c 0 192 1 192 rss _pics1
bart transpose 0 1 _pics1 _pics

endsys=18
inter=21
enddia=7
resp=1

bart slice 10 $endsys _pics _endsys0
bart slice 11 $resp _endsys0 _endsys

bart slice 10 $inter _pics _inter0
bart slice 11 $resp _inter0 _inter

bart slice 10 $enddia _pics _enddia0
bart slice 11 $resp _enddia0 _enddia

cfl2png -u 0.5 -z 5 -F Y _endsys{,}
cfl2png -u 0.5 -z 5 -F Y _inter{,}
cfl2png -u 0.5 -z 5 -F Y _enddia{,}


#--- Plots ---
python3 plot.py


#--- Process Images ---
# Diastole
python3 ../utils/figcreator.py -t "LCv:end-systole" _endsys.png _endsys1.png
python3  ../utils/figcreator.py --tile 1x2  _endsys1.png CINE/slice_06-1_frame11_endsys-5x.jpg _sys.png

# Itermediate
python3 ../utils/figcreator.py -t "LCv: " _inter.png _inter1.png
python3  ../utils/figcreator.py --tile 1x2 _inter1.png CINE/slice_06-1_frame14_inter-5x.jpg _inter.png

# Systole
python3 ../utils/figcreator.py -t "TCh:SSA-FARY Gridding" _enddia.png _enddia1.png
python3 ../utils/figcreator.py -t "TCh:ECG-CINE" CINE/slice_06-1_frame23_enddia-5x.jpg _enddia_cine.png

python3 ../utils/figcreator.py -t "LCv:end-diastole    " _enddia1.png _enddia2.png
python3  ../utils/figcreator.py --tile 1x2 _enddia2.png _enddia_cine.png _dia.png



# Tile
python3  ../utils/figcreator.py --spacing 20 --tile 3x1 _dia.png _inter.png _sys.png _c1.png
convert -trim _c{1,2}.png
python3  ../utils/figcreator.py --resize "x:2000:iso" _c2.png _c3.png

python3  ../utils/figcreator.py -t "LTh:c)" _c3.png _c.png


#--- Plots ---
python3  ../utils/figcreator.py --tile 1x2 _A.png _B.png _SSA1.png
convert -trim _SSA{1,2}.png
python3  ../utils/figcreator.py --resize "x:2000:iso" _SSA2.png _a1.png
python3  ../utils/figcreator.py -t "LTh:a)" _a1.png _a.png

python3  ../utils/figcreator.py --tile 1x2 _A_PCA.png _B_PCA.png _PCA1.png
convert -trim _PCA{1,2}.png
python3  ../utils/figcreator.py --resize "x:2000:iso" _PCA2.png _b1.png
python3  ../utils/figcreator.py -t "LTh:b)" _b1.png _b.png

python3 ../utils/figcreator.py --tile 3x1 --spacing 40 _{a,b,c}.png SupFig4_SS-bssfp_gridding.png

rm _*.{cfl,hdr,png}


