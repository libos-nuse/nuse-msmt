#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
OIF=ens3f1
OIF=br0
TRIALS=2

main() {
  initialize

  # for netperf tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PSIZES; do
      for test in $TESTNAMES; do
        netperf::run $test $num $size "-m $size,$size"
      done

#      nerperf::run TCP_RR $num $size " -r $size,$size"
#      nerperf::run UDP_STREAM $num $size "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"
    done
  done

  bash "$SCRIPT_DIR/netperf-plot-android.sh" "$OUTPUT" tx
  bash "$SCRIPT_DIR/netperf-plot-android.sh" "$OUTPUT" rx
}

initialize() {
  export FIXED_ADDRESS=${SELF_ADDR}
  export FIXED_MASK=24

  export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_HIJACK_BOOT_CMDLINE="mem=1G"

  export LKL_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_BOOT_CMDLINE="mem=1G"

  # enable offload

  # disable c-state
  sudo tuned-adm profile latency-performance

  # VIRTIO offloads, CSUM/TSO4/MRGRCVBUF/UFO
  export LKL_HIJACK_OFFLOAD=0xc803

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

netperf::run() {
  sudo ethtool -K "$OIF" tso on gro on gso on rx on tx on
  sudo sysctl -w net.ipv4.tcp_wmem="4096 87380 100000000"

  netperf::lkl_android "$@"
  netperf::native_android "$@"
}


netperf::lkl_android() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H 202.214.86.51 -c -C -D1 -T 1/1 -t $test -p 443 -- -o $ex_arg -P 80,80"

  setup_lkl

  export PATH=${PATH}:/home/tazaki/Android/Sdk/platform-tools/
  echo "$(tput bold)== lkl-android raw ($test-$num $*)  ==$(tput sgr0)"

  #adb shell su -c /data/local/tmp/cellar-test.sh /data/local/tmp/netperf $netperf_args \

  adb shell su -c LKL_HIJACK_LIBNAME=liblkl-hijack-mptcp.so sh /data/data/jp.ad.iij.nuse/cache/lkl-hijack-android.sh netperf $netperf_args \
     |& tee -a "$OUTPUT/$PREFIX-$test-lkl-android-raw-ps$size-$num.dat"
)
}

netperf::native_android() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H 202.214.86.51 -c -C -D1 -T 1/1 -t $test -p 443 -- -o $ex_arg -P 80,80"

  setup_lkl

  export PATH=${PATH}:/home/tazaki/Android/Sdk/platform-tools/
  echo "$(tput bold)== native-android ($test-$num $*)  ==$(tput sgr0)"

  adb shell su -c /data/data/jp.ad.iij.nuse/cache/netperf $netperf_args \
     |& tee -a "$OUTPUT/$PREFIX-$test-native-android-raw-ps$size-$num.dat"
)
}

main
