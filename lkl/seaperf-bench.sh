#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

PREFIX=netperf-bench
TESTNAMES="base tso gso checksum"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
OIF=ens3f1
OIF=br0

main() {
  initialize

  # for netperf tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PSIZES; do
      for test in $TESTNAMES; do
        network_config "$test"
        seaperf::tap::run $test $num $size "-m $size,$size"
      done
    done

    seaperf::dpdk::run "dpdk" $num $size "-m $size,$size"
  done
  network_config tso gro gso rx tx

  seaperf::plot
}

initialize() {
  export FIXED_ADDRESS=${SELF_ADDR}
  export FIXED_MASK=24

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

seaperf::tap::run() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"

  echo "$(tput bold)== seastar tap ($test-$num $*) ==$(tput sgr0)"

  ssh "$DEST_ADDR" "$SEAPERF/src/seaperf/seaserver -c1 --once --port $SEAPERF_TCP_PORT" \
    |& tee -a "$OUTPUT/$PREFIX-$test-seastar-tap-ps$size-$num.dat" &

  for i in {0..5}; do
    sudo timeout 120 "$SEAPERF/src/seaperf/seaclient" \
      --host "$DEST_ADDR" --port "$SEAPERF_TCP_PORT" \
      --bufsize "$psize" \
      --host-ipv4-addr "$SELF_ADDR" \
      --lro off

    case ${PIPESTATUS[0]} in
      0) break ;;
      *) continue ;;
    esac
  done # while
)
}

seaperf::dpdk::run() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"

  if [[ "$test" != "TCP_STREAM" ]]; then
    return
  fi

  echo "$(tput bold)== seastar dpdk ($test-$num $*) ==$(tput sgr0)"

  ssh "$DPDK_DEST_ADDR" "$SEAPERF/src/seaperf/seaserver -c1 --once --port $SEAPERF_TCP_PORT" \
    |& tee -a "$OUTPUT/$PREFIX-$test-seastar-dpdk-ps$size-$num.dat" &

  for i in {0..5}; do
    sudo timeout 120 "$SEAPERF/src/seaperf/seaclient" \
      --host "$DEST_ADDR" --port "$SEAPERF_TCP_PORT" \
      --bufsize "$psize" \
      --network-stack native --dpdk-pmd \
      --dhcp 0 \
      --host-ipv4-addr "$DPDK_SELF_ADDR" \
      --netmask-ipv4-addr "$DPDK_NETMASK" \
      --lro off

    case ${PIPESTATUS[0]} in
      124|137) continue ;;
      *) break ;;
    esac
  done # while
)
}

seaperf::plot() {
  rm -rf "$OUTPUT/seastar"
  mkdir -p "$OUTPUT/seastar"
  mkdir -p "$OUTPUT/out/seastar"

  grep -E -h bits "$OUTPUT/$PREFIX"-tso-seastar-tap-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine d1 d2 psize thpt d3 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/seastar/tso-seastar-tap.dat

  grep -E -h bits "$OUTPUT/$PREFIX"-gso-seastar-tap-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine d1 d2 psize thpt d3 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/seastar/gso-seastar-tap.dat

  grep -E -h bits "$OUTPUT/$PREFIX"-checksum-seastar-tap-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine d1 d2 psize thpt d3 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/seastar/checksum-seastar-tap.dat

  grep -E -h bits "$OUTPUT/$PREFIX"-base-seastar-tap-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine d1 d2 psize thpt d3 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/seastar/base-seastar-tap.dat

  grep -E -h bits "$OUTPUT/$PREFIX"-dpdk-seastar-* \
  | dbcoldefine dum | csv_to_db | dbcoldefine d1 d2 psize thpt d3 \
  | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
  > ${OUTPUT}/seastar/dpdk-seastar.dat

  gnuplot  << EndGNUPLOT
    set terminal png lw 3 14 crop
    set output "${OUTPUT}/out/seastar/tcp-stream.png"
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
      '${OUTPUT}/seastar/tso-seastar-tap.dat' usin (\$0-0.45):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "tso" , \
      '${OUTPUT}/seastar/gso-seastar-tap.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "gso" , \
      '${OUTPUT}/seastar/checksum-seastar-tap.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "checksum" , \
      '${OUTPUT}/seastar/base-seastar-tap.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "base" , \
      '${OUTPUT}/seastar/dpdk-seastar.dat' usin (\$0+0.45):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 title "dpdk"
    
    quit
EndGNUPLOT
}

main
