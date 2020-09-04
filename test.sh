#!/bin/bash
set -e

REF=$ARCHIVE/reference_reconstructions/ssa-fary/

if [ ! -d $REF ] ; then
	
	echo "\$ARCHIVE variable is not set!" >&1
	exit 1
fi

#--- BART ---
export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi


bart nrmse -t 0.00001   {.,$REF}/Fig3-4/SS
bart nrmse -t 0.00001   {.,$REF}/Fig5/SMS3
bart nrmse -t 0.00005   {.,$REF}/Fig6/pics_rs
bart nrmse -t 0.00001   {.,$REF}/SupFig4/rss
bart nrmse -t 0.00005   {.,$REF}/SupFig5-6/SS
bart nrmse -t 0.00001   {.,$REF}/SupFig7/SMS3
bart nrmse -t 0.0015    {.,$REF}/SupFig8/pics_rs
bart nrmse -t 0.00005   {.,$REF}/SupFig9/pics_rs
bart nrmse -t 0.00001   {.,$REF}/Vol1/pics_rs
bart nrmse -t 0.00005   {.,$REF}/Vol2/pics_rs
bart nrmse -t 0.0015    {.,$REF}/Vol3/pics_rs
bart nrmse -t 0.00005   {.,$REF}/Vol4/pics_rs

bart nrmse -t 0.0000001 {.,$REF}/Fig2/EOF_noise
bart nrmse -t 0.0000001 {.,$REF}/Fig2/EOF_spell
bart nrmse -t 0.0000001 {.,$REF}/Fig2/EOF_sin
bart nrmse -t 0.0000001 {.,$REF}/Fig2/EOF_trend
bart nrmse -t 0.0000001 {.,$REF}/SupFig1/EOF_noise
bart nrmse -t 0.0000001 {.,$REF}/SupFig1/EOF_spell
bart nrmse -t 0.0000001 {.,$REF}/SupFig1/EOF_sin
bart nrmse -t 0.0000001 {.,$REF}/SupFig1/EOF_trend
bart nrmse -t 0.0000001 {.,$REF}/SupFig2/EOF_noise
bart nrmse -t 0.0000001 {.,$REF}/SupFig2/EOF_spell
bart nrmse -t 0.0000001 {.,$REF}/SupFig2/EOF_sin
bart nrmse -t 0.0000001 {.,$REF}/SupFig2/EOF_trend
bart nrmse -t 0.0000001 {.,$REF}/SupFig3/EOF_noise
bart nrmse -t 0.0000001 {.,$REF}/SupFig3/EOF_spell
bart nrmse -t 0.0000001 {.,$REF}/SupFig3/EOF_sin
bart nrmse -t 0.0000001 {.,$REF}/SupFig3/EOF_trend
