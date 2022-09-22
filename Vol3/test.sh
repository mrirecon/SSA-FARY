#!/bin/bash
set -B

source ../ssa_fary_utils/test_utils.sh

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

ERR=0

for f in pics_rs S_91
do
	F=${f}
	COMPARE ${REFERENCE_ARCHIVE}/${REPO_NAME}/Vol3/${F} $F 0.005
	EX=$?
	ERR=$((ERR + EX))
done
echo "$ERR error(s)."
exit $ERR
