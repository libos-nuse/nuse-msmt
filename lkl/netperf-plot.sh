
OUTPUT=$1


# parse outputs

# TCP_STREAM
grep -h bits ${OUTPUT}/netperf-TCP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-hijack-tap.dat

grep -h bits ${OUTPUT}/netperf-TCP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-hijack-raw.dat

grep -E -h bits ${OUTPUT}/netperf-TCP_ST*-musl-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-musl.dat

grep -h bits ${OUTPUT}/netperf-TCP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-musl-skbpre.dat

grep -h bits ${OUTPUT}/netperf-TCP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/netperf-TCP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-native.dat

grep -h bits ${OUTPUT}/netperf-TCP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/tcp-stream-native-sendmmsg.dat


# TCP_RR
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-hijack-tap.dat

grep -h Trans ${OUTPUT}/netperf-TCP_RR*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-hijack-raw.dat

grep -E -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-musl.dat

grep -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-musl-skbpre.dat

grep -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-musl-sendmmsg.dat

grep -E -h Trans ${OUTPUT}/netperf-TCP_RR*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-native.dat

grep -E -h Trans ${OUTPUT}/netperf-TCP_RR*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-rr-native-sendmmsg.dat


# UDP_STREAM
grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-hijack-tap.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-hijack-raw.dat

grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-musl-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-musl.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-musl-skbpre.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-native.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/udp-stream-native-sendmmsg.dat

# UDP_STREAM PPS
grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-hijack-tap.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-hijack-raw.dat

grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-musl-[0-9].* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-musl.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-musl-skbpre.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-native.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 \
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/udp-stream-pps-native-sendmmsg.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/tcp-stream.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern


set ylabel "Goodput (Mbps)"
plot \
   '${OUTPUT}/tcp-stream-hijack-tap.dat' usin (\$0-0.5):1 w boxes fill patter 0 title "hijack(tap)" , \
   '' usin (\$0-0.5):1:2 w yerror  notitle , \
   '${OUTPUT}/tcp-stream-hijack-raw.dat' usin (\$0-0.3):1 w boxes fill patter 1 title "hijack(raw)",\
   '' usin (\$0-0.3):1:2 w yerrorb  notitle, \
   '${OUTPUT}/tcp-stream-musl.dat' usin (\$0-0.1):1 w boxes fill patter 4 title "lkl-musl",\
   '' usin (\$0-0.1):1:2 w yerrorb  notitle, \
   '${OUTPUT}/tcp-stream-musl-skbpre.dat' usin (\$0+0.1):1 w boxes fill patter 6 title "lkl-musl (skb-prealloc)",\
   '' usin (\$0+0.1):1:2 w yerrorb  notitle ,\
   '${OUTPUT}/tcp-stream-musl-sendmmsg.dat' usin (\$0+0.3):1 w boxes fill patter 7 title "lkl-musl (sendmmsg)",\
   '' usin (\$0+0.3):1:2 w yerrorb  notitle ,\
   '${OUTPUT}/tcp-stream-native.dat' usin (\$0+0.5):1 w boxes fill patter 3 title "native",\
   '' usin (\$0+0.5):1:2 w yerrorb  notitle


set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/tcp-stream.png"
replot


set datafile separator "," 
set xtics ("1" 0, "64" 1, "128" 2, "256" 3, "512" 4, "1024" 5, "1500" 6, "2048" 7, "65507" 8)
set xlabel "Payload size (bytes)"
set xrange [-1:9]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/tcp-rr.eps"
set ylabel "Goodput (Trans/sec)"

