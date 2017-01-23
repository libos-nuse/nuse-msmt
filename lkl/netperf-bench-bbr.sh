#!/bin/sh

TESTNAMES="TCP_STREAM"
DEST_ADDR="2.1.1.2"
SELF_ADDR="2.1.1.3"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24
TRIALS=3
PSIZES="1 64 128 256 512 1024 1500 2048 65507"
SYS_MEM="512M 1G"
TCP_WMEM="4194304 1000000000 2147483647"
QDISC_PARAMS="root|fq"
CC_ALGO="bbr cubic"


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
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l 30 -- -K $cc -o $ex_arg"

# enable offload
sudo ethtool -K ens3f0 tso on gro on gso on rx on tx on
sudo tc qdisc del dev ens3f0 root fq pacing
echo "== lkl-hijack tap ($test-$num, $*)  =="

LKL_HIJACK_NET_IFTYPE=tap \
 LKL_HIJACK_NET_IFPARAMS=tap1 \
 LKL_HIJACK_NET_IP=${SELF_ADDR} \
 LKL_HIJACK_NET_NETMASK_LEN=24 \
 LKL_HIJACK_MEMSIZE=${mem} \
 LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem|4096 87380 ${tcp_wmem}" \
 LKL_HIJACK_NET_QDISC=${qdisc_params} \
${TASKSET} lkl-hijack.sh \
 ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/netperf-$test-hijack-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat

echo "== native ($test-$num, $*)  =="
sudo tc qdisc replace dev ens3f0 root fq pacing
sudo sysctl net.ipv4.tcp_wmem="4096 87380 $tcp_wmem"
${TASKSET} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/netperf-$test-native-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat
}


rm -f ${OUTPUT}/netperf-*.dat

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

run_netperf_turn $test $num "" $mem $tcp_wmem $qdisc $cc

done
done
done
done
done
done



sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr.sh ${OUTPUT}
