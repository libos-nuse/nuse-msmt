#!/bin/sh

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

PREFIX=netperf6
TESTNAMES="TCP_STREAM"
DEST_ADDR="fc03::2"
SELF_ADDR="fc03::3"
export FIXED_ADDRESS="$SELF_ADDR"
export FIXED_MASK=24

SYS_MEM="1G"
TCP_WMEM="100000000"
QDISC_PARAMS="none"
CC_ALGO="cubic"

OIF=br0

main() {
  # disable c-state
  sudo tuned-adm profile latency-performance

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat

  # for netperf (tx) tests
  # for TCP_xx tests (netperf)
  for num in $(seq 1 "$TRIALS"); do
    for test in $TESTNAMES; do
      for mem in $SYS_MEM; do
        for tcp_wmem in $TCP_WMEM; do
          for qdisc in $QDISC_PARAMS; do
            for cc in $CC_ALGO; do
              for off in $OFFLOADS; do
                netperf::run $test $num "" $mem $tcp_wmem $qdisc $cc $off
              done
            done
          done
        done
      done
    done
  done

  bash "$SCRIPT_DIR/netperf-plot-bbr-6.sh" "$OUTPUT"
}

netperf::run() {
  netperf::init "$@"
  netperf::lkl "$@"
  netperf::native "$@"
}

netperf::init() {
  local offload=$8

  # enable offload
  if [ $offload == "0" ] ; then
  sudo ethtool -K ${OIF} tso off gro off gso off rx off tx off
  sudo ethtool -K ens3f1 tso off gro off gso off rx off tx off
  elif [ $offload == "0003" ] ; then
  sudo ethtool -K ${OIF} tso off gro off gso off rx on tx on
  sudo ethtool -K ens3f1 tso off gro off gso off rx on tx on
  else
  sudo ethtool -K ${OIF} tso on gro on gso on rx on tx on
  sudo ethtool -K ens3f1 tso on gro on gso on rx on tx on
  fi
  sudo tc qdisc del dev ens3f0 root fq pacing
}

netperf::lkl() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local mem=$4
  local tcp_wmem=$5
  local qdisc_params=$6
  local cc=$7
  local offload=$8
  local netperf_args="-H $DEST_ADDR -t $test -l 30 -- -K $cc -o $ex_arg"

  setup_lkl

  echo "== lkl-hijack tap ($test-$num, $*)  =="
  export LKL_HIJACK_OFFLOAD="0x$offload"
  export LKL_HIJACK_NET_IFTYPE=tap
  export LKL_HIJACK_NET_IFPARAMS=tap0
  export LKL_HIJACK_NET_IPV6="$SELF_ADDR"
  export LKL_HIJACK_NET_NETMASK6_LEN=64
  export LKL_HIJACK_BOOT_CMDLINE="mem=$mem"
  export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 $tcp_wmem"
  export LKL_HIJACK_NET_QDISC="$qdisc_params"
  $TASKSET lkl-hijack.sh "$NATIVE_NETPERF/netperf" $netperf_args \
   |& tee -a "$OUTPUT/$PREFIX-$test-hijack-tap-$num-$mem-$tcp_wmem-$qdisc_params-$cc-off$offload.dat"

)
}

netperf::native() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local mem=$4
  local tcp_wmem=$5
  local qdisc_params=$6
  local cc=$7
  local offload=$8
  local netperf_args="-H $DEST_ADDR -t $test -l 30 -- -K $cc -o $ex_arg"

  echo "== native ($test-$num, $*)  =="
  if [[ $qdisc_params != "none" ]] ; then
    sudo tc qdisc replace dev ens3f0 root fq pacing
  fi
  sudo sysctl net.ipv4.tcp_wmem="4096 87380 $tcp_wmem"
  $TASKSET "$NATIVE_NETPERF/netperf" $NETPERF_ARGS \
    |& tee -a "$OUTPUT/$PREFIX-$test-native-$num-$mem-$tcp_wmem-$qdisc_params-$cc-off$offload.dat"
)
}

main
