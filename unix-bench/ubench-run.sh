#!/bin/bash

TESTS="-q -c 1 -i 1 fstime-r fstime-w fstime fsdisk-r fsdisk-w fsdisk fsbuffer-r fsbuffer-w fsbuffer pipe"
CMD="./Run $TESTS"
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE:-$0})" ; pwd )
OUTPUT=$SCRIPT_DIR/output/$(date "+%Y%m%d-%H")
UBENCH_ROOT=/Users/tazaki/gitworks/byte-unixbench/UnixBench

rm -rf $OUTPUT
mkdir -p $OUTPUT
exec > >(tee "$OUTPUT/`basename $0`.log") 2>&1

cd $UBENCH_ROOT

export UB_RESULTDIR=$OUTPUT
export UB_OUTPUT_CSV=true

# disk image
dd if=/dev/zero of=testdir/disk.img bs=1024 count=20480
mkfs.ext4 -F testdir/disk.img
ln -fs testdir/disk.img

# ram disk
#diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nomount ram://51200`

# LKL
UB_OUTPUT_FILE_NAME=lkl UB_TMPDIR=/tmp/ UB_BINDIR=`pwd`/pgms-lkl PROGDIR=pgms-lkl CC=x86_64-rumprun-linux-cc $CMD

# native (macOS)
UB_OUTPUT_FILE_NAME=macos $CMD

# Docker
docker run --detach-keys="ctrl-q,ctrl-q" --rm -i -t \
  -v /Volumes/Extended/:/Users/tazaki \
  --privileged=True \
  -e UB_RESULTDIR=$UB_RESULTDIR \
  -e UB_OUTPUT_FILE_NAME=docker \
  -e UB_OUTPUT_CSV=true \
  -h `hostname` \
  thehajime/byte-unixbench:latest $CMD


## plot

$SCRIPT_DIR/ubench-plot.sh ${OUTPUT}
