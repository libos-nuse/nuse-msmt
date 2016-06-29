#!/bin/sh

TESTNAMES="TCP_STREAM"
#TESTNAMES=""
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.5"
export FIXED_ADDRESS=1.1.1.3
export FIXED_MASK=24
TRIALS=1

# disable offload
sudo ethtool -K br0 tso off gso off rx off tx off

LKLMUSL_NETPERF=/home/tazaki/work/netperf2/lkl/orig/netperf
LKLMUSL_NETPERF_skb_pre=/home/tazaki/work/netperf2/lkl/src/netperf
LKLMUSL_NETPERF_mmsg=/home/tazaki/work/netperf2/sendmmsg/src/netperf
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/netperf
NATIVE_NETPERF_mmsg=/home/tazaki/work/netperf2/native-mmsg/src/netperf
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/

OUTPUT=`date -I`

mkdir -p ${OUTPUT}


run_netperf_turn()
{

test=$1
num=$2
ex_arg=$3

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -- -o $ex_arg"

echo "== lkl-musl ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF} tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-$num.dat

echo "== lkl-musl (skb pre allocation) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_skb_pre} tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-skbpre-$num.dat

echo "== lkl-musl (sendmmsg) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_mmsg} tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-sendmmsg-$num.dat

echo "== lkl-hijack ($test-$num)  =="
LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap0 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
taskset 3 lkl-hijack.sh \
 ${NATIVE_NETPERF} ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/netperf-$test-hijack-$num.dat

echo "== native ($test-$num)  =="
taskset 3 ${NATIVE_NETPERF} ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-$num.dat

echo "== native (sendmmsg) ($test-$num)  =="
taskset 3 ${NATIVE_NETPERF_mmsg} ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-mmsg-$num.dat


}


rm -f ${OUTPUT}/netperf-*.dat

# for TCP_xx tests
for num in `seq 1 ${TRIALS}`
do
for test in ${TESTNAMES}
do

run_netperf_turn $test $num

done
done

# UDP_STREAM with different packet size

for num in `seq 1 ${TRIALS}`
do
for size in 64 128 256 512 1024 1500 2048 65507
do

run_netperf_turn TCP_RR $num " -r $size,$size"

run_netperf_turn UDP_STREAM $num "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"

done
done



sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot.sh ${OUTPUT}
