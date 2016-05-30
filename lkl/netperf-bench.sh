#!/bin/sh

TESTNAMES="TCP_STREAM TCP_RR UDP_STREAM omni"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.5"
TRIALS=1
LKLMUSL_NETPERF=/home/tazaki/work/netperf2/src/netperf
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/netperf
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/

OUTPUT=`date -I`

mkdir -p ${OUTPUT}

for num in `seq 1 ${TRIALS}`
do
for test in ${TESTNAMES}
do

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -- -o"

echo "== lkl-musl ($test-$num) =="
rexec ${LKLMUSL_NETPERF} tap:tap0 -- ${NETPERF_ARGS} |& tee ${OUTPUT}/netperf-$test-musl-$num.dat

echo "== lkl-hijack ($test-$num)  =="
LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap0 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
 lkl-hijack.sh \
 ${NATIVE_NETPERF} ${NETPERF_ARGS} \
 |& tee ${OUTPUT}/netperf-$test-hijack-$num.dat

echo "== native ($test-$num)  =="
${NATIVE_NETPERF} ${NETPERF_ARGS} |& tee ${OUTPUT}/netperf-$test-native-$num.dat

done
done

sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot.sh ${OUTPUT}
