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



# Simulation Parameters
nSamples=1000
nTime=800
nChannels=30
Ta=80
Tb=30
Tc=10
phi_a=0
phi_b=0.5
spell="220:300"


####################################
# Frequency variations
####################################
spell_amp=1
noise_amp=2
trend_amp=3
var=3
ylim=2.5
y2lim=1

python3 ../Fig2/sim_data.py -n $nSamples -T $nTime -c $nChannels --Ta $Ta --Tb $Tb --Tc $Tc \
	    --phia $phi_a --phib $phi_b --spell $spell \
	    --var $var --spell_amp $spell_amp --trend_amp $trend_amp --noise_amp $noise_amp


