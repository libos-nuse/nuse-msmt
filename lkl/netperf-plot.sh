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
grep -h bits ${OUTPUT}/${PREFIX}*-hijack-tap* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-hijack-tap.dat

# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-macvtap* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-hijack-macvtap.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-raw* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-hijack-raw.dat
# 
grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-netbsd-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-netbsd-tap.dat

# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-macvtap-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-musl-macvtap.dat
# 
# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-raw-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-musl-raw.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-skbpre* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-musl-skbpre.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-sendmmsg* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
# | dbcolstats thpt | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-native-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native.dat

#grep -h bits ${OUTPUT}/${PREFIX}*-native-mmsg* \
#| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
#| dbcolstats thpt | dbcol mean stddev \
#> ${OUTPUT}/${DIR}/tcp-stream-native-sendmmsg.dat


# TCP_RR
 grep -h Trans ${OUTPUT}/${PREFIX_RR}*-hijack-tap* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-hijack-tap.dat
 
# grep -h Trans ${OUTPUT}/${PREFIX}*-hijack-macvtap* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-hijack-macvtap.dat
# 
# grep -h Trans ${OUTPUT}/${PREFIX}*-hijack-raw* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-hijack-raw.dat

grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-musl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-musl-tap.dat

grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-netbsd-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-netbsd-tap.dat

# grep -E -h Trans ${OUTPUT}/${PREFIX}*-musl-macvtap-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-musl-macvtap.dat
# 
# grep -E -h Trans ${OUTPUT}/${PREFIX}*-musl-raw-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-musl-raw.dat
# 
# grep -h Trans ${OUTPUT}/${PREFIX}*-musl-skbpre* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-musl-skbpre.dat
# 
# grep -h Trans ${OUTPUT}/${PREFIX}*-musl-sendmmsg* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-musl-sendmmsg.dat
# 
 grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-native-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-native.dat
 
# grep -E -h Trans ${OUTPUT}/${PREFIX}*-native-mmsg* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-native-sendmmsg.dat


# UDP_STREAM
grep -h bits ${OUTPUT}/${PREFIX_UDP}*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-hijack-tap.dat

# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-macvtap* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-hijack-macvtap.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-raw* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-hijack-raw.dat
 
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-musl-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-netbsd-tap-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-netbsd-tap.dat

# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-macvtap-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-musl-macvtap.dat
# 
# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-raw-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-musl-raw.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-skbpre* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-musl-skbpre.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-sendmmsg* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-musl-sendmmsg.dat
 
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-native.dat

# grep -h bits ${OUTPUT}/${PREFIX}*-native-mmsg* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-native-sendmmsg.dat


# UDP_STREAM PPS
grep -h bits ${OUTPUT}/${PREFIX_UDP}*-hijack-tap* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-hijack-tap.dat

# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-macvtap* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-hijack-macvtap.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-hijack-raw* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-hijack-raw.dat
# 
grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-tap-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}*-netbsd-tap-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-netbsd-tap.dat

# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-macvtap-* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-musl-macvtap.dat
# 
# grep -E -h bits ${OUTPUT}/${PREFIX}*-musl-raw-* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-musl-raw.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-skbpre* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-musl-skbpre.dat
# 
# grep -h bits ${OUTPUT}/${PREFIX}*-musl-sendmmsg* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-musl-sendmmsg.dat
# 
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-native.dat

# grep -h bits ${OUTPUT}/${PREFIX}*-native-mmsg* \
# | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
# | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/udp-stream-pps-native-sendmmsg.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/${DIR}/tcp-stream.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.45
set style fill pattern

set size 1.0,0.6
set key top left

set xrange [-1:7]
set xtics ${PSIZE_XTICS}
set xlabel "Payload size (bytes)"
set yrange [0:10]
set ylabel "Goodput (Gbps)"


