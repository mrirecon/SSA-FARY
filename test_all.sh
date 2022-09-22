#!/bin/bash
set -uo pipefail

ERR=0


for d in Fig{2,3-4,5,6} SupFig{1,2,3,4,5-6,7,8,9} Vol{1,2,3,4}
do
	cd $d
	echo $d
	bash test.sh
	EX=$?
	ERR=$((ERR + EX))
	cd ..
	echo "--------"
done
echo "--------------------------------"
echo "$ERR error(s)."
exit $ERR

