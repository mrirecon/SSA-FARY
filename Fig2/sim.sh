#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig2 of the followin manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020


set -e


# Simulation Parameters
interval="0:1000"
nSamples=1000
nTime=800
nChannels=30
Ta=80
Tb=30
Tc=10
phi_a=0
phi_b=0.5
spell="220:300"
spell_amp=1
noise_amp=2
trend_amp=3
var=2
ylim=2.5
y2lim=1
eof="0:1:2:3"

####################################
# main manuscript
####################################

python3 sim_data.py -n $nSamples -T $nTime -c $nChannels --Ta $Ta --Tb $Tb --Tc $Tc \
	    --phia $phi_a --phib $phi_b --spell $spell \
	    --var $var --spell_amp $spell_amp --trend_amp $trend_amp --noise_amp $noise_amp



