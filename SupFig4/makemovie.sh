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

bart resize -c 0 192 1 192 rss _a
bart transpose 0 1 _a _aa

# Cardiac motion
bart slice 11 1 _aa _b
cfl2png -F Y -u0.5 _b SS_R

ffmpeg -r 25 -f image2 -i SS_R_frame_%4d.png -b 1500k -vcodec wmv2 -pix_fmt yuv420p Mov5_SS-bssfp_gridding.wmv

rm SS_R*.png
rm _*.{cfl,hdr}

