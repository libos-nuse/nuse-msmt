#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

OUTPUT="$1"
DIR=tx
PREFIX=netperf-bench-TCP_STREAM
PREFIX_RR=netperf-bench-TCP_RR
PREFIX_UDP=netperf-bench-UDP_STREAM

if [[ "$2" == "rx" ]] ; then
  DIR=rx
  PREFIX=netperf-bench-TCP_MAERTS
elif [[ "$2" == "tx" ]] ; then
  DIR=tx
  PREFIX=netperf-bench-TCP_STREAM
else
  echo "Invalid direction: $0 \${OUTPUT} [tx/rx]"
  exit
fi

rm -rf "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/out/$DIR/"


# parse outputs

# TCP_STREAM

grep -E -h bits ${OUTPUT}/${PREFIX}*-native-android-* | grep usec \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native-android.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-lkl-android-* | grep usec \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-lkl-android.dat

# cpu utilization
grep -E -h bits ${OUTPUT}/${PREFIX}*-native-android-* | grep usec \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 d4 d5 cpu \
| dbmultistats -k psize cpu | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native-android-cpu.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-lkl-android-* | grep usec \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 d4 d5 cpu \
| dbmultistats -k psize cpu | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-lkl-android-cpu.dat


gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/${DIR}/tcp-stream.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.4
set style fill pattern

set size 1.0,0.6
set key top left

set xrange [-1:7]
set xtics ${PSIZE_XTICS}
set xlabel "Payload size (bytes)"
set yrange [0:100]
set ylabel "Goodput (Mbps)"
set y2tics
set ytics nomirror
set y2range [0:]
set y2label "CPU utilization (%)"


plot \
   '${OUTPUT}/${DIR}/tcp-stream-lkl-android.dat' usin (\$0-0.2):(\$1):(\$2) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/tcp-stream-native-android.dat' usin (\$0+0.2):(\$1):(\$2) w boxerrorbar fill patter 0 title "native" ,\
   '${OUTPUT}/${DIR}/tcp-stream-lkl-android-cpu.dat' usin (\$0-0.2):(\$1):(\$2) w yerrorbars axes x1y2 notitle , \
   '${OUTPUT}/${DIR}/tcp-stream-native-android.dat' usin (\$0+0.2):(\$1):(\$2) w yerrorbars axes x1y2 notitle 

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/${DIR}/tcp-stream.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

