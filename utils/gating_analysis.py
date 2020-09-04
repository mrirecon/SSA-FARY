#!/usr/bin/env python3
# Author:Sebastian Rosenzweig, 2020
# sebastian.rosenzweig@med.uni-goettingen.de
# Analyze ECG and SSA-FARY gating
# Rosenzweig, S. et al. "Cardiac and Respiratory Self-Gating in Radial MRI using an Adapted Singular Spectrum Analysis (SSA-FARY)", IEEE TMI (2020)

import numpy as np
import sys
import os
sys.path.insert(0, os.path.join(os.environ['TOOLBOX_PATH'], 'python'))
from cfl import readcfl
from cfl import writecfl
from detect_peaks import detect_peaks  # by Marcos Duarte. MIT licence

# Option Parsing
from optparse import OptionParser
parser = OptionParser(description="Remove Oscillations.", usage="usage: %prog <kDC> <dst>")
parser.add_option("-p", dest="pmu_rm",
          help="Remove pmu element. %default", default=-1)
parser.add_option("--p2", dest="pmu_rm2",
          help="Remove pmu element. %default", default=-1)
parser.add_option("-s", dest="ssa_rm",
          help="Remove ssa-fary element. %default", default=-1)
parser.add_option("--s2", dest="ssa_rm2",
          help="Remove ssa-fary element. %default", default=-1)

(options, args) = parser.parse_args()

pmu_rm = int(options.pmu_rm)
pmu_rm2 = int(options.pmu_rm2)
ssa_rm = int(options.ssa_rm)
ssa_rm2 = int(options.ssa_rm2)

######### EOF
n_partitions = 8 # Undersampling scheme: 6 partitions from AC and 2 partitions from periphery

eof_raw = np.squeeze(readcfl("card"))
c1=0
c2=1
eof = np.repeat(eof_raw, n_partitions, axis=0) # repeat samples to align with pmu
angles = np.arctan2(np.real(eof[:,c2]),np.real(eof[:,c1]))


# Count zero-passes
counts = 0
for i in range(angles.shape[0] - 1):
    if ((angles[i] * angles[i+1]) < 0 and angles[i + 1] < 0):
        counts += 1
ssa_peaks = np.zeros(shape=(counts))

# Find zero-passes
counts = 0
for i in range(angles.shape[0] - 1):
    if ((angles[i] * angles[i+1]) < 0 and angles[i + 1] < 0):
        ssa_peaks[counts] = i
        counts += 1
  
#%%
n_tot = eof.shape[0]
min_peak_dist = (1000 / n_partitions) * 0.7

#%%
######### PMU
pmu_raw = np.squeeze(readcfl("data/pmu")) # load and extract AC region
_tmp = np.transpose(pmu_raw, (2,0,1))
pmu_1d = np.reshape(_tmp, (np.product(_tmp.shape),), order="C")

# Remove undersampled partitions
mask = np.zeros_like(pmu_1d)
ss = pmu_raw.shape[0]
pp = pmu_raw.shape[1]
ff = pmu_raw.shape[2]

typ = 0
for f in range(ff):
    for s in range(ss):    
        for p in range(pp):
            if (f * pp * ss + ss * pp + pp > mask.shape[0]):
                break
            if ( (p < 4 or p > 9) and (p != typ and p != 10 + typ) ):
                mask[f * ss * pp + s * pp + p] = 1
    if (typ < 3):
        typ +=1
    else: 
        typ = 0
mask[0] = 1 # Sequence implementation 

mask2 = np.nonzero(mask)
pmu_1d_usamp = np.delete(pmu_1d, mask2)
pmu = pmu_1d_usamp[:n_tot]

# Find peaks
pmu_peaks = detect_peaks(np.real(pmu), mpd=min_peak_dist, show=False)

#%%
# Eventually remove border elements
if (pmu_rm == -1):
	pmu_remove = []
elif (pmu_rm2 == -1):
	pmu_remove = [pmu_rm]
else:
	pmu_remove = [pmu_rm,pmu_rm2]
if (ssa_rm == -1):
	ssa_remove = []
elif (ssa_rm2 == -1):
	ssa_remove = [ssa_rm]
else:
	ssa_remove = [ssa_rm,ssa_rm2]

ssa_peaks_mod = np.delete(ssa_peaks, ssa_remove)
pmu_peaks_mod = np.delete(pmu_peaks, pmu_remove)

# Heart beat characteristics
heartbeat_avgf = np.mean(1 / ((pmu_peaks_mod[1:] - pmu_peaks_mod[:-1]) * 3.8e-3) ) # [Hz]
heartbeat_stdf = np.std(1 / ((pmu_peaks_mod[1:] - pmu_peaks_mod[:-1]) * 3.8e-3) ) # [Hz]

heartbeat_avgferr = heartbeat_stdf / np.sqrt(len(pmu_peaks_mod[1:]))
heartbeat_stderr = heartbeat_stdf  / np.sqrt(2 * (len(pmu_peaks_mod[1:]) - 1 ))
#%%

diff = pmu_peaks_mod - ssa_peaks_mod
delta = np.mean(diff)
ssa_peaks_shift = ssa_peaks_mod + delta # correct systematic (constant) shift
stdv = np.std(pmu_peaks_mod - ssa_peaks_shift)
stdv_err = stdv / np.sqrt(2 * (len(pmu_peaks_mod) - 1))
print(len(pmu_peaks_mod))

print("SSA-FARY/ECG sigma ", stdv)
print("SSA-FARY/ECG sigma_err ", stdv_err)

print("SSA-FARY/ECG sigma [ms]", stdv * 3.8)
print("SSA-FARY/ECG sigma_err [ms]", stdv_err * 3.8)

print("Cardiac frequency avg [Hz]", heartbeat_avgf)
print("Cardiac frequency avgerr [Hz]", heartbeat_avgferr)
print("Cardiac frequency sigma [Hz]", heartbeat_stdf)
print("Cardiac frequency sigma_err [Hz]", heartbeat_stderr)
