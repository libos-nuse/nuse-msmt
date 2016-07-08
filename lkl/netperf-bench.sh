#!/bin/sh

TESTNAMES="TCP_STREAM"
#TESTNAMES=""
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
HOST_ADDR="1.1.1.1"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24
TRIALS=3

# disable offload
sudo ethtool -K br0 tso off gro off gso off rx off tx off
sudo ethtool -K ens3f1 tso off gro off gso off rx off tx off

# disable c-state
sudo tuned-adm profile latency-performance

LKLMUSL_NETPERF=/home/tazaki/work/netperf2/lklorig/src/
LKLMUSL_NETPERF_skb_pre=/home/tazaki/work/netperf2/lkl/src/
LKLMUSL_NETPERF_mmsg=/home/tazaki/work/netperf2/sendmmsg/src/
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/
NATIVE_NETPERF_mmsg=/home/tazaki/work/netperf2/native-mmsg/src/
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
taskset 3 rexec ${LKLMUSL_NETPERF}/netperf tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-$num.dat

echo "== lkl-musl (skb pre allocation) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_skb_pre}/netperf tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-skbpre-$num.dat

echo "== lkl-musl (sendmmsg) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_mmsg}/netperf tap:tap0 -- ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-musl-sendmmsg-$num.dat

echo "== lkl-hijack tap ($test-$num)  =="
LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap0 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
taskset 3 lkl-hijack.sh \
 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/netperf-$test-hijack-tap-$num.dat

echo "== lkl-hijack raw ($test-$num)  =="
sudo LKL_HIJACK_NET_IFTYPE=raw \
 LKL_HIJACK_NET_IFPARAMS=ens3f1 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
taskset 3 /home/tazaki/work/lkl-linux/tools/lkl/bin/lkl-hijack.sh \
 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/netperf-$test-hijack-raw-$num.dat

echo "== native ($test-$num)  =="
taskset 3 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-$num.dat

echo "== native (sendmmsg) ($test-$num)  =="
taskset 3 ${NATIVE_NETPERF_mmsg}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-mmsg-$num.dat


}


run_netserver_turn()
{
sudo pkill netserver

test=$1
num=$2
ex_arg=$3

NETSERVER_ARGS="-D -f"
NETPERF_ARGS="-H ${FIXED_ADDRESS} -t $test -- -o $ex_arg"

echo "== lkl-musl ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF}/netserver tap:tap0 -- ${NETSERVER_ARGS} &
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-musl-$num.dat

pkill netserver

echo "== lkl-musl (skb pre allocation) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_skb_pre}/netserver tap:tap0 -- ${NETSERVER_ARGS} &
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-musl-skbpre-$num.dat
pkill netserver

echo "== lkl-musl (sendmmsg) ($test-$num) =="
taskset 3 rexec ${LKLMUSL_NETPERF_mmsg}/netserver tap:tap0 -- ${NETSERVER_ARGS}&
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-musl-sendmmsg-$num.dat
pkill netserver

echo "== lkl-hijack tap ($test-$num)  =="
LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap0 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
taskset 3 lkl-hijack.sh \
 ${NATIVE_NETPERF}/netserver ${NETSERVER_ARGS} &
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-hijack-tap-$num.dat
pkill netserver

echo "== lkl-hijack raw ($test-$num)  =="
sudo LKL_HIJACK_NET_IFTYPE=raw \
 LKL_HIJACK_NET_IFPARAMS=ens3f1 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
taskset 3 /home/tazaki/work/lkl-linux/tools/lkl/bin/lkl-hijack.sh \
 ${NATIVE_NETPERF}/netserver ${NETSERVER_ARGS} &
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-hijack-raw-$num.dat
sudo pkill netserver

echo "== native ($test-$num)  =="
NETPERF_ARGS="-H ${HOST_ADDR} -t $test -- -o $ex_arg"
taskset 3 ${NATIVE_NETPERF}/netserver ${NETSERVER_ARGS} &
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-native-$num.dat
pkill netserver

echo "== native (sendmmsg) ($test-$num)  =="
taskset 3 ${NATIVE_NETPERF_mmsg}/netserver ${NETSERVER_ARGS} &
ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netserver-$test-native-mmsg-$num.dat
pkill netserver


}


rm -f ${OUTPUT}/netperf-*.dat
rm -f ${OUTPUT}/netserver-*.dat

# for netserver (rx) tests
# for TCP_xx tests (netperf)
for num in `seq 1 ${TRIALS}`
do
for test in ${TESTNAMES}
do

run_netserver_turn $test $num

done
done

#exit

# UDP_STREAM with different packet size

for num in `seq 1 ${TRIALS}`
do
for size in 1 64 128 256 512 1024 1500 2048 65507
do

run_netserver_turn TCP_RR $num " -r $size,$size"

# XXX: temporary disabled
#run_netserver_turn UDP_STREAM $num "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"

done
done


# for netperf (tx) tests
# for TCP_xx tests (netperf)
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
for size in 1 64 128 256 512 1024 1500 2048 65507
do

run_netperf_turn TCP_RR $num " -r $size,$size"

run_netperf_turn UDP_STREAM $num "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"

done
done



sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot.sh ${OUTPUT}
sh `dirname ${BASH_SOURCE:-$0}`/netserver-plot.sh ${OUTPUT}
