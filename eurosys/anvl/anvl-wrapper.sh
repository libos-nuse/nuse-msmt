#!/bin/sh

#set -x
killall -9 -q `basename $4`

sed "s/fe80:$1::20/$2/" /home/tazaki/anvl-dut/lkl-linux/lkl-hijack.json > /tmp/tmp.json

if [ "$(basename $4)" = "ip" ] ; then
	WRAPPER=/home/tazaki/anvl-dut/lkl-linux/tools/lkl/bin/lkl-hijack.sh
	ARGS="$4 $5 $6"
fi

if [ "$(basename $4)" = "lwip-tap" ] ; then
	WRAPPER=$4
	ARGS='-HEC -i name=tap-lwip-0,addr=10.1.0.10,netmask=255.255.255.0 -i name=tap-lwip-1,addr=10.2.0.10,netmask=255.255.255.0'
fi

sleep 3
LKL_HIJACK_CONFIG_FILE=/tmp/tmp.json \
 $WRAPPER $ARGS > /dev/null &

sleep 5
