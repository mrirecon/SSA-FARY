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
args=("EOF_81", "EOF_91", "EOF_101")
label=["W=81", "W=91", "W=101"]
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

# Plot EOF Respiration
rows=1
cols=2
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1800/DPI, 500/DPI))
c=0
for col in ax:
    col.set_xlabel("Samples [a.u.]")
        
    if (c == 0):
        col.set_title("Respiration[a.u.]")
        col.grid()
        col.set_ylim(-1.1,1.6)
        col.set_xlim(0,int_end)   
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,0,0])[int_start:int_end]), label=label[0], linewidth=2, linestyle=linestyle[1],  color=color[1])
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,0,1])[int_start:int_end]), label=label[1], linewidth=2, linestyle=linestyle[0],  color=color[0])
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,0,2])[int_start:int_end]), label=label[2], linewidth=2, linestyle=linestyle[3],  color=color[3])
        col.legend(ncol=3, fontsize='11', loc='upper center')
    else:
        col.grid()
        col.set_ylim(-1.1,1.6)
        col.set_xlim(0,int_end)   
        col.set_title("Cardiac [a.u.]")         
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,3,0])[int_start:int_end]), label=label[0], linewidth=2, linestyle=linestyle[1],  color=color[1])
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,2,1])[int_start:int_end]), label=label[1], linewidth=2, linestyle=linestyle[0],  color=color[0])
        col.plot(t[int_start:int_end], normalize(np.real(EOF[:,2,2])[int_start:int_end]), label=label[2], linewidth=2, linestyle=linestyle[3],  color=color[3])
        col.legend(ncol=3, fontsize='11', loc='upper center')
    c += 1          
fig.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=0.1, hspace=0.1)    
fig.savefig( "_out2.png", dpi=DPI, bbox_inches='tight')

          
    
     
