#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT="$(date "+%Y-%m-%d")"
DUT_HOST=172.16.0.176

DUT=$(basename `pwd`)
run_DUT()
{
  # kill all programs
  ssh ${DUT_HOST} "sudo killall epserver; sudo killall -9 zebra; sudo killall -9 httpd; killall lwip-tap"

  case $DUT in
    "mtcp") coproc ssh ${DUT_HOST} "cd anvl-dut/mtcp/; bash run.sh & read; sudo killall epserver"  ;;
    "lkl") coproc ssh ${DUT_HOST} "cd anvl-dut/lkl-linux/; bash run.sh & read; sudo killall -9 zebra"  ;;
    "linux") coproc ssh ${DUT_HOST} "cd anvl-dut/quagga/; bash run.sh & read; sudo killall -9 zebra" ;;
    "seastar") coproc ssh ${DUT_HOST} "cd anvl-dut/seastar/; bash run.sh & read; sudo killall -9 httpd"  ;;
    "gvisor") ;; #ssh ${DUT_HOST} "cd anvl-dut/mtcp/; bash run.sh" & ;;
    "lwip") coproc ssh ${DUT_HOST} "cd anvl-dut/lwip-tap/; bash run.sh & read; killall lwip-tap"  ;;
    "osv") coproc ssh ${DUT_HOST} "sudo /home/upa/OSv/start-osv-qemu-cmd-two-netdev.sh" & ;;
  esac

  trap 'echo >&"${COPROC[1]}"' EXIT

  sleep 10

}

