#!/bin/sh

sh `dirname ${BASH_SOURCE:-$0}`/netperf-bench.sh
sh `dirname ${BASH_SOURCE:-$0}`/netperf-bench-bbr.sh
sh `dirname ${BASH_SOURCE:-$0}`/netperf-bench-bbr-6.sh

sh `dirname ${BASH_SOURCE:-$0}`/nginx-bench.sh

