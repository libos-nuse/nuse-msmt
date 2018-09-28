#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT="$(date "+%Y-%m-%d")"

TESTS="ipgw"

mkdir -p $OUTPUT

#exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

for test in $TESTS
do
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -f anvl$test $test
done