plot \
   '${OUTPUT}/${DIR}/tcp-stream-musl-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/tcp-stream-netbsd-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/tcp-stream-native.dat' usin (\$0+0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 title "Linux"

   #'${OUTPUT}/${DIR}/tcp-stream-hijack-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \

#   '${OUTPUT}/${DIR}/tcp-stream-hijack-macvtap.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 1 title "hijack(macvtap)",\
#   '${OUTPUT}/${DIR}/tcp-stream-musl-tap.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 4 title "lkl-musl(tap)",\
#   '${OUTPUT}/${DIR}/tcp-stream-netbsd-tap.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 4 title "lkl-musl(tap)",\
#   '${OUTPUT}/${DIR}/tcp-stream-musl-skbpre.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 6 title "lkl-musl (skb-prealloc)",\
#   '${OUTPUT}/${DIR}/tcp-stream-musl-sendmmsg.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 7 title "lkl-musl (sendmmsg)",\
#   '${OUTPUT}/${DIR}/tcp-stream-musl-raw.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 4 title "lkl-musl(raw)",\
#   '${OUTPUT}/${DIR}/tcp-stream-hijack-raw.dat' usin (\$0-0.5):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\

set terminal png lw 3 14
set output "${OUTPUT}/out/${DIR}/tcp-stream.png"
replot


set xlabel "Payload size (bytes)"
set xrange [-1:7]
set xtics ${PSIZE_XTICS}
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/${DIR}/tcp-rr.eps"
set ylabel "Goodput (KTrans/sec)"
set yrange [0:20]
set key top right

plot \
   '${OUTPUT}/${DIR}/tcp-rr-musl-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/tcp-rr-netbsd-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/tcp-rr-native.dat' usin (\$0+0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 title "Linux"

   #'${OUTPUT}/${DIR}/tcp-rr-hijack-tap.dat' usin (\$0-0.225):1:2 w boxerrorbar fill patter 0 title "LKL" , \

##   '${OUTPUT}/${DIR}/tcp-rr-hijack-macvtap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 1 title "hijack(macvtap)",\
##   '${OUTPUT}/${DIR}/tcp-rr-musl-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
##   '${OUTPUT}/${DIR}/tcp-rr-musl-skbpre.dat' usin (\$0+0.2):1:2 w boxerrorbar fill patter 6 title "lkl-musl (skb-prealloc)",\
##   '${OUTPUT}/${DIR}/tcp-rr-netbsd-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
## #   '${OUTPUT}/${DIR}/tcp-rr-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\
##    #'${OUTPUT}/${DIR}/tcp-rr-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\

set terminal png lw 3 14
set output "${OUTPUT}/out/${DIR}/tcp-rr.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/${DIR}/udp-stream.eps"
set ylabel "Goodput (Gbps)"
set yrange [0:10]
set key top left

plot \
   '${OUTPUT}/${DIR}/udp-stream-hijack-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/udp-stream-native.dat' usin (\$0+0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 title "Linux"

   #'${OUTPUT}/${DIR}/udp-stream-musl-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \
   #'${OUTPUT}/${DIR}/udp-stream-netbsd-tap.dat' usin (\$0-0.225):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL" , \

#   '${OUTPUT}/${DIR}/udp-stream-hijack-macvtap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 1 title "hijack(macvtap)",\
#   '${OUTPUT}/${DIR}/udp-stream-musl-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap",\
#   '${OUTPUT}/${DIR}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):1:2 w boxerrorbar title "lkl-musl (sendmmsg+skb prealloc)", \
   #'${OUTPUT}/${DIR}/udp-stream-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\
#   '${OUTPUT}/${DIR}/udp-stream-netbsd-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap",\
   #'${OUTPUT}/${DIR}/udp-stream-native-sendmmsg.dat' usin (\$0+0.5):1:2 w boxerrorbar fill patter 3 title "native (sendmmsg)"
#   '${OUTPUT}/${DIR}/udp-stream-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\



set terminal png lw 3 14
set output "${OUTPUT}/out/${DIR}/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/${DIR}/udp-stream-pps.eps"
set ylabel "Goodput (Mpps)"
set key top right
set yrange [0:1]

plot \
   '${OUTPUT}/${DIR}/udp-stream-pps-hijack-tap.dat' usin (\$0-0.225):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 0 title "LKL" , \
   '${OUTPUT}/${DIR}/udp-stream-pps-native.dat' usin (\$0+0.225):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 3 title "Linux"

   #'${OUTPUT}/${DIR}/udp-stream-pps-musl-tap.dat' usin (\$0-0.225):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 0 title "LKL" , \
   #'${OUTPUT}/${DIR}/udp-stream-pps-netbsd-tap.dat' usin (\$0-0.225):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 0 title "LKL" , \

#   '${OUTPUT}/${DIR}/udp-stream-pps-hijack-macvtap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 1 title "hijack(macvtap)",\
#   '${OUTPUT}/${DIR}/udp-stream-pps-musl-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
#   '${OUTPUT}/${DIR}/udp-stream-pps-musl-sendmmsg.dat' usin (\$0+0.2):1:2 w boxerrorbar title "lkl-musl (sendmmsg+skb prealloc)", \
   #'${OUTPUT}/${DIR}/udp-stream-pps-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\
#   '${OUTPUT}/${DIR}/udp-stream-pps-netbsd-tap.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
   #'${OUTPUT}/${DIR}/udp-stream-pps-native-sendmmsg.dat' usin (\$0+0.5):1:2 w boxerrorbar fill patter 3 title "native (sendmmsg)"
   #'${OUTPUT}/${DIR}/udp-stream-pps-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\



set terminal png lw 3 14
set output "${OUTPUT}/out/${DIR}/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

