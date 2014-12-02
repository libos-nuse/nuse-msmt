#!/bin/sh

#sudo ip route add 172.16.2.0/24 via 172.16.1.2

RX_HOST="10.10.93.15"
SRC_ADDR="172.16.1.4"
DST_ADDR="172.16.2.5"

#timeout 11 ping -d 172.16.2.5 > ping-result.txt
sudo NUSECONF=./nuse.conf timeout 11 ./nuse ping -d 172.16.2.5 > ping-result.txt
cat ping-result.txt
