#!/bin/bash

# Seastar always uses 12:23:34:56:67:78 for MAC address of tap.
# So, we can specify its IP address and MTU by DHCPD
sudo killall -q -9 httpd
sudo ./build/release/apps/httpd/httpd --network-stack native --tap-device tap-ss-0 --dhcp 1
