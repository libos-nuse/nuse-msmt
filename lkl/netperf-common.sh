#!/bin/bash

PSIZES="64 128 256 512 1024 1500 65507"
PSIZE_XTICS="('64' 0, '128' 1, '256' 2, '512' 3, '1024' 4, '1500' 5, '65507' 6)"
SYS_MEM="512M 2G"
SYS_MEM="10000M"
TCP_WMEM="4194304 30000000 100000000 2000000000"
QDISC_PARAMS="root|fq none"
CC_ALGO="bbr cubic"
OFFLOADS="0 0003 d903" #disable, CSUM, CSUM/TSO4/MRGRCVBUF/UFO + TSO6

TRIALS=5

SELF_ADDR="1.1.1.3"
DEST_ADDR="1.1.1.2"
GUEST_ADDR="1.1.1.4"
GATEWAY_ADDR="1.1.1.1"
DPDK_DEST_ADDR="2.1.1.2"
DPDK_SELF_ADDR="2.1.1.3"
DPDK_NETMASK="255.255.255.0"
SEAPERF_TCP_PORT="8065"


[[ -z "$PROJECT_ROOT" ]] && PROJECT_ROOT=~/work
LKL_DIR="$PROJECT_ROOT/lkl-linux/"
NATIVE_NETPERF="$PROJECT_ROOT/netperf2/src/"
LKLMUSL_NETPERF="$PROJECT_ROOT/netperf2-lklmusl/src/"
NETBSD_NETPERF="$PROJECT_ROOT/netperf2-netbsd/src/"
RUMPRUN_NETPERF="$PROJECT_ROOT/netperf2/rumprun/"
SEAPERF="$PROJECT_ROOT/seaperf/release/"

TASKSET="taskset -c 0"
#OUTPUT="$(date -I)"

export LKL_HIJACK_OFFLOAD=0xc803
export LKL_OFFLOAD=1
#export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
#export LKL_HIJACK_BOOT_CMDLINE="mem=1G"
#LKL_SYSCTL="net.ipv4.tcp_wmem=4096 87380 2147483647"
#LKL_BOOT_CMDLINE="mem=1G"

setup_lkl() {
  PATH="$PROJECT_ROOT/frankenlibc/rump/bin:$LKL_DIR/tools/lkl/bin:$PATH"
  PATH="$PROJECT_ROOT/rumprun/rumprun-lkl-musl/bin:$PATH"
  export PATH
}

setup_netbsd_rump() {
  export PATH="$PROJECT_ROOT/frankenlibc-netbsd/rump/bin:$PATH"
}
