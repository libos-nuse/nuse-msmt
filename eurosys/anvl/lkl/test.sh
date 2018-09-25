#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT="$(date "+%Y-%m-%d")"

# available TESTS="icmpv6 ipv6 ipv6-autoconfig ipv6-ndp ipv6-pmtu ipv6-rtralert ipv6cp ipv6ov4"
TESTS="anvlipv6 icmpv6 ipv6-ndp"

mkdir -p $OUTPUT

#exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

for test in $TESTS
do
  sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file $OUTPUT/$test-out.log \
   -f anvl$test $test
done
