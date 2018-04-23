#!/bin/bash

OUTPUT=$1
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE:-$0})" ; pwd )

if [ -z $OUTPUT ] ; then
	echo "missing output dir"
	exit
fi

# data convertion
LKL=$(grep peak ${OUTPUT}/mem-lkl.dat | awk '{print $4}')
NOAH=$(grep peak ${OUTPUT}/mem-noah.dat | awk '{print $4}' | head -1)
NOAH_VMM=$(grep peak ${OUTPUT}/mem-noah.dat | awk '{print $4}' | tail -1)
MACOS=$(grep peak ${OUTPUT}/mem-native.dat | awk '{print $4}')
DOCKER=$(grep peak ${OUTPUT}/mem-docker.dat | awk '{print $4}' | head -1)
DOCKER_VMM=$(grep peak ${OUTPUT}/mem-docker.dat | awk '{print $4}' | tail -1)

echo "$LKL &  $NOAH  &  $DOCKER &  $MACOS \\\\" > $OUTPUT/mem-tbl.dat
echo " &  ($NOAH_VMM) &  ($DOCKER_VMM) & \\\\" >> $OUTPUT/mem-tbl.dat
