#!/bin/bash

# available TESTS="icmpv6 ipv6 ipv6-autoconfig ipv6-ndp ipv6-pmtu ipv6-rtralert ipv6cp ipv6ov4"
TESTS="ipv6 icmpv6"


for test in $TESTS
do
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $test-out.log -f anvl$test $test
done
