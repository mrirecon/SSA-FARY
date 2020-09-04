#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig9 of the following manuscript:
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

eof_91 = readcfl("EOF_91")
eof_21 = readcfl("EOF_21")

DPI = 200

#%%
int_start=500
int_end=5200
t = np.linspace(0,eof_91.shape[0],eof_91.shape[0], endpoint="False")

idx=0
# Plot EOF 
rows=2
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1800/DPI, 1200/DPI))
ax[0].grid()
ax[0].set_title("Respiration [a.u.] - W=91")
ax[0].set_ylim(-1.1,1.9)
ax[0].set_xlim(int_start,int_end) 
ax[0].set_xticklabels([])   

norm_r = np.max(np.abs(eof_91[:,1])[int_start:int_end])
ax[0].plot(t[int_start:int_end], np.real(eof_91[:,0])[int_start:int_end] / norm_r , label="EOF 1", linewidth=2, color=color[1])
ax[0].plot(t[int_start:int_end], np.real(eof_91[:,1])[int_start:int_end] / norm_r, label="EOF 2", linewidth=2, color=color[4])
ax[0].plot(t[int_start:int_end], np.real(eof_91[:,2])[int_start:int_end] / norm_r, label="EOF 3", linewidth=2, color=color[0])
ax[0].legend(ncol=3, loc='upper center', bbox_to_anchor=(0.5, 1.05))

norm_c = np.max(np.abs(eof_21[:,2])[int_start:int_end])
ax[1].grid()
ax[1].set_title("Cardiac [a.u.] - W=21")
ax[1].set_ylim(-1.1,1.9)
ax[1].set_xlim(int_start,int_end) 
ax[1].set_xlabel("Samples [a.u.]")
ax[1].plot(t[int_start:int_end], np.real(eof_21[:,2])[int_start:int_end] / norm_c, label="EOF 3", linewidth=2, color=color[4])
ax[1].plot(t[int_start:int_end], np.real(eof_21[:,3])[int_start:int_end] / norm_c, label="EOF 4", linewidth=2, color=color[0])
ax[1].legend(ncol=2, loc='upper center', bbox_to_anchor=(0.5, 1.05))

fig.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=None, hspace=0.3)    
fig.savefig( "_out.png", dpi=DPI, bbox_inches='tight')


          
    
     
