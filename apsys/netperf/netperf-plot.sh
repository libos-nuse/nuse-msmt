#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

OUTPUT="$1"
DIRS="tx rx"
PREFIX=netperf-bench-TCP_STREAM
PREFIX_RR=netperf-bench-TCP_RR
PREFIX_UDP=netperf-bench-UDP_STREAM

for DIR in $DIRS; do

if [[ "$DIR" == "rx" ]] ; then
  PREFIX=netperf-bench-TCP_MAERTS
elif [[ "$DIR" == "tx" ]] ; then
  PREFIX=netperf-bench-TCP_STREAM
else
  echo "Invalid direction: $0 \${OUTPUT} [tx/rx]"
  exit
fi


rm -rf "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/out/"


# parse outputs

# TCP_STREAM
grep -E -h bits ${OUTPUT}/${PREFIX}*-lkl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-lkl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-noah-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-noah.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-native-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-docker-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-docker.dat

# TCP_RR
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-lkl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-lkl-tap.dat

grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-noah-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-noah.dat

grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-native-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-native.dat

grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-docker-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-docker.dat

# UDP_STREAM
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-lkl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-lkl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-noah-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-noah.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-native.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-docker-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-docker.dat

# UDP_STREAM PPS
 
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-lkl-tap-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-lkl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-noah-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-noah.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-native.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-docker-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-docker.dat

done # end of ${DIR}


gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-stream.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics
set rmargin 0

set boxwidth 0.2
set style fill pattern

set size 1.0,0.8
set key top left

set xrange [-0.5:6.5]
set xtics ${PSIZE_XTICS}
set xlabel "Payload size (bytes)"
set yrange [-1:1]
set ytics ('(rx) 1' -1, '0.5' -0.5, '0' 0, '0.5' 0.5, '(tx) 1' 1)
set ylabel "Goodput (Gbps)"


plot \
   '${OUTPUT}/tx/tcp-stream-lkl-tap.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "lkl" , \
   '${OUTPUT}/tx/tcp-stream-noah.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "green" title "noah" , \
   '${OUTPUT}/tx/tcp-stream-docker.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "gray" title "docker" ,\
   '${OUTPUT}/tx/tcp-stream-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "macos" ,\
   '${OUTPUT}/rx/tcp-stream-lkl-tap.dat' usin (\$0-0.3):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" notitle , \
   '${OUTPUT}/rx/tcp-stream-noah.dat' usin (\$0-0.1):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "green" notitle , \
   '${OUTPUT}/rx/tcp-stream-docker.dat' usin (\$0+0.1):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "gray" notitle,\
   '${OUTPUT}/rx/tcp-stream-native.dat' usin (\$0+0.3):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" notitle


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-stream.png"
replot


set xlabel "Payload size (bytes)"
set xrange [-0.5:6.5]
set xtics ${PSIZE_XTICS}
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-rr.eps"
set ylabel "Goodput (KTrans/sec)"
set yrange [0:20]
set ytics auto
set key top right

plot \
   '${OUTPUT}/tx/tcp-rr-lkl-tap.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "lkl" , \
   '${OUTPUT}/tx/tcp-rr-noah.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "green" title "noah" , \
   '${OUTPUT}/tx/tcp-rr-native.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "gray" title "docker" ,\
   '${OUTPUT}/tx/tcp-rr-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "macos" 

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-rr.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/udp-stream.eps"
set ylabel "Goodput (Gbps)"
set yrange [0:1]
set key top left

plot \
   '${OUTPUT}/tx/udp-stream-lkl-tap.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "lkl" , \
   '${OUTPUT}/tx/udp-stream-noah.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "green" title "noah" , \
   '${OUTPUT}/tx/udp-stream-native.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "gray" title "docker",\
   '${OUTPUT}/tx/udp-stream-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "macos"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/udp-stream-pps.eps"
set ylabel "Goodput (Mpps)"
set key top right
set yrange [0:1]

plot \
   '${OUTPUT}/tx/udp-stream-pps-lkl-tap.dat' usin (\$0-0.3):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 0 lc rgb "red" title "lkl" , \
   '${OUTPUT}/tx/udp-stream-pps-noah.dat' usin (\$0-0.1):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 1 lc rgb "green" title "noah" , \
   '${OUTPUT}/tx/udp-stream-pps-docker.dat' usin (\$0+0.1):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 2 lc rgb "gray" title "docker" ,\
   '${OUTPUT}/tx/udp-stream-pps-native.dat' usin (\$0+0.3):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 3 lc rgb "blue" title "macos"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

