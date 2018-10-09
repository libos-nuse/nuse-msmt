#!/bin/bash

. ./rumpctrl.sh -u /tmp/sock

ifconfig virt0 create
ifconfig virt1 create
ifconfig virt0 10.1.0.80 netmask 255.255.255.0
ifconfig virt1 10.2.0.80 netmask 255.255.255.0
ifconfig virt0 up
ifconfig virt1 up

sysctl -w net.inet6.ip6.forwarding=1
