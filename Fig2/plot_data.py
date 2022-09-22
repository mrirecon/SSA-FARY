#!/usr/bin/env python3
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
#
# Script to reproduce Fig2 and SupFig1-3 of the manuscript
#
# Rosenzweig S. et al.
# Cardiac and Respiratory Self-Gating in Radial MRI using an
# Adapted Singular Spectrum Analysis (SSA-FARY).
# IEEE Trans Med Imag. 2020.

import sys
import os
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))
from cfl import readcfl
from cfl import writecfl
import numpy as np
import matplotlib as mpl
mpl.use('Agg');
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
parser = OptionParser(description="Plotting.", usage="%prog [-options] <src:k> <src:S> <src:EOF> <src:PCA> <src:osc1> <src:osc2>")
parser.add_option("-x", dest="xdims",
                 help="x dimensions x_start:x_end", default="0:1000")
parser.add_option("--ylim", dest="ylim",
                 help="y limits noise", default="1")
parser.add_option("--y2lim", dest="y2lim",
                 help="y limits other", default="1")
parser.add_option("--eof", dest="eof_idx",
                 help="Choose index for EOFs: eof1:eof2:eof3:eof4", default="0:1:2:3")

(options, args) = parser.parse_args()
k = readcfl(str(args[0]))
S = np.real(readcfl(str(args[1])))[:30]
EOF = readcfl(str(args[2]))
PCA = readcfl(str(args[3]))
osc1 = readcfl(str(args[4]))
osc2 = readcfl(str(args[5]))
typ = readcfl(str(args[6]))

xdims = str(options.xdims)
ylim = float(options.ylim)
y2lim = float(options.y2lim)
st, end = [int(k) for k in xdims.split(":")]
eof_idx = str(options.eof_idx)
eof1, eof2, eof3, eof4 = [int(k) for k in eof_idx.split(":")]

DPI = 200

#%%
t = np.linspace(0, k.shape[0], k.shape[0], endpoint=False)

# Plot Superposition 
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
if (str(args[6]) == "sin"):
    ax.set_xlabel("Samples [a.u.]")
ax.set_ylim([-1,1])
norm = 3.5

if(str(args[6]) == "noise"):
    ax.set_ylim([-ylim,ylim])
elif(y2lim != 1 and str(args[6]) != "sin"):
    ax.set_ylim([-y2lim,y2lim])
    
ax.plot(t[st:end], 1. / norm * np.real(k)[st:end,15], color="black", linestyle=linestyle[0], linewidth=2, label="Signal")
fig.savefig("_"+str(args[0]) + ".png", dpi=DPI, bbox_inches='tight')

#%%
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.yaxis.set_major_formatter(FormatStrFormatter('%.0f'))
ax.set_ylim([-1,1])

if(str(args[6]) == "noise"):
    ax.set_ylim([-ylim,ylim])
elif(y2lim != 1 and str(args[6]) != "sin"):
    ax.set_ylim([-y2lim,y2lim])
    
ax.plot(t[st:end], 1. / norm * np.real(typ[:])[st:end], color="black", linestyle=linestyle[0], linewidth=2, label="Type")
fig.savefig("_"+str(args[6]) + ".png", dpi=DPI, bbox_inches='tight')

#%%
# Plot Oscillation 1
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("Samples [a.u.]")
ax.set_ylabel("Amplitude [a.u.]")
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1 / norm * np.real(osc1)[st:end], color="grey", linestyle=linestyle[0], linewidth=2, label="Subsignal 1")
fig.savefig("_"+str(args[4]) + ".png", dpi=DPI, bbox_inches='tight')

#%%
# Plot Oscillation 2
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("Samples [a.u.]")
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1 / norm * np.real(osc2)[st:end], color="grey", linestyle=linestyle[0], linewidth=2, label="Subsignal 2")
fig.savefig("_"+str(args[5]) + ".png", dpi=DPI, bbox_inches='tight')

#%%
# Plot PCA A
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_ylabel("Amplitude [a.u.]")
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1. / np.max(np.abs(PCA)[:,0]) * np.real(PCA[:,0])[st:end], color=color[1], linestyle=linestyle[0], linewidth=2, label="EV 1")
fig.savefig("_"+str(args[3]) + "_1.png", dpi=DPI, bbox_inches='tight')

