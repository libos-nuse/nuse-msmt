#!/bin/sh

#set -x
killall -9 -q ip

sed "s/fe80:$1::20/$2/" /home/tazaki/anvl-dut/lkl-linux/lkl-hijack.json > /tmp/tmp.json

sleep 3
LKL_HIJACK_CONFIG_FILE=/tmp/tmp.json \
 /home/tazaki/anvl-dut/lkl-linux/tools/lkl/bin/lkl-hijack.sh $4 $5 $6 > /dev/null &

sleep 1
