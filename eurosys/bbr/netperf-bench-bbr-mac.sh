#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

PREFIX=netperf-bbr
TESTNAMES="TCP_STREAM"
DEST_ADDR="2.1.1.2"
QDISC_PARAMS="root|fq"
TCP_WMEM="4194304 30000000 100000000 2000000000"
TCP_WMEM="100000000"
CC_ALGO="bbr cubic"
SYS_MEM="1G"
TRIALS=5
LKLMUSL_NETPERF=$HOME/tmp/bbr/rootfs/bin/

OUTPUT="$(date "+%Y-%m-%d")"

mkdir -p ${OUTPUT}
exec > >(tee ${OUTPUT}/$0.log) 2>&1

set -m
setup_lkl

DOCKER_IMG_VERSION=0.1
export PATH=$HOME/tmp/bbr/rootfs/bin:$HOME/tmp/bbr/rootfs/sbin:${PATH}

prepare_image() {
    mkdir -p $HOME/tmp/bbr/rootfs
    # get script from moby
    curl https://raw.githubusercontent.com/moby/moby/master/contrib/download-frozen-image-v2.sh \
	-o /tmp/download-frozen-image-v2.sh

    # get image runu-base
    mkdir -p /tmp/bbr
    bash /tmp/download-frozen-image-v2.sh /tmp/bbr/ thehajime/runu-base:$DOCKER_IMG_VERSION-osx

    # extract images from layers
    for layer in `find /tmp/bbr -name layer.tar`
    do
	tar xvfz $layer -C $HOME/tmp/bbr/rootfs
    done

}


run_netperf_lkl_turn()
{
test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -K $cc -o $ex_arg"
echo "== lkl ($test-$num, $*)  =="


LKL_BOOT_CMDLINE="mem=${mem}" \
 LKL_OFFLOAD=1 \
 sudo rexec ${LKLMUSL_NETPERF}/netperf tap:tap0 config:lkl-mac.json \
 -- ${NETPERF_ARGS} \
  2>&1 | grep -v fallback | \
  tee -a ${OUTPUT}/${PREFIX}-$test-musl-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat &
 sleep 1
 sudo ifconfig tap0 up
 sudo ifconfig bridge1 addm tap0
 fg

}



run_netperf_native_turn()
{

test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -o $ex_arg"

echo "== native ($test-$num, $*)  =="
    /usr/local/bin/netperf ${NETPERF_ARGS} \
    2>&1 | tee -a ${OUTPUT}/${PREFIX}-$test-native-$num-$mem-$tcp_wmem-$cc.dat
}


rm -f ${OUTPUT}/${PREFIX}-*.dat
prepare_image

# for netperf (tx) tests
# for TCP_xx tests (netperf)
for num in `seq 1 ${TRIALS}`
do
for mem in ${SYS_MEM}
do
for tcp_wmem in ${TCP_WMEM}
do

run_netperf_lkl_turn $TESTNAMES $num "" $mem $tcp_wmem "root|fq" bbr
run_netperf_lkl_turn $TESTNAMES $num "" $mem $tcp_wmem "" cubic

run_netperf_native_turn $TESTNAMES $num "" $mem $tcp_wmem "" cubic
echo ""

done
done
done


sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr.sh ${OUTPUT}
