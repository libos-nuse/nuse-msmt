#!/bin/bash

source ../test-common.sh


mkdir -p $OUTPUT

for test in $TESTS6
do
  run_DUT
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -l medium -f anvl$test $test
done

bash  ${SCRIPT_DIR}/test6-parse.sh ${OUTPUT}
