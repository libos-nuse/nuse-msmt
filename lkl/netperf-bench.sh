#!/bin/sh

source ./netperf-common.sh

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24
OIF=ens3f1
OIF=br0

export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem|4096 87380 100000000"
export LKL_HIJACK_MEMSIZE=1G

# enable offload

# disable c-state
sudo tuned-adm profile latency-performance

LKLMUSL_NETPERF=/home/tazaki/work/netperf2/lklorig/src/
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/

TASKSET="taskset -c 0"
OUTPUT=`date -I`

# VIRTIO offloads, CSUM/TSO4/MRGRCVBUF/UFO
export LKL_HIJACK_OFFLOAD=0xc803

mkdir -p ${OUTPUT}


run_netperf_turn()
{

test=$1
num=$2
psize=$3
ex_arg=$4

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -- -o $ex_arg"

sudo ethtool -K ${OIF} tso on gro on gso on rx on tx on

echo "== lkl-hijack tap ($test-$num $*)  =="
LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap0 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
${TASKSET} lkl-hijack.sh \
 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/${PREFIX}-$test-hijack-tap-ps$size-$num.dat


echo "== native ($test-$num $*)  =="
NETPERF_ARGS="-H ${DEST_ADDR} -t $test -- -o $ex_arg"
${TASKSET} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/${PREFIX}-$test-native-ps$size-$num.dat

#echo "== native (sendmmsg) ($test-$num)  =="
#${TASKSET} ${NATIVE_NETPERF_mmsg}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-mmsg-$num.dat
#

}


rm -f ${OUTPUT}/${PREFIX}-*.dat


# for netperf tests
for num in `seq 1 ${TRIALS}`
do
for size in ${PSIZES}
do

for test in ${TESTNAMES}
do

run_netperf_turn $test $num $size "-m $size,$size"

done

run_netperf_turn TCP_RR $num $size " -r $size,$size"
run_netperf_turn UDP_STREAM $num $size "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"
done
done


sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot.sh ${OUTPUT} tx
sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot.sh ${OUTPUT} rx
