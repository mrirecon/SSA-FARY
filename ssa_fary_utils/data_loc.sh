#!/bin/bash

set +u

REPO_NAME=SSA-FARY

if [ ! -d ${DATA_ARCHIVE}/${REPO_NAME} ] ; then
	FOLDER=$(dirname $(readlink -f $BASH_SOURCE))
	DATA_LOC=$(realpath "$FOLDER"/../data)
else
	DATA_LOC=${DATA_ARCHIVE}/${REPO_NAME}
fi

set -u
export DATA_LOC
