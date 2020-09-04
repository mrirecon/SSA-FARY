#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig5-6 of the following manuscript:
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

args=["EOF_1171", "PCA", "_resp", "_card"]

EOF = np.squeeze(readcfl(str(args[0])))
PCA = np.squeeze(readcfl(str(args[1])))

DPI = 200

###### 
# EOF
######

#%% 
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1500/DPI, 900/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.set_xlabel("Samples [a.u.]")
norm = np.max(EOF[:,0:2])
ax.plot(np.real(EOF[:,0]/norm), color=color[0], linestyle=linestyle[0], linewidth=2, label="EOF 1")
ax.plot(np.real(EOF[:,1]/norm), color=color[4], linestyle=linestyle[0], linewidth=2, label="EOF 2")
plt.legend(loc=4)
fig.savefig(str(args[-2]) + ".png", dpi=DPI, bbox_inches='tight')

#%% 
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1500/DPI, 900/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.set_xlabel("Samples [a.u.]")
norm = np.max(EOF[:,2:4])
ax.plot(np.real(EOF[:,2]/norm), color=color[0], linestyle=linestyle[0], linewidth=2, label="EOF 3")
ax.plot(np.real(EOF[:,3]/norm), color=color[4], linestyle=linestyle[0], linewidth=2, label="EOF 4")
plt.legend(loc=4)
fig.savefig(str(args[-1]) + ".png", dpi=DPI, bbox_inches='tight')

######
# PCA
######
#%% 
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1500/DPI, 900/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.set_xlabel("Samples [a.u.]")
norm = np.max(PCA[:,0])
ax.plot(np.real(PCA[:,0]/norm), color=color[1], linestyle=linestyle[0], linewidth=2,)
fig.savefig(str(args[-2]) + "_PCA.png", dpi=DPI, bbox_inches='tight')

#%% 
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(1500/DPI, 900/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.set_xlabel("Samples [a.u.]")
norm = np.max(PCA[:,1])
ax.plot(np.real(PCA[:,1]/norm), color=color[1], linestyle=linestyle[0], linewidth=2,)
fig.savefig(str(args[-1]) + "_PCA.png", dpi=DPI, bbox_inches='tight')

