#!/bin/bash
set -B

source ../ssa_fary_utils/test_utils.sh

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
        echo "\$TOOLBOX_PATH is not set correctly!" >&2
        exit 1
fi

ERR=0

for f in S_*.cfl
do
	F=$(basename $f .cfl)
	COMPARE ${REFERENCE_ARCHIVE}/${REPO_NAME}/Fig2/${F} $F 0.003
	EX=$?
	ERR=$((ERR + EX))
done
echo "$ERR error(s)."
exit $ERR
