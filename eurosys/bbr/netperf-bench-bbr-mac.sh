#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"
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
NETPERF_DIR=/Users/tazaki/gitworks/netperf2/

OUTPUT="$SCRIPT_DIR/$(date "+%Y-%m-%d")"

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

netperf::noah() {
(
  test=$1
  num=$2
  ex_arg=$3
  mem=$4
  tcp_wmem=$5
  qdisc_params=$6
  cc=$7

  local netperf_args="-H $DEST_ADDR -t $test -- -K $cc -o $ex_arg"

  cd $NETPERF_DIR/noah
  echo "$(tput bold)== noah ($test-$num $*)  ==$(tput sgr0)"

  ulimit -n 1088

  noah "src/netperf" -- $netperf_args \
    2>&1 | tee "$OUTPUT/$PREFIX-$test-noah-$num-$cc.dat"

  cd $SCRIPT_DIR
)
}

netperf::lkl()
{
test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7

NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -K $cc -o $ex_arg"
echo "$(tput bold)== lkl ($test-$num $*)  ==$(tput sgr0)"


LKL_BOOT_CMDLINE="mem=${mem}" \
 LKL_OFFLOAD=1 \
 sudo rexec ${LKLMUSL_NETPERF}/netperf tap:tap0 config:lkl-mac-$qdisc_params.json \
 -- ${NETPERF_ARGS} \
  2>&1 | grep -v fallback | \
  tee -a ${OUTPUT}/${PREFIX}-$test-musl-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc.dat &
 sleep 1
 sudo ifconfig tap0 up
 sudo ifconfig bridge1 addm tap0
 fg

}



netperf::native()
{

test=$1
num=$2
ex_arg=$3
mem=$4
tcp_wmem=$5
qdisc_params=$6
cc=$7


NETPERF_ARGS="-H ${DEST_ADDR} -t $test -l10 -- -o $ex_arg"

echo "$(tput bold)== native ($test-$num $*)  ==$(tput sgr0)"
    /usr/local/bin/netperf ${NETPERF_ARGS} \
    2>&1 | tee -a ${OUTPUT}/${PREFIX}-$test-native-$num-$mem-$tcp_wmem-$cc.dat
}

netperf::docker() {
( 
  test=$1
  num=$2
  ex_arg=$3
  mem=$4
  tcp_wmem=$5
  qdisc_params=$6
  cc=$7

  local netperf_args="-H $DEST_ADDR -t $test -- -K $cc -o $ex_arg"
  
  echo "$(tput bold)== docker ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --rm \
   thehajime/byte-unixbench:latest \
   netperf $netperf_args 2>&1 \
  | tee "$OUTPUT/$PREFIX-$test-docker-$num-$cc.dat"
)
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

netperf::lkl $TESTNAMES $num "" $mem $tcp_wmem "root|fq" bbr
netperf::lkl $TESTNAMES $num "" $mem $tcp_wmem "nofq" cubic

netperf::noah $TESTNAMES $num "" $mem $tcp_wmem "" cubic
netperf::docker $TESTNAMES $num "" $mem $tcp_wmem "" cubic
netperf::native $TESTNAMES $num "" $mem $tcp_wmem "" cubic
echo ""

done
done
done


sh `dirname ${BASH_SOURCE:-$0}`/netperf-plot-bbr.sh ${OUTPUT}
