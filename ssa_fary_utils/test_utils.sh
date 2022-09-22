
export REPO_NAME=ssa-fary

if [ ! -d ${REFERENCE_ARCHIVE}/${REPO_NAME} ] ; then
	export REFERENCE_ARCHIVE=/home/ague/archive/reference_reconstructions
fi


COMPARE ()
{
	REF="$1"
	TEST="$2"
	TOL="$3"

	echo -n "$TEST: "
	OUT=$(bart nrmse -t"$TOL" "$REF" "$TEST")
	EX=$?
	RET=0
	if [ "$EX" -ne 0 ]; then
		echo -n "!!! "
		RET=1
	fi
	echo "$OUT"
	return $RET
}
