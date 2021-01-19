#!/bin/bash

#set -x

# variables
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=${OUTPUT:-`date "+%Y-%m-%d-%H"`}
export OUTPUT
DUT_HOST=10.0.39.2
DUT_ROOTDIR=$HOME/work/nuse-msmt/eurosys/anvl/anvl-dut
SLACK_CH=log

STACKS4=${STACKS4:-"linux lwip osv gvisor lkl mtcp seastar rump linux-nozebra lkl-nozebra lkl-osx graphene"}
STACKS6=${STACKS6:-"linux lwip lkl rump linux-nozebra lkl-nozebra lkl-osx graphene"}

TESTS4=${TESTS4:-"arp ip icmp"}
# available TESTS="icmpv6 ipv6 ipv6-autoconfig ipv6-ndp ipv6-pmtu ipv6-rtralert ipv6cp ipv6ov4"
TESTS6=${TESTS6:-"ipv6 icmpv6 ipv6-ndp"}

run_DUT()
{
  DUT=$1
  # kill all programs
  ssh ${DUT_HOST} "sudo killall epserver rump_allserver qemu-system-x86_64; sudo killall -9 zebra httpd; killall lwip-tap; docker kill gvisor; docker kill graphene"

  case $DUT in
    "mtcp") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/mtcp/; bash ../../mtcp/dut-run.sh & read; sudo killall epserver"  ;;
    lkl|lkl-nozebra) 
	coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/lkl-linux/; export NO_ZEBRA=$NO_ZEBRA ; 
	bash ../../lkl/dut-run.sh & read; sudo killall -9 zebra"  ;;
    linux|linux-nozebra) 
	coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/quagga/; export NO_ZEBRA=$NO_ZEBRA ; 
	bash ../../linux/dut-run.sh & read; sudo killall zebra" ;;
    "seastar") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/seastar/; bash ../../seastar/dut-run.sh & read; sudo killall -9 httpd"  ;;
    "gvisor") ssh ${DUT_HOST} "cd $DUT_ROOTDIR/../gvisor/; bash dut-run.sh" ;;
    "graphene") ssh ${DUT_HOST} "cd $DUT_ROOTDIR/../graphene/; bash dut-run.sh" ;;
    "lwip") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/lwip-tap/; bash ../../lwip/dut-run.sh & read; killall lwip-tap"  ;;
    "osv") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/osv; bash ../../osv/dut-run.sh & read; sudo killall qemu-system-x86_64" ;;
    "rump") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/rump/; bash ../../rump/dut-run.sh & read; killall rump_server"  ;
  esac

  trap 'echo >&"${COPROC[1]}"' EXIT

  sleep 10

}

