#!/bin/sh

sh `dirname ${BASH_SOURCE:-$0}`/netperf-bench.sh ${OUTPUT}
sh `dirname ${BASH_SOURCE:-$0}`/nginx-bench.sh ${OUTPUT}

