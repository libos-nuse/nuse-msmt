#!/bin/sh

sudo ip tuntap add tap-lwip-0 mode tap
sudo ip tuntap add tap-lwip-1 mode tap
sudo brctl addif br-anvl0 tap-lwip-0
sudo brctl addif br-anvl1 tap-lwip-1
sudo ifconfig tap-lwip-0 up
sudo ifconfig tap-lwip-1 up

killall -q -9 lwip-tap
./lwip-tap -HEC -i name=tap-lwip-0,addr=10.1.0.10,netmask=255.255.255.0 -i name=tap-lwip-1,addr=10.2.0.10,netmask=255.255.255.0
