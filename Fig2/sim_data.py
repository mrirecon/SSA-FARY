#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig2 and SupFig1-3 of the manuscript
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag (2020)

import numpy as np
import scipy.signal as scp
import sys
import os
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))
from cfl import readcfl
from cfl import writecfl
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from optparse import OptionParser

# Option Parsing
parser = OptionParser(description="Signal simulation.", usage="%prog [-options]")
parser.add_option("-n", dest="n",
                 help="Number of samples", default="1000")
parser.add_option("-T", dest="T",
                 help="Total Time", default="800")
parser.add_option("-c", dest="c",
                 help="Number of channels", default="30")
parser.add_option("--Ta", dest="Ta",
                 help="Period of oscillation 1", default="80")
parser.add_option("--Tb", dest="Tb",
                 help="Period of oscillation 2", default="30")
parser.add_option("--Tc", dest="Tc",
                 help="Period of spell", default="10")
parser.add_option("--phia", dest="phia",
                 help="Phi oscillation 1", default="0")
parser.add_option("--phib", dest="phib",
                 help="Phi oscillation 2", default="0.5")
parser.add_option("--spell", dest="spell",
                 help="Spell  position spell_start:spell_end", default="220:300")
parser.add_option("--var", dest="var",
                 help="Frequency variation.", default="2")
parser.add_option("--spell_amp", dest="spell_amp",
                 help="Spell amplitude.", default="1")
parser.add_option("--noise_amp", dest="noise_amp",
                 help="Noise amplitude.", default="2")
parser.add_option("--trend_amp", dest="trend_amp",
                 help="Trend amplitude.", default="3")

(options, args) = parser.parse_args()

nSamples = int(options.n)
T = int(options.T)
nChannels = int(options.c)
Ta = int(options.Ta)
Tb = int(options.Tb)
Tc = int(options.Tc)
phi_a = float(options.phia)
phi_b = float(options.phib)
spell = str(options.spell)
spell_start, spell_end = [int(k) for k in spell.split(":")]
var = float(options.var)
noise_amp = float(options.noise_amp)
spell_amp = float(options.spell_amp)
trend_amp = float(options.trend_amp)

#%%
# Set up data array
t = np.linspace(0, T, nSamples, endpoint=False)
k_sin = np.zeros(shape=(nSamples, nChannels), dtype="complex")
k_noise = np.zeros(shape=(nSamples, nChannels), dtype="complex")
k_spell = np.zeros(shape=(nSamples, nChannels), dtype="complex")
k_trend = np.zeros(shape=(nSamples, nChannels), dtype="complex")
osc_spell = np.zeros(shape=(nSamples))
    
np.random.seed(0)

#%%
for c in range(nChannels): 
    
    # Respiratory oscillation (with drift)
    phase_resp = np.sin(2 * np.pi * t / 2 / T) * var
    osc_sin1 = 3 * np.sin( phi_a + 2 * np.pi * t / Ta + phase_resp)
    
    # Cardiac oscillation (with variability)
    phase_card = np.sin(2 * np.pi * t / T) * var
    osc_sin2 = 1 * np.sin(phi_b + 2 * np.pi * t / Tb + phase_card)
      
    # Noise
    noise = np.random.normal(0, noise_amp, nSamples)
    osc_noise1 = osc_sin1
    osc_noise2 = osc_sin2
    
    # Spell
    spell = np.zeros(shape=(nSamples), dtype="complex")
    spell[spell_start:spell_end] =  np.sin(phi_a + 2 * np.pi * t[:(spell_end - spell_start)] / Tc) * spell_amp
    osc_spell1 = osc_sin1
    osc_spell2 = osc_sin2
    
    # Trend
    trend = (np.exp(t / np.max(t) * 3))
    trend = trend / np.max(trend) * trend_amp
    trend -= np.max(trend) / 2    
    
    osc_trend1 = osc_sin1
    osc_trend2 = osc_sin2
    
    # Add up    
    a1 = (c + 1) / nChannels 
    a2 = (nChannels - c) / nChannels
    
    k_sin[:, c]   =  a1 * osc_sin1    + a2 * osc_sin2
    k_noise[:, c] = (a1 * osc_noise1  + a2 * osc_noise2) + noise
    k_spell[:, c] = (a1 * osc_spell1  + a2 * osc_spell2) + spell 
    k_trend[:, c] = (a1 * osc_trend1  + a2 * osc_trend2) + trend
        

writecfl("osc_sin1",   osc_sin1)
writecfl("osc_sin2",   osc_sin2)
writecfl("sin", np.zeros(shape=(nSamples))) # for bash-script to run poperly
writecfl("noise", noise)
writecfl("trend", trend)
writecfl("spell", spell)


writecfl("k_sin",   k_sin)
writecfl("k_noise", k_noise)
writecfl("k_spell", k_spell)
writecfl("k_trend", k_trend)
