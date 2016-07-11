
OUTPUT=$1
DIR=tx
PREFIX=netpert

if [ $2 == "rx" ] ; then
    DIR=rx
    PREFIX=netserver
elif [ $2 == "tx" ] ; then
    DIR=tx
    PREFIX=netperf
else
    echo "Invalid direction: $0 \${OUTPUT} [tx/rx]"
    exit
fi

mkdir -p ${OUTPUT}/${DIR}

# parse outputs

# TCP_STREAM
grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-hijack-tap.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-hijack-raw.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-raw-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-musl-raw.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-musl-skbpre.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native-sendmmsg.dat


# TCP_RR
grep -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-hijack-tap.dat

grep -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-hijack-raw.dat

grep -E -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-musl-tap-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-musl-tap.dat

grep -E -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-musl-raw-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-musl-raw.dat

grep -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-musl-skbpre.dat

grep -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-musl-sendmmsg.dat

grep -E -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-native.dat

grep -E -h Trans ${OUTPUT}/${PREFIX}-TCP_RR*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-rr-native-sendmmsg.dat


# UDP_STREAM
grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-hijack-tap.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-hijack-raw.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-tap-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-raw-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-musl-raw.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-musl-skbpre.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-native.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-native-sendmmsg.dat

# UDP_STREAM PPS
grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-hijack-tap.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-hijack-raw.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-tap-[0-9].* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-musl-tap.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-raw-[0-9].* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-musl-raw.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-musl-skbpre.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-native.dat

grep -h bits ${OUTPUT}/${PREFIX}-UDP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-native-sendmmsg.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/tcp-stream.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern


set xrange [-1:1]
set yrange [:10000]
set ylabel "${DIR} Goodput (Mbps)"
unset xlabel
unset xtics


plot \
   '${OUTPUT}/${DIR}/tcp-stream-hijack-raw.dat' usin (\$0-0.5):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\
   '${OUTPUT}/${DIR}/tcp-stream-musl-tap.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 4 title "lkl-musl(tap)",\
   '${OUTPUT}/${DIR}/tcp-stream-musl-raw.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 4 title "lkl-musl(raw)",\
   '${OUTPUT}/${DIR}/tcp-stream-musl-skbpre.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 6 title "lkl-musl (skb-prealloc)",\
   '${OUTPUT}/${DIR}/tcp-stream-musl-sendmmsg.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 7 title "lkl-musl (sendmmsg)",\
   '${OUTPUT}/${DIR}/tcp-stream-native.dat' usin (\$0+0.5):1:2 w boxerrorbar fill patter 3 title "native"

#   '${OUTPUT}/${DIR}/tcp-stream-hijack-tap.dat' usin (\$0-0.5):1:2 w boxerrorbar fill patter 0 title "hijack(tap)" , \

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/${DIR}/tcp-stream.png"
replot


set xtics ("1" 0, "64" 1, "128" 2, "256" 3, "512" 4, "1024" 5, "1500" 6, "2048" 7, "65507" 8)
set xlabel "Payload size (bytes)"
set xrange [-1:9]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/tcp-rr.eps"
set ylabel "${DIR} Goodput (Trans/sec)"
set yrange [0:20000]

plot \
   '${OUTPUT}/${DIR}/tcp-rr-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\
   '${OUTPUT}/${DIR}/tcp-rr-musl-tap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
   '${OUTPUT}/${DIR}/tcp-rr-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\
   '${OUTPUT}/${DIR}/tcp-rr-musl-skbpre.dat' usin (\$0+0.2):1:2 w boxerrorbar fill patter 6 title "lkl-musl (skb-prealloc)",\
   '${OUTPUT}/${DIR}/tcp-rr-native.dat' usin (\$0+0.4):1:2 w boxerrorbar fill patter 3 title "native"

#   '${OUTPUT}/${DIR}/tcp-rr-hijack-tap.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 0 title "hijack(tap)" , \

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/${DIR}/tcp-rr.png"
replot


set autoscale y
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/udp-stream.eps"
set ylabel "${DIR} Goodput (Mbps)"

plot \
   '${OUTPUT}/${DIR}/udp-stream-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\
   '${OUTPUT}/${DIR}/udp-stream-musl-tap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap",\
   '${OUTPUT}/${DIR}/udp-stream-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\
   '${OUTPUT}/${DIR}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):1:2 w boxerrorbar title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/${DIR}/udp-stream-native-sendmmsg.dat' usin (\$0+0.4):1:2 w boxerrorbar fill patter 3 title "native (sendmmsg)"

#   '${OUTPUT}/${DIR}/udp-stream-hijack-tap.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 0 title "hijack(tap)" , \


set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/${DIR}/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/udp-stream-pps.eps"
set ylabel "${DIR} Throughput (pps)"

plot \
   '${OUTPUT}/${DIR}/udp-stream-pps-hijack-raw.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 1 title "hijack(raw)",\
   '${OUTPUT}/${DIR}/udp-stream-pps-musl-tap.dat' usin (\$0-0.2):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(tap)",\
   '${OUTPUT}/${DIR}/udp-stream-pps-musl-raw.dat' usin (\$0-0.0):1:2 w boxerrorbar fill patter 5 lw 1 title "lkl-musl(raw)",\
   '${OUTPUT}/${DIR}/udp-stream-pps-musl-sendmmsg.dat' usin (\$0+0.2):1:2 w boxerrorbar title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/${DIR}/udp-stream-pps-native-sendmmsg.dat' usin (\$0+0.4):1:2 w boxerrorbar fill patter 3 title "native (sendmmsg)"

#   '${OUTPUT}/${DIR}/udp-stream-pps-hijack-tap.dat' usin (\$0-0.4):1:2 w boxerrorbar fill patter 0 title "hijack(tap)" , \


set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/${DIR}/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

