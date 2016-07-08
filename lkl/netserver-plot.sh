
OUTPUT=$1
mkdir -p ${OUTPUT}/rx


# parse outputs

grep -h bits ${OUTPUT}/netserver-TCP_ST*-hijack-tap* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-hijack-tap.dat

grep -h bits ${OUTPUT}/netserver-TCP_ST*-hijack-raw* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
 > ${OUTPUT}/rx/tcp-stream-hijack-raw.dat

grep -E -h bits ${OUTPUT}/netserver-TCP_ST*-musl-[0-9].* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-musl.dat

grep -h bits ${OUTPUT}/netserver-TCP_ST*-musl-skbpre* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-musl-skbpre.dat

grep -h bits ${OUTPUT}/netserver-TCP_ST*-musl-sendmmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-musl-sendmmsg.dat

grep -E -h bits ${OUTPUT}/netserver-TCP_ST*-native-[0-9]* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-native.dat

grep -h bits ${OUTPUT}/netserver-TCP_ST*-native-mmsg* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
> ${OUTPUT}/rx/tcp-stream-native-sendmmsg.dat


grep -h Trans ${OUTPUT}/netserver-TCP_RR*-hijack-tap* > ${OUTPUT}/rx/tcp-rr-hijack-tap.dat
grep -h Trans ${OUTPUT}/netserver-TCP_RR*-hijack-raw* > ${OUTPUT}/rx/tcp-rr-hijack-raw.dat
grep -E -h Trans ${OUTPUT}/netserver-TCP_RR*-musl-[0-9].* > ${OUTPUT}/rx/tcp-rr-musl.dat
grep -h Trans ${OUTPUT}/netserver-TCP_RR*-musl-skbpre* > ${OUTPUT}/rx/tcp-rr-musl-skbpre.dat
grep -h Trans ${OUTPUT}/netserver-TCP_RR*-musl-sendmmsg* > ${OUTPUT}/rx/tcp-rr-musl-sendmmsg.dat
grep -E -h Trans ${OUTPUT}/netserver-TCP_RR*-native-[0-9]* > ${OUTPUT}/rx/tcp-rr-native.dat
grep -E -h Trans ${OUTPUT}/netserver-TCP_RR*-native-mmsg* > ${OUTPUT}/rx/tcp-rr-native-sendmmsg.dat


grep -h bits ${OUTPUT}/netserver-UDP_ST*-hijack-tap* > ${OUTPUT}/rx/udp-stream-hijack-tap.dat
grep -h bits ${OUTPUT}/netserver-UDP_ST*-hijack-raw* > ${OUTPUT}/rx/udp-stream-hijack-raw.dat
grep -E -h bits ${OUTPUT}/netserver-UDP_ST*-musl-[0-9].* > ${OUTPUT}/rx/udp-stream-musl.dat
grep -h bits ${OUTPUT}/netserver-UDP_ST*-musl-skbpre* > ${OUTPUT}/rx/udp-stream-musl-skbpre.dat
grep -h bits ${OUTPUT}/netserver-UDP_ST*-musl-sendmmsg* > ${OUTPUT}/rx/udp-stream-musl-sendmmsg.dat
grep -E -h bits ${OUTPUT}/netserver-UDP_ST*-native-[0-9]* > ${OUTPUT}/rx/udp-stream-native.dat
grep -h bits ${OUTPUT}/netserver-UDP_ST*-native-mmsg* > ${OUTPUT}/rx/udp-stream-native-sendmmsg.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/rx/tcp-stream.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern


set ylabel "Rx Goodput (Mbps)"
unset xlabel 
unset xtics
plot \
   '${OUTPUT}/rx/tcp-stream-hijack-tap.dat' usin 1:2 w boxerror  title "hijack(tap)"

#, \
#   '${OUTPUT}/rx/tcp-stream-hijack-raw.dat' usin (\$0-0.3):1:2 w boxerror  title "hijack(raw)", \
#   '${OUTPUT}/rx/tcp-stream-musl.dat' usin (\$0-0.1):1:2 w boxerror  title "lkl-musl", \
#   '${OUTPUT}/rx/tcp-stream-musl-skbpre.dat' usin (\$0+0.1):1:2 w boxerror  title "lkl-musl (skb prealloc)", \
#   '${OUTPUT}/rx/tcp-stream-musl-sendmmsg.dat' usin (\$0+0.3):1:2 w boxerror  title "lkl-musl (sendmmsg)", \
#   '${OUTPUT}/rx/tcp-stream-native.dat' usin (\$0+0.5):1:2 w boxerror  title "native"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/rx/tcp-stream.png"
replot


set datafile separator "," 

set xtics ("1" 0, "64" 1, "128" 2, "256" 3, "512" 4, "1024" 5, "1500" 6, "2048" 7, "65507" 8)
set xlabel "Payload size (bytes)"
set xrange [-1:9]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/rx/tcp-rr.eps"
set ylabel "Rx Goodput (Trans/sec)"

plot \
   '${OUTPUT}/rx/tcp-rr-hijack-tap.dat' usin (\$0-0.4):8 w boxes  title "hijack(tap)", \
   '${OUTPUT}/rx/tcp-rr-hijack-raw.dat' usin (\$0-0.2):8 w boxes  title "hijack(raw)", \
   '${OUTPUT}/rx/tcp-rr-musl.dat' usin (\$0-0.0):8 w boxes  title "lkl-musl", \
   '${OUTPUT}/rx/tcp-rr-musl-skbpre.dat' usin (\$0+0.2):8 w boxes  title "lkl-musl (skb prealloc)", \
   '${OUTPUT}/rx/tcp-rr-native.dat' usin (\$0+0.4):8 w boxes  title "native"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/rx/tcp-rr.png"
replot


set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/rx/udp-stream.eps"
set ylabel "Rx Goodput (Mbps)"

plot \
   '${OUTPUT}/rx/udp-stream-hijack-tap.dat' usin (\$0-0.4):2 w boxes  title "hijack(tap)", \
   '${OUTPUT}/rx/udp-stream-hijack-raw.dat' usin (\$0-0.2):2 w boxes  title "hijack(raw)", \
   '${OUTPUT}/rx/udp-stream-musl.dat' usin (\$0-0.0):2 w boxes  title "lkl-musl", \
   '${OUTPUT}/rx/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):2 w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/rx/udp-stream-native-sendmmsg.dat' usin (\$0+0.4):2 w boxes  title "native (sendmmsg)"

   #'${OUTPUT}/udp-stream-musl-skbpre.dat' usin (\$0-0.1):2 w boxes  title "lkl-musl (skb prealloc)", \
   #'${OUTPUT}/udp-stream-native.dat' usin (\$0+0.4):2 w boxes  title "native"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/rx/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/rx/udp-stream-pps.eps"
set ylabel "Rx Throughput (pps)"

plot \
   '${OUTPUT}/rx/udp-stream-hijack-tap.dat' usin (\$0-0.4):(\$4/\$5) w boxes  title "hijack(tap)", \
   '${OUTPUT}/rx/udp-stream-hijack-raw.dat' usin (\$0-0.2):(\$4/\$5) w boxes  title "hijack(raw)", \
   '${OUTPUT}/rx/udp-stream-musl.dat' usin (\$0-0.0):(\$4/\$5) w boxes  title "lkl-musl", \
   '${OUTPUT}/rx/udp-stream-musl-sendmmsg.dat' usin (\$0+0.2):(\$4/\$5) w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/rx/udp-stream-native-sendmmsg.dat' usin (\$0+0.4):(\$4/\$5) w boxes  title "native (sendmmsg)"


set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/rx/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

