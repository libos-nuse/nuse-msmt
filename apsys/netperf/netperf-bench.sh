#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

# macos has different syntax
OUTPUT=$SCRIPT_DIR/$(date "+%Y-%m-%d")

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="3.3.3.2"
SELF_ADDR="3.3.3.3"
OIF=br0

NETPERF_DIR=/Users/tazaki/gitworks/netperf2/
#TMP variable
export PATH=~/bin:~/gitworks/frankenlibc/rump/bin:${PATH}

main() {
  initialize

  # for netperf tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PSIZES; do
      for test in $TESTNAMES; do
        netperf::run $test $num $size "-m $size,$size"
      done

      netperf::run TCP_RR $num $size " -r $size,$size"
      netperf::run UDP_STREAM $num $size "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"
    done
  done

  bash "$SCRIPT_DIR/netperf-plot.sh" "$OUTPUT" tx
  bash "$SCRIPT_DIR/netperf-plot.sh" "$OUTPUT" rx
}

initialize() {
  export FIXED_ADDRESS=${SELF_ADDR}
  export FIXED_MASK=24

  export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_HIJACK_BOOT_CMDLINE="mem=1G"

  export LKL_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_BOOT_CMDLINE="mem=1G"

  # VIRTIO offloads, CSUM/TSO4/MRGRCVBUF/UFO
  export LKL_HIJACK_OFFLOAD=0xc803

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

netperf::run() {

  netperf::lkl "$@"
  netperf::noah "$@"
  netperf::native "$@"
  netperf::docker "$@"
}

netperf::lkl() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  setup_lkl
  cd $NETPERF_DIR/lkl

  # XXX: musl-libc w/ UDP_STREAM is not working over 2sec length so, use hijack
  echo "$(tput bold)== lkl tap ($test-$num $*)  ==$(tput sgr0)"

  rexec src/netperf disk.img tap:tap0 config:lkl.json \
   -- $netperf_args \
   2>&1 | tee "$OUTPUT/$PREFIX-$test-lkl-tap-ps$size-$num.dat" &
  sudo ifconfig tap0 up; sudo ifconfig bridge0 addm tap0
  wait

  cd $SCRIPT_DIR
)
}

netperf::noah() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  cd $NETPERF_DIR/noah
  echo "$(tput bold)== noah ($test-$num $*)  ==$(tput sgr0)"

  ulimit -n 1088

  noah "src/netperf" -- $netperf_args \
    2>&1 | tee "$OUTPUT/$PREFIX-$test-noah-ps$size-$num.dat"

  cd $SCRIPT_DIR
)
}

netperf::docker() {
( 
  local test=$1
  local num=$2
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"
  
  echo "$(tput bold)== docker ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --rm \
   thehajime/byte-unixbench:latest \
   netperf $netperf_args 2>&1 \
  | tee "$OUTPUT/$PREFIX-$test-docker-ps$size-$num.dat"
)
}

netperf::native() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  cd $NETPERF_DIR/macos
  echo "$(tput bold)== native ($test-$num $*)  ==$(tput sgr0)"
  "src/netperf" $netperf_args 2>&1 | tee "$OUTPUT/$PREFIX-$test-native-ps$size-$num.dat"

  cd $SCRIPT_DIR
)
}

main
