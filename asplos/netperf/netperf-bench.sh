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

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

netperf::run() {
  netperf::lkl    "$@"
  netperf::native "$@"
  netperf::docker "$@" "runc"
  netperf::docker "$@" "kata-runtime"
  netperf::docker "$@" "runsc"
}

netperf::lkl() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  setup_lkl
  cd $NETPERF_DIR

  echo "$(tput bold)== lkl ($test-$num $*)  ==$(tput sgr0)"
  sudo -u moroo ${FRANKENLIBC_DIR}/rump/bin/rexec \
   src/netperf disk.img tap:tap0 config:lkl.json \
   -- $netperf_args \
   2>&1 | tee "$OUTPUT/$PREFIX-$test-lkl-ps$size-$num.dat"
  wait

  cd $SCRIPT_DIR
)
}

netperf::native() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  echo "$(tput bold)== native ($test-$num $*)  ==$(tput sgr0)"
  netperf $netperf_args 2>&1 | tee "$OUTPUT/$PREFIX-$test-native-ps$size-$num.dat"
)
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
