#!/bin/bash
set -B

source ../ssa_fary_utils/test_utils.sh

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

ERR=0

for f in SS S_PCA
do
	F=${f}
	COMPARE ${REFERENCE_ARCHIVE}/${REPO_NAME}/Fig3-4/${F} $F 0.003
	EX=$?
	ERR=$((ERR + EX))
done

bart extract 1 0 2 PCA tmp_PCA.ra
bart extract 1 0 2 ${REFERENCE_ARCHIVE}/${REPO_NAME}/Fig3-4/PCA tmp_ref_PCA.ra

COMPARE tmp_ref_PCA.ra tmp_PCA.ra 0.003
EX=$?
ERR=$((ERR + EX))

rm tmp_PCA.ra tmp_ref_PCA.ra


echo "$ERR error(s)."
exit $ERR
