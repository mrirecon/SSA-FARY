#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce SubFig7 of the following manuscript:
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
path = '../ssa_fary_utils/LinBiolinum_R.otf'
prop = font_manager.FontProperties(fname=path)
mpl.rcParams['font.family'] = prop.get_name()
import pandas as pd
from optparse import OptionParser

# Option Parsing
parser = OptionParser(description="Plotting.", usage="%prog [-options] <img> <eof> <dst>")
(options, args) = parser.parse_args()
DPI = 200

#%% EOF & Real-time
RT = plt.imread(str(args[0]))
EOF = np.squeeze(readcfl(str(args[1])))
EOF = EOF / np.max(np.real(EOF)) * 2500 - 120


#%% Respiration belt
dt = 2.5 # [ms] sample duration
resp = np.loadtxt(str(args[2]))
resp_no_trig = resp[ resp != 5000 ] # remove trigger points
T_tot = resp.shape[0] * dt
Samples_meas = 60900 / dt
#%%
start = 12637
end = int(start + Samples_meas)
resp_ex = resp_no_trig[start:end]
#%% # Interpolate
xp = np.linspace(0, EOF[:,0].shape[0], resp_ex.shape[0]) 
x = np.linspace(0, EOF[:,0].shape[0], EOF[:,0].shape[0])
resp_interp = np.interp(x,xp,resp_ex)
resp_interp_norm = - resp_interp / np.max(np.abs(resp_interp))  * 400 + 50
#%%

fig, ax =plt.subplots(nrows=1, ncols=1, figsize=(3000/DPI, 500/DPI))
ax.imshow(RT, extent=[0, 7000, -400,400])
ax.plot(0.6 * resp_interp_norm,  linewidth=2, color=color[1], label="Belt") 
ax.plot(0.6 * np.real(EOF[:,0]),  linewidth=2, color=color[4], label="EOF 1") # consider indexing

ax.legend(loc='lower left', bbox_to_anchor= (0.0, 1.01), ncol=3,
            borderaxespad=0, frameon=False)
ax.axis("off")
plt.savefig(str(args[-1])+ ".png", dpi=DPI, bbox_inches='tight')
