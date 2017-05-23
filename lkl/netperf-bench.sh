#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
OIF=ens3f1
OIF=br0

SEAPERF_TCP_PORT="8065"
SEAPERF_DEST="2.1.1.2"
SEAPERF_SELF="2.1.1.3"

main() {
  initialize

  # for netperf tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PSIZES; do
      for test in $TESTNAMES; do
        netperf::run $test $num $size "-m $size,$size"
      done

      nerperf::run TCP_RR $num $size " -r $size,$size"
      nerperf::run UDP_STREAM $num $size "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size"
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

  netperf::lkl "$@"
  netperf::seaperf "$@"
  netperf::netbsd "$@"
  netperf::lkl-qemu "$@"
  netperf::native "$@"
}

netperf::lkl() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  # XXX: musl-libc w/ UDP_STREAM is not working over 2sec length so, use hijack
  if [[ "$test" == "UDP_STREAM" ]] ; then
    echo "$(tput bold)== lkl-hijack tap ($test-$num $*)  ==$(tput sgr0)"
    LKL_HIJACK_NET_IFTYPE=tap \
    LKL_HIJACK_NET_IFPARAMS=tap0 \
    LKL_HIJACK_NET_IP="$SELF_ADDR" \
    LKL_HIJACK_NET_NETMASK_LEN=24 \
      $TASKSET lkl-hijack.sh \
      "$NATIVE_NETPERF/netperf" $netperf_args \
        |& tee -a "$OUTPUT/$PREFIX-$test-hijack-tap-ps$size-$num.dat"
  else
    echo "$(tput bold)== lkl-musl tap ($test-$num $*)  ==$(tput sgr0)"

    rexec "$LKLMUSL_NETPERF/netperf" tap:tap0 -- $netperf_args \
     |& tee -a "$OUTPUT/$PREFIX-$test-musl-tap-ps$size-$num.dat"
  fi
)
}

netperf::seaperf() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"

  if [[ "$test" != "TCP_STREAM" ]]; then
    return
  fi

  echo "$(tput bold)== seastar tap ($test-$num $*) ==$(tput sgr0)"

  for i in {0..5}; do
    sudo timeout 120 "$SEAPERF/src/seaperf/seaclient" \
      --host "$SEAPERF_DEST" --port "$SEAPERF_TCP_PORT" \
      --network-stack native --dpdk-pmd \
      --dhcp 0 \
      --host-ipv4-addr "$SEAPERF_SELF" \
      --netmask-ipv4-addr 255.255.255.0 \
      |& tee -a "$OUTPUT/$PREFIX-$test-seastar-tap-ps$size-$num.dat"

    if [[ "$?"  != 124 ]]; then
      break
    fi
  done # while
)
}

netperf::netbsd() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  echo "$(tput bold)== netbsd tap ($test-$num $*)  ==$(tput sgr0)"

  export PATH="$PROJECT_ROOT/frankenlibc-netbsd/rump/bin:$PATH"
  export FIXED_GATEWAY=1.1.1.1

  rexec "$NETBSD_NETPERF/netperf" tap:tap0 -- $netperf_args \
    |& tee -a "$OUTPUT/$PREFIX-$test-netbsd-tap-ps$size-$num.dat"
)
}

netperf::lkl-qemu() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -t $test -- -o $ex_arg"

  echo "$(tput bold)== lkl-musl-qemu tap ($test-$num $*)  ==$(tput sgr0)"
  rumprun kvm \
   -M 10000 -I 'eth0,eth,-netdev type=tap,script=no,ifname=tap0,id=eth0' \
   -W "eth0,inet,static,$SELF_ADDR/$FIXED_MASK" \
   -g "-s -nographic -vga none" -i \
   "$RUMPRUN_NETPERF/netperf.bin" $NETPERF_ARGS \
   |& tee -a "$OUTPUT/$PREFIX-$test-qemu-tap-ps$size-$num.dat" &
  sleep 13 && killall qemu-system-x86_64
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
  $TASKSET "$NATIVE_NETPERF/netperf" $netperf_args |& tee -a "$OUTPUT/$PREFIX-$test-native-ps$size-$num.dat"

  #echo "== native (sendmmsg) ($test-$num)  =="
  #$TASKSET "$NATIVE_NETPERF_mmsg/netperf" $netperf_args |& tee -a "$OUTPUT/netperf-$test-native-mmsg-$num.dat"
)
}

main
