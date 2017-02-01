#!/bin/sh

source ./netperf-common.sh

PREFIX=netperf-bbr
TESTNAMES="TCP_STREAM"
DEST_ADDR="2.1.1.2"
SELF_ADDR="2.1.1.3"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24
QDISC_PARAMS="root|fq"


# disable c-state
sudo tuned-adm profile latency-performance

# VIRTIO offloads, CSUM/TSO4/MRGRCVBUF/UFO
export LKL_HIJACK_OFFLOAD=0xc803

mkdir -p ${OUTPUT}


run_netperf_hijack_turn()
{
test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l 30 -- -K $cc -o $ex_arg"

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
 |& tee -a ${OUTPUT}/${PREFIX}-$test-hijack-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat
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


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l 30 -- -K $cc -o $ex_arg"

# enable offload
sudo ethtool -K ens3f0 tso on gro on gso on rx on tx on
sudo tc qdisc del dev ens3f0 root fq pacing

run_netperf_hijack_turn $1 $2 "" $4 $5 $6 $7

# echo "== lkl-musl tap ($test-$num, $*)  =="
# 
# LKL_MEMSIZE=${mem} \
#  LKL_SYSCTL="net.ipv4.tcp_wmem|4096 87380 ${tcp_wmem}" \
#  LKL_NET_QDISC=${qdisc_params} \
#  rexec ${LKLMUSL_NETPERF}/netperf tap:tap1 -- ${NETPERF_ARGS} \
#  |& tee -a ${OUTPUT}/${PREFIX}-$test-musl-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat

echo "== native ($test-$num, $*)  =="
if [ $qdisc_params != "none" ] ; then
sudo tc qdisc replace dev ens3f0 root fq pacing
fi
sudo sysctl net.ipv4.tcp_wmem="4096 87380 $tcp_wmem"
${TASKSET} ${NATIVE_NETPERF}/netperf ${NETPERF_ARGS} |& tee -a ${OUTPUT}/${PREFIX}-$test-native-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat
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

for inum in `seq 1 ${TRIALS}`
do

PREFIX="netperf-bbr-nohrt"
(cd ${LKL_DIR}/tools/lkl;ln -f -s liblkl-hijack-nohrt.so liblkl-hijack.so)
#run_netperf_hijack_turn TCP_STREAM nohrt-nofq-$inum "" 1G 2000000000 none bbr
run_netperf_hijack_turn TCP_STREAM nohrt-fq-$inum "" 1G 1000000000 "root|fq" bbr
(cd ${LKL_DIR}/tools/lkl;ln -f -s liblkl-hijack-hrt.so liblkl-hijack.so)
run_netperf_hijack_turn TCP_STREAM hrt-nofq-$inum "" 1G 1000000000 none bbr
#run_netperf_hijack_turn TCP_STREAM hrt-fq-$inum "" 1G 1000000000 "root|fq" bbr

done

sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr.sh ${OUTPUT}
