#!/usr/bin/env bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig3-4 of the following manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020

set -e

#--- Extract images ---

# AC region
bart resize -c 10 100 KDC _kDC_res
bart transpose 3 10 _kDC_res _kDC_res1
cfl2png -z8 -l 0.09 -u 0.255 -C G _kDC_res1 Fig3a_AC

bart resize -c 10 100 Kc _kc_res
bart transpose 3 10 _kc_res _kc_res1
cfl2png -z8 -l 0.09 -u 0.255 -C G _kc_res1 Fig3b_AC-corr

# Recos
endsys=18
inter=21
enddia=7
endexh=4
endinh=0

bart slice 10 $endsys SS _endsys
bart slice 11 $endexh _endsys _endsys_endexh
bart slice 11 $endinh _endsys _endsys_endinh

bart slice 10 $inter SS _inter
bart slice 11 $endexh _inter _inter_endexh
bart slice 11 $endinh _inter _inter_endinh

bart slice 10 $enddia SS _enddia
bart slice 11 $endexh _enddia _enddia_endexh
bart slice 11 $endinh _enddia _enddia_endinh

cfl2png -u 0.485 -z 4 -F Y _endsys_endexh{,}
cfl2png -u 0.485 -z 4 -F Y _inter_endexh{,}
cfl2png -u 0.585 -z 4 -F Y _endsys_endinh{,}
cfl2png -u 0.485 -z 4 -F Y _enddia_endexh{,}
cfl2png -u 0.585 -z 4 -F Y _inter_endinh{,}
cfl2png -u 0.585 -z 4 -F Y _enddia_endinh{,}

#--- Plots ---
python3 plot.py


#--- Images ---
# Diastole
python3 ../utils/figcreator.py -t "LCv:end-systole" _endsys_endexh.png _endsys_endexh1.png
python3  ../utils/figcreator.py --tile 1x3  _endsys_endexh1.png _endsys_endinh.png  CINE/slice_06-1_frame11_endsys.jpg _sys.png

# Itermediate
python3 ../utils/figcreator.py -t "LCv: " _inter_endexh.png _inter_endexh1.png
python3  ../utils/figcreator.py --tile 1x3 _inter_endexh1.png _inter_endinh.png  CINE/slice_06-1_frame14_inter.jpg _inter.png

# Systole
python3 ../utils/figcreator.py -t "TCh:SSA-FARY end-expiration" _enddia_endexh.png _enddia_exh1.png
python3 ../utils/figcreator.py -t "TCh:SSA-FARY end-inspiration" _enddia_endinh.png _enddia_inh1.png
python3 ../utils/figcreator.py -t "TCh:ECG-CINE" CINE/slice_06-1_frame23_enddia.jpg _enddia_cine.png

python3 ../utils/figcreator.py -t "LCv:end-diastole    " _enddia_exh1.png _enddia_exh2.png
python3  ../utils/figcreator.py --tile 1x3 _enddia_exh2.png _enddia_inh1.png  _enddia_cine.png _dia.png



# Tile
python3  ../utils/figcreator.py --spacing 20 --tile 3x1 _dia.png _inter.png _sys.png _c1.png
convert -trim _c{1,2}.png
python3  ../utils/figcreator.py --resize "x:2100:iso" _c2.png _c3.png

python3  ../utils/figcreator.py -t "LTh:c)" _c3.png _c.png


#--- Plots ---
python3  ../utils/figcreator.py --tile 1x2 _resp.png _card.png _SSA1.png
convert -trim _SSA{1,2}.png
python3  ../utils/figcreator.py --resize "x:2100:iso" _SSA2.png _a1.png
python3  ../utils/figcreator.py -t "LTh:a)" _a1.png _a.png

python3  ../utils/figcreator.py --tile 1x2 _resp_PCA.png _card_PCA.png _PCA1.png
convert -trim _PCA{1,2}.png
python3  ../utils/figcreator.py --resize "x:2100:iso" _PCA2.png _b1.png
python3  ../utils/figcreator.py -t "LTh:b)" _b1.png _b.png

python3 ../utils/figcreator.py --tile 3x1 --spacing 40 _{a,b,c}.png Fig4_SS.png

#--- AC region ---
python3 ../utils/figcreator.py -t "LCv:Coils" Fig3a_AC.png _a0.png
python3 ../utils/figcreator.py -t "BCh:Time →" _a0.png _a1.png
python3 ../utils/figcreator.py -t "LTh:a)" _a1.png _a.png

python3 ../utils/figcreator.py -t "LCv:Coils" Fig3b_AC-corr.png _b0.png
python3 ../utils/figcreator.py -t "BCh:Time →" _b0.png _b1.png
python3 ../utils/figcreator.py -t "LTh:b)" _b1.png _b.png

python3 ../utils/figcreator.py --tile 1x2 _a.png _b.png _AC.png
convert -trim _AC.png Fig3_AC.png

#---Clean up ---
rm _*.{cfl,hdr,png}


