#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

PREFIX=netperf-bbr
TESTNAMES="TCP_STREAM"
DEST_ADDR="2.1.1.1"
QDISC_PARAMS="root|fq"
TCP_WMEM="4194304 30000000 100000000 2000000000"
TCP_WMEM="100000000"
CC_ALGO="bbr cubic"
SYS_MEM="1G"
TRIALS=5
LKLMUSL_NETPERF=/home/tazaki/work/rumprun-packages/netperf/build/src/

OUTPUT="$(date -I)"

mkdir -p ${OUTPUT}
exec > >(tee ${OUTPUT}/$0.log) 2>&1

setup_lkl

# disable c-state
sudo tuned-adm profile latency-performance

# VIRTIO offloads, CSUM/TSO4/MRGRCVBUF/UFO
export LKL_HIJACK_OFFLOAD=0xc803



run_netperf_musl_turn()
{
test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7

mkfs.ext4 -q -F disk.img
NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -K $cc -o $ex_arg"
echo "== lkl-musl ($test-$num, $*)  =="


LKL_BOOT_CMDLINE="mem=${mem}" \
 LKL_OFFLOAD=1 \
 rexec ${LKLMUSL_NETPERF}/netperf tap:tap0 disk.img config:lkl.json \
 -- ${NETPERF_ARGS} \
 |& tee -a ${OUTPUT}/${PREFIX}-$test-musl-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat

}



run_netperf_turn()
{

test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -K $cc -o $ex_arg"

# enable offload
sudo ethtool -K ens3f0 tso on gro on gso on rx on tx on
sudo tc qdisc del dev ens3f0 root fq pacing

run_netperf_musl_turn $1 $2 "" $4 $5 $6 $7

echo "== native ($test-$num, $*)  =="
if [ $qdisc_params != "none" ] ; then
sudo tc qdisc replace dev ens3f0 root fq pacing
fi
sudo sysctl net.ipv4.tcp_wmem="4096 87380 $tcp_wmem"
#set -x
${TASKSET} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/${PREFIX}-$test-native-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat
#set +x
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

run_netperf_turn $test $num "" $mem $tcp_wmem $qdisc $cc
echo ""

done
done
done
done
done
done


sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr.sh ${OUTPUT}
