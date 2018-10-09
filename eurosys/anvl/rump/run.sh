#!/bin/bash

sudo killall rump_allserver

#sudo ./buildrump.sh/rump/bin/rump_server -lrumpdev -lrumpdev_disk -lrumpvfs -lrumpfs_ffs -lrumpnet -lrumpnet_net -lrumpnet_netinet -lrumpnet_netinet6 -lrumpnet_tap -lrumpnet_virtif unix:///tmp/sock
sudo ./buildrump.sh/rump/bin/rump_allserver unix:///tmp/sock

sudo chmod 777 /tmp/sock

cd rumpctrl && bash ../rumpctl-cfg.sh

sudo ifconfig tun0 up
sudo ifconfig tun1 up
sudo brctl addif br-anvl1 tun0
sudo brctl addif br-anvl2 tun1
