#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SupFig3 of the followin manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020


set -e

#--- BART ---
export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi



for type in "sin" "spell" "trend" "noise"; do

	bart ssa -w101 k_$type EOF_$type S_${type}

	# Global PCA
	bart ssa -w1 k_$type U_$type S_pca_${type}
done



