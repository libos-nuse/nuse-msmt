#!/bin/sh

source ./netperf-common.sh

PREFIX=netperf6
TESTNAMES="TCP_STREAM"
DEST_ADDR="fc03::2"
SELF_ADDR="fc03::3"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24

SYS_MEM="1G"
TCP_WMEM="100000000"
QDISC_PARAMS="root|fq"
CC_ALGO="bbr"
OFFLOADS="0 d903" #disable, CSUM/TSO4/MRGRCVBUF/UFO + TSO6


# disable c-state
sudo tuned-adm profile latency-performance

LKLMUSL_NETPERF=/home/tazaki/work/netperf2/lklorig/src/
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/

TASKSET="taskset -c 0"
OUTPUT=`date -I`


mkdir -p ${OUTPUT}


run_netperf_turn()
{

test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7
offload=$8


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l 30 -- -K $cc -o $ex_arg"

# enable offload
if [ $offload != "0" ] ; then
sudo ethtool -K ens3f0 tso on gro on gso on rx on tx on
else
sudo ethtool -K ens3f0 tso off gro off gso off rx off tx off
fi
sudo tc qdisc del dev ens3f0 root fq pacing

echo "== lkl-hijack tap ($test-$num, $*)  =="

export LKL_HIJACK_OFFLOAD=0x$offload

LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap1 \
 LKL_HIJACK_NET_IPV6=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK6_LEN=64 \
 LKL_HIJACK_MEMSIZE=${mem} \
 LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem|4096 87380 ${tcp_wmem}" \
 LKL_HIJACK_NET_QDISC=${qdisc_params} \
${TASKSET} lkl-hijack.sh \
 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/${PREFIX}-$test-hijack-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc-off$offload.dat

echo "== native ($test-$num, $*)  =="
if [ $qdisc_params != "none" ] ; then
sudo tc qdisc replace dev ens3f0 root fq pacing
fi
sudo sysctl net.ipv4.tcp_wmem="4096 87380 $tcp_wmem"
${TASKSET} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
|& tee -a ${OUTPUT}/${PREFIX}-$test-native-$num-$mem-$tcp_wmem-$qdisc_params-$cc-off$offload.dat

}


rm -f ${OUTPUT}/${PREFIX}-*.dat

# for netperf (tx) tests
# for TCP_xx tests (netperf)
for num in `seq 1 ${TRIALS}`
do
for test in ${TESTNAMES}
do
for mem in ${SYS_MEM}
do
for tcp_wmem in ${TCP_WMEM}
do
for qdisc in ${QDISC_PARAMS}
do
for cc in ${CC_ALGO}
do
for off in ${OFFLOADS}
do

run_netperf_turn $test $num "" $mem $tcp_wmem $qdisc $cc $off

done
done
done
done
done
done
done



sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr-6.sh ${OUTPUT}
