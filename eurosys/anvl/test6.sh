#!/bin/bash

source ../test-common.sh

# available TESTS="icmpv6 ipv6 ipv6-autoconfig ipv6-ndp ipv6-pmtu ipv6-rtralert ipv6cp ipv6ov4"
TESTS="ipv6 icmpv6 ipv6-ndp"

mkdir -p $OUTPUT

for test in $TESTS
do
  run_DUT
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -l medium -f anvl$test $test
done

bash  ${SCRIPT_DIR}/test6-parse.sh ${OUTPUT}
