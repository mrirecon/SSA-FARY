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

#--- BART ---
if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.5.00"

# get data either from sim, or from data archive
source ../ssa_fary_utils/data_loc.sh


####################################
# Amplitude variations too high
####################################

for type in "sin" "spell" "trend" "noise"; do
	if [ ! -f k_${type}.cfl ] ; then
		DATA=${DATA_LOC}/sim/SupFig2/k_${type}
	else
		DATA=./k_${type}
	fi

	bart ssa -w101 ${DATA} EOF_$type S_${type}

	# Global PCA
	bart ssa -w1 ${DATA} U_$type S_pca_${type}
done



