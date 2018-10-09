#!/bin/bash

source ../test-common.sh
TESTS="arp ip icmp ipgw"
#TESTS="arp"

mkdir -p $OUTPUT

for test in $TESTS
do
  run_DUT
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -l medium -f anvl$test $test
done

bash  ${SCRIPT_DIR}/test4-parse.sh ${OUTPUT}