#%%
# Plot PCA B
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("Samples [a.u.]")
ax.set_ylabel("Amplitude [a.u.]")
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1. / np.max(np.abs(PCA)[:,1]) * np.real(PCA[:,1])[st:end], color=color[1], linestyle=linestyle[0], linewidth=2, label="EV 2")
fig.savefig("_"+str(args[3]) + "_2.png", dpi=DPI, bbox_inches='tight')

#%%
# Singular Value
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("Index [a.u.]")
ax.set_ylabel("S [a.u.]")
ax.set_ylim([0,1])#
ax.plot(1. / np.max(np.abs(S)) * S, color=color[0], linewidth=2, marker=marker[0])
fig.savefig("_"+str(args[1]) + ".png", dpi=DPI, bbox_inches='tight')

#%%
# Plot EOF A/B
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1. / np.max(np.abs(EOF[:,eof1])[st:end]) * np.real(EOF[:,eof1])[st:end], color=color[0], linestyle=linestyle[0], linewidth=2, label="EOF 1")
ax.plot(t[st:end], 1. / np.max(np.abs(EOF[:,eof2])[st:end]) * np.real(EOF[:,eof2])[st:end], color=color[4], linestyle=linestyle[0], linewidth=2, label="EOF 2")
fig.savefig("_"+str(args[2]) + "_0_1.png", dpi=DPI, bbox_inches='tight')


#%%
# Plot EOF C/D
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("Samples [a.u.]")
ax.set_ylim([-1,1])
ax.plot(t[st:end], 1. / np.max(np.abs(EOF[:,eof3])[st:end]) * np.real(EOF[:,eof3])[st:end], color=color[0], linestyle=linestyle[0], linewidth=2, label="EOF 3")
ax.plot(t[st:end], 1. / np.max(np.abs(EOF[:,eof4])[st:end]) * np.real(EOF[:,eof4])[st:end], color=color[4], linestyle=linestyle[0], linewidth=2, label="EOF 4")
fig.savefig("_"+str(args[2]) + "_2_3.png", dpi=DPI, bbox_inches='tight')

#%%
# Plot Scatter EOF A/B
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("EOF " + str(eof1 + 1) + "[a.u.]")
ax.set_ylabel("EOF " + str(eof2 + 1) + "[a.u.]")
ax.scatter(1. / np.max(np.abs(EOF[:,eof1])[st:end]) * np.real(EOF[:,eof1])[st:end], 1. / np.max(np.abs(EOF[:,eof2])[st:end]) * np.real(EOF[:,eof2])[st:end], color=color[0], linestyle=linestyle[0], zorder=2, edgecolor=color[4], linewidth=0.5)
ax.plot(1. / np.max(np.abs(EOF[:,eof1])[st:end]) * np.real(EOF[:,eof1])[st:end], 1. / np.max(np.abs(EOF[:,eof2])[st:end]) * np.real(EOF[:,eof2])[st:end], color=color[4], linestyle=linestyle[0], zorder=1)
ax.axis("equal")
ax.set_ylim([-1,1])
fig.savefig("_"+str(args[2]) + "_scatter_0_1.png", dpi=DPI, bbox_inches='tight')

#%%
# Plot Scatter EOF C/D
rows=1
cols=1
fig, ax = plt.subplots(nrows=rows, ncols=cols, figsize=(800/DPI, 600/DPI))
ax.grid()
ax.set_xlabel("EOF " + str(eof3 + 1) + "[a.u.]")
ax.set_ylabel("EOF " + str(eof4 + 1) + "[a.u.]")
ax.scatter(1. / np.max(np.abs(EOF[:,eof3])[st:end]) * np.real(EOF[:,eof3])[st:end], 1. / np.max(np.abs(EOF[:,eof4])[st:end]) * np.real(EOF[:,eof4])[st:end], color=color[0], linestyle=linestyle[0], zorder=2, edgecolor=color[4], linewidth=0.5)
ax.plot(1. / np.max(np.abs(EOF[:,eof3])[st:end]) * np.real(EOF[:,eof3])[st:end], 1. / np.max(np.abs(EOF[:,eof4])[st:end]) * np.real(EOF[:,eof4])[st:end], color=color[4], linestyle=linestyle[0], zorder=1)
ax.axis("equal")
ax.set_ylim([-1,1])
fig.savefig("_"+str(args[2]) + "_scatter_2_3.png", dpi=DPI, bbox_inches='tight')