plot \
   '${OUTPUT}/tcp-rr-hijack-tap.dat' usin (\$0-0.4):1 w boxes fill patter 0 title "hijack(tap)" , \
   '' usin (\$0-0.4):1:2 w yerror  notitle , \
   '${OUTPUT}/tcp-rr-hijack-raw.dat' usin (\$0-0.2):1 w boxes fill patter 1 title "hijack(raw)",\
   '' usin (\$0-0.2):1:2 w yerrorb  notitle, \
   '${OUTPUT}/tcp-rr-musl.dat' usin (\$0-0.0):1 w boxes fill patter 5 lw 1 title "lkl-musl",\
   '' usin (\$0-0.0):1:2 w yerrorb  notitle, \
   '${OUTPUT}/tcp-rr-musl-skbpre.dat' usin (\$0+0.2):1 w boxes fill patter 6 title "lkl-musl (skb-prealloc)",\
   '' usin (\$0+0.2):1:2 w yerrorb  notitle ,\
   '${OUTPUT}/tcp-rr-native.dat' usin (\$0+0.4):1 w boxes fill patter 3 title "native",\
   '' usin (\$0+0.4):1:2 w yerrorb  notitle

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/tcp-rr.png"
replot


set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/udp-stream.eps"
set ylabel "Goodput (Mbps)"

plot \
   '${OUTPUT}/udp-stream-hijack-tap.dat' usin (\$0-0.4):1 w boxes fill patter 0 title "hijack(tap)" , \
   '' usin (\$0-0.4):1:2 w yerror  notitle , \
   '${OUTPUT}/udp-stream-hijack-raw.dat' usin (\$0-0.2):1 w boxes fill patter 1 title "hijack(raw)",\
   '' usin (\$0-0.2):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-musl.dat' usin (\$0-0.0):1 w boxes fill patter 5 lw 1 title "lkl-musl",\
   '' usin (\$0-0.0):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):1 w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '' usin (\$0-0.2):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-native-sendmmsg.dat' usin (\$0+0.4):1 w boxes fill patter 3 title "native (sendmmsg)",\
   '' usin (\$0+0.4):1:2 w yerrorb  notitle

   #'${OUTPUT}/udp-stream-musl-skbpre.dat' usin (\$0-0.1):2 w boxes  title "lkl-musl (skb prealloc)", \
   #'${OUTPUT}/udp-stream-native.dat' usin (\$0+0.4):2 w boxes  title "native"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/udp-stream-pps.eps"
set ylabel "Throughput (pps)"

plot \
   '${OUTPUT}/udp-stream-pps-hijack-tap.dat' usin (\$0-0.4):1 w boxes fill patter 0 title "hijack(tap)" , \
   '' usin (\$0-0.4):1:2 w yerror  notitle , \
   '${OUTPUT}/udp-stream-pps-hijack-raw.dat' usin (\$0-0.2):1 w boxes fill patter 1 title "hijack(raw)",\
   '' usin (\$0-0.2):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-pps-musl.dat' usin (\$0-0.0):1 w boxes fill patter 5 lw 1 title "lkl-musl",\
   '' usin (\$0-0.0):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-pps-musl-sendmmsg.dat' usin (\$0+0.2):1 w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '' usin (\$0-0.2):1:2 w yerrorb  notitle, \
   '${OUTPUT}/udp-stream-pps-native-sendmmsg.dat' usin (\$0+0.4):1 w boxes fill patter 3 title "native (sendmmsg)",\
   '' usin (\$0+0.4):1:2 w yerrorb  notitle

#plot \
#   '${OUTPUT}/udp-stream-hijack-tap.dat' usin (\$0-0.4):(\$4/\$5) w boxes  title "hijack(tap)", \
#   '${OUTPUT}/udp-stream-hijack-raw.dat' usin (\$0-0.2):(\$4/\$5) w boxes  title "hijack(raw)", \
#   '${OUTPUT}/udp-stream-musl.dat' usin (\$0-0.0):(\$4/\$5) w boxes  title "lkl-musl", \
#   '${OUTPUT}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):(\$4/\$5) w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
#   '${OUTPUT}/udp-stream-native-sendmmsg.dat' usin (\$0+0.4):(\$4/\$5) w boxes  title "native (sendmmsg)"


set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

