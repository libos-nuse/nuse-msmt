#!/bin/sh

bash `dirname ${BASH_SOURCE:-$0}`/netperf-bench.sh
bash `dirname ${BASH_SOURCE:-$0}`/netperf-bench-bbr.sh
bash `dirname ${BASH_SOURCE:-$0}`/netperf-bench-bbr-6.sh

bash ./hrtimer-bench.sh

sh `dirname ${BASH_SOURCE:-$0}`/nginx-bench.sh

