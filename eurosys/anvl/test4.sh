#!/bin/bash

#set -x

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

mkdir -p $OUTPUT

for test in $TESTS4
do
  run_DUT
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -l low -f anvl$test $test
done

### XXX
ssh ${DUT_HOST} "sudo systemctl start firewalld.service"
bash  ${SCRIPT_DIR}/test4-parse.sh ${OUTPUT}
