#!/bin/bash

#set -x

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT="$(date "+%Y-%m-%d")"
DUT_HOST=192.168.39.2
DUT_ROOTDIR=$HOME/work/nuse-msmt/eurosys/anvl/anvl-dut

DUT=$(basename `pwd`)
run_DUT()
{
  # kill all programs
  ssh ${DUT_HOST} "sudo killall epserver; sudo killall -9 zebra; sudo killall -9 httpd; killall lwip-tap; sudo killall rump_allserver"

  case $DUT in
    "mtcp") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/mtcp/; bash run.sh & read; sudo killall epserver"  ;;
    lkl|lkl-nozebra) 
	coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/lkl-linux/; export NO_ZEBRA=$NO_ZEBRA ; 
	bash run.sh & read; sudo killall -9 zebra"  ;;
    linux|linux-nozebra) 
	coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/quagga/; export NO_ZEBRA=$NO_ZEBRA ; 
	bash run.sh & read; sudo killall zebra" ;;
    "seastar") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/seastar/; bash ../../seastar/dut-run.sh & read; sudo killall -9 httpd"  ;;
    "gvisor") ssh ${DUT_HOST} "cd $DUT_ROOTDIR/../gvisor/; bash dut-run.sh" ;;
    "lwip") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/lwip-tap/; bash run.sh & read; killall lwip-tap"  ;;
    "osv") coproc ssh ${DUT_HOST} "sudo /home/upa/OSv/start-osv-qemu-cmd-two-netdev.sh" & ;;
    "rump") coproc ssh ${DUT_HOST} "cd $DUT_ROOTDIR/rump/; bash ../../rump/dut-run.sh & read; killall rump_server"  ;
  esac

  trap 'echo >&"${COPROC[1]}"' EXIT

  sleep 10

}

