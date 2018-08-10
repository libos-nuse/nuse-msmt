#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

# macos has different syntax
OUTPUT=$SCRIPT_DIR/$(date "+%Y-%m-%d")

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.1"
OIF=br0

FRANKENLIBC_DIR=/home/moroo/src/frankenlibc
NETPERF_DIR=${FRANKENLIBC_DIR}/netperf2
#TMP variable
export PATH=${FRANKENLIBC_DIR}/rump/bin:${PATH}
export PATH=${FRANKENLIBC_DIR}/liunx/tools/lkl/bin:${PATH}

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

  export LKL_HIJACK_OFFLOAD=0xc803

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

netperf::run() {
  netperf::docker "$@" "runsc-ptrace-user"
  netperf::docker "$@" "runsc-ptrace-host"
  netperf::docker "$@" "runsc-kvm-user"
  netperf::docker "$@" "runsc-kvm-host"
}

netperf::docker() {
( 
  local test=$1
  local num=$2
  local psize="$3"
  local ex_arg="$4"
  local runtime="$5"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"
  
  echo "$(tput bold)== docker ($runtime) ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --runtime=$runtime --rm \
   thehajime/byte-unixbench:latest \
   netperf $netperf_args 2>&1 \
  | tee "$OUTPUT/$PREFIX-$test-$runtime-ps$size-$num.dat"
)
}

main
