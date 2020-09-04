#!/bin/bash

ZENODO_RECORD=3822451

# load SS data
for i in SS_Fig3-4 SS_SupFig5-6; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load SMS data
for i in SMS_Fig5 SMS_SupFig7; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

# load SoS data
for i in SoS_Vol1 SoS_Vol2 SoS_Vol3 SoS_Vol4 SoS_Vol5_Fig6 SoS_Vol6_SupFig8 SoS_Vol7_SupFig9 SoS_Vol8; do

	./load.sh ${ZENODO_RECORD} ${i} .
	tar -xzvf ${i}.tgz
done

