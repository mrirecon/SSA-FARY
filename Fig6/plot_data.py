#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig6 of the following manuscript:
#
# Rosenzweig S et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020

import sys
import os
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))
from cfl import readcfl
from cfl import writecfl
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter

color = ["#348ea9","#ef4846","#52ba9b","#f48b37", "#89c2d4","#ef8e8d","#a0ccc5","#f4b481"]
linestyle = ["-", "--", "-.", ":"]
marker = ["o", "^", "s", "8"]
import matplotlib.font_manager as font_manager
from matplotlib import rcParams
mpl.rcParams.update({'font.size': 22})
path = '../utils/LinBiolinum_R.otf'
prop = font_manager.FontProperties(fname=path)
mpl.rcParams['font.family'] = prop.get_name()
import pandas as pd
from optparse import OptionParser

# Option Parsing
parser = OptionParser(description="Plotting.", usage="%prog [-options] <src:EOF_a> <src:EOF_b> <src:EOF_c> <dst>")
(options, args) = parser.parse_args()
args=("EOF_31", "EOF_91", "EOF_151")
label=["W=31", "W=91", "W=151"]
dummy = readcfl(str(args[0]))[:,:20]
EOF = np.zeros(np.append(dummy.shape,len(args)), dtype="complex")
for i in range(len(args)):
    EOF[...,i] = readcfl(str(args[i]))[:,:20]

DPI = 200

def normalize(arr):
    return arr / np.max(np.abs(arr))
#%%
int_start=0
int_end=900
t = np.linspace(0,EOF.shape[0],EOF.shape[0], endpoint="False")

# Plot EOF
rows=3
cols=2
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1800/DPI, 1200/DPI))
idx = 0
for row in ax:
    c = 0
    for col in row:
        if (idx != len(args) - 1):
            col.set_xticklabels([])   
        else:
            col.set_xlabel("Samples [a.u.]")
            
        if (c == 0):
            col.grid()
            col.text(810, 0.7, label[idx], {'fontsize': 15, 'ha': 'center', 'va': 'center',
          'bbox': dict(boxstyle="round", fc="w", ec="k", pad=0.2)})
            col.set_ylim(-1.1,1.1)
            col.set_xlim(0,int_end)   
            col.plot(t[int_start:int_end], normalize(np.real(EOF[:,0,idx])[int_start:int_end]), label=label[idx], linewidth=2, color=color[4])
            col.plot(t[int_start:int_end], normalize(np.real(EOF[:,1,idx])[int_start:int_end]), label=label[idx], linewidth=2, color=color[0])
        else:
            col.grid()
            col.set_ylim(-1.1,1.1)
            col.set_xlim(0,int_end)   
            col.set_yticklabels([])   
            col.text(810, 0.7, label[idx], {'fontsize': 15, 'ha': 'center', 'va': 'center',
          'bbox': dict(boxstyle="round", fc="w", ec="k", pad=0.2)})            
            col.plot(t[int_start:int_end], normalize(np.real(EOF[:,2,idx])[int_start:int_end]), label=label[idx], linewidth=2, color=color[4])
            col.plot(t[int_start:int_end], normalize(np.real(EOF[:,3,idx])[int_start:int_end]), label=label[idx], linewidth=2, color=color[0])
        if (idx == 0):
            if (c == 0):
                col.set_title("Respiration[a.u.]")
                    
            else:
                col.set_title("Cardiac [a.u.]")         
        c += 1          
    idx += 1
fig.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=0.02, hspace=0.1)    
fig.savefig( "_out.png", dpi=DPI, bbox_inches='tight')

          
    
     
