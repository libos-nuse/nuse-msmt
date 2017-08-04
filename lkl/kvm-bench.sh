#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

PREFIX=netperf-bench
TESTNAMES="base tso gso checksum"
OIF=ens3f1
OIF=br0

main() {
  initialize

  # for netperf tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PSIZES; do
      for test in $TESTNAMES; do
        network_config "$test"
        netperf::run $test $num $size "-m $size,$size"
      done
    done
  done
  network_config tso gro gso rx tx

  netperf::plot
}

initialize() {
  # disable c-state
  sudo tuned-adm profile latency-performance

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

network_config() {
  local tso=off
  local gro=off
  local gso=off
  local rx=off
  local tx=off

  while (( "$#" >  0 )); do
    case "$1" in
      tso)
        tso=on
        rx=on
        tx=on
        ;;
      gso)
        gso=on
        rx=on
        tx=on
        ;;
      checksum)
        rx=on
        tx=on
        ;;
    esac
    shift
  done

  sudo ethtool -K "$OIF" tso "$tso" gro "$gro" gso "$gso" rx "$rx" tx "$tx"
  sudo sysctl -w net.ipv4.tcp_wmem="4096 87380 100000000"
}

netperf::run() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local netperf_args="-H $DEST_ADDR -- -o $ex_arg"

  echo "$(tput bold)== kvm tap ($test-$num $*) ==$(tput sgr0)"

  ssh "root@$GUEST_ADDR" "netperf $netperf_args" \
    |& tee -a "$OUTPUT/$PREFIX-$test-kvm-ps$size-$num.dat"
)
}

netperf::plot() {
  rm -rf "$OUTPUT/kvm"
  mkdir -p "$OUTPUT/kvm"
  mkdir -p "$OUTPUT/out/kvm"

  grep -E -h bits ${OUTPUT}/${PREFIX}*-tso-kvm-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/kvm/tso-kvm.dat

  grep -E -h bits ${OUTPUT}/${PREFIX}*-gso-kvm-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/kvm/gso-kvm.dat

  grep -E -h bits ${OUTPUT}/${PREFIX}*-checksum-kvm-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/kvm/checksum-kvm.dat

  grep -E -h bits ${OUTPUT}/${PREFIX}*-base-kvm-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/kvm/base-kvm.dat

  gnuplot  << EndGNUPLOT
    set terminal png lw 3 14 crop
    set output "${OUTPUT}/out/kvm/tcp-stream.png"
    #set xtics font "Helvetica,14"
    set pointsize 2
    set xzeroaxis
    set grid ytics
    
    set boxwidth 0.3
    set style fill pattern
    
    set size 1.0,0.6
    set key top left
    
    set xrange [-1:7]
    set xtics ${PSIZE_XTICS}
    set xlabel "Payload size (bytes)"
    set yrange [0:10]
    set ylabel "Goodput (Gbps)"
    
    
    plot \
      '${OUTPUT}/kvm/tso-kvm.dat' usin (\$0-0.45):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "tso" , \
      '${OUTPUT}/kvm/gso-kvm.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "gso" , \
      '${OUTPUT}/kvm/checksum-kvm.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "checksum" , \
      '${OUTPUT}/kvm/base-kvm.dat' usin (\$0+0.45):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "base"
    
    quit
EndGNUPLOT
}

main
