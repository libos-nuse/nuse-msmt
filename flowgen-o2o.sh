#!/bin/sh

#sudo ethtool -A eth3 rx off tx off
#ssh -t 10.10.93.15 sudo ethtool -A eth5 rx off tx off

RX_HOST="10.10.93.15"
SRC_ADDR="172.16.1.4"
DST_ADDR="172.16.2.5"

ssh $RX_HOST "vnstat -l -i eth5 -tr 10 > flowgen-result.txt" &
sudo timeout 10 ./flowgen -s $SRC_ADDR -d $DST_ADDR -n 1 
ssh -t $RX_HOST pkill vnstat
scp $RX_HOST:flowgen-result.txt ./
cat flowgen-result.txt
