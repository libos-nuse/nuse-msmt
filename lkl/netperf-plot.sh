
OUTPUT=$1
PKG_SIZES="64 128 256 512 1024 1500 2048"


# parse outputs

grep -h bits ${OUTPUT}/netperf-TCP_ST*-hijack* > ${OUTPUT}/tcp-stream-hijack.dat
grep -E -h bits ${OUTPUT}/netperf-TCP_ST*-musl-[0-9].* > ${OUTPUT}/tcp-stream-musl.dat
grep -h bits ${OUTPUT}/netperf-TCP_ST*-musl-skbpre* > ${OUTPUT}/tcp-stream-musl-skbpre.dat
grep -h bits ${OUTPUT}/netperf-TCP_ST*-musl-sendmmsg* > ${OUTPUT}/tcp-stream-musl-sendmmsg.dat
grep -h bits ${OUTPUT}/netperf-TCP_ST*-native* > ${OUTPUT}/tcp-stream-native.dat


grep -h Trans ${OUTPUT}/netperf-TCP_RR*-hijack* > ${OUTPUT}/tcp-rr-hijack.dat
grep -E -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-[0-9].* > ${OUTPUT}/tcp-rr-musl.dat
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-skbpre* > ${OUTPUT}/tcp-rr-musl-skbpre.dat
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-musl-sendmmsg* > ${OUTPUT}/tcp-rr-musl-sendmmsg.dat
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-native* > ${OUTPUT}/tcp-rr-native.dat


grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack* > ${OUTPUT}/udp-stream-hijack.dat
grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-musl-[0-9].* > ${OUTPUT}/udp-stream-musl.dat
grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-skbpre* > ${OUTPUT}/udp-stream-musl-skbpre.dat
grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl-sendmmsg* > ${OUTPUT}/udp-stream-musl-sendmmsg.dat
grep -E -h bits ${OUTPUT}/netperf-UDP_ST*-native-[0-9]* > ${OUTPUT}/udp-stream-native.dat
grep -h bits ${OUTPUT}/netperf-UDP_ST*-native-mmsg* > ${OUTPUT}/udp-stream-native-sendmmsg.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/tcp-stream.eps"
set yrange [0:]
set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set key left top
set boxwidth 0.2
set style fill pattern

set datafile separator "," 

set ylabel "Goodput (Mbps)"
plot \
   '${OUTPUT}/tcp-stream-hijack.dat' usin (\$0-0.4):5 w boxes  title "hijack", \
   '${OUTPUT}/tcp-stream-musl.dat' usin (\$0-0.2):5 w boxes  title "lkl-musl", \
   '${OUTPUT}/tcp-stream-musl-skbpre.dat' usin (\$0+0.0):5 w boxes  title "lkl-musl (skb prealloc)", \
   '${OUTPUT}/tcp-stream-musl-sendmmsg.dat' usin (\$0+0.2):5 w boxes  title "lkl-musl (sendmmsg)", \
   '${OUTPUT}/tcp-stream-native.dat' usin (\$0+0.4):5 w boxes  title "native"

set xtics ("64" 0, "128" 1, "256" 2, "512" 3, "1024" 4, "1500" 5, "2048" 6, "65507" 7)
set xlabel "Payload size (bytes)"
set xrange [-1:8]
set output "${OUTPUT}/tcp-rr.eps"
set ylabel "Goodput (Trans/sec)"

plot \
   '${OUTPUT}/tcp-rr-hijack.dat' usin (\$0-0.3):8 w boxes  title "hijack", \
   '${OUTPUT}/tcp-rr-musl.dat' usin (\$0-0.1):8 w boxes  title "lkl-musl", \
   '${OUTPUT}/tcp-rr-musl-skbpre.dat' usin (\$0+0.1):8 w boxes  title "lkl-musl (skb prealloc)", \
   '${OUTPUT}/tcp-rr-native.dat' usin (\$0+0.3):8 w boxes  title "native"

set output "${OUTPUT}/udp-stream.eps"
set ylabel "Goodput (Mbps)"

plot \
   '${OUTPUT}/udp-stream-hijack.dat' usin (\$0-0.3):2 w boxes  title "hijack", \
   '${OUTPUT}/udp-stream-musl.dat' usin (\$0-0.1):2 w boxes  title "lkl-musl", \
   '${OUTPUT}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.1):2 w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/udp-stream-native-sendmmsg.dat' usin (\$0+0.3):2 w boxes  title "native (sendmmsg)"

   #'${OUTPUT}/udp-stream-musl-skbpre.dat' usin (\$0-0.1):2 w boxes  title "lkl-musl (skb prealloc)", \
   #'${OUTPUT}/udp-stream-native.dat' usin (\$0+0.4):2 w boxes  title "native"


set output "${OUTPUT}/udp-stream-pps.eps"
set ylabel "Throughput (pps)"

plot \
   '${OUTPUT}/udp-stream-hijack.dat' usin (\$0-0.3):(\$4/\$5) w boxes  title "hijack", \
   '${OUTPUT}/udp-stream-musl.dat' usin (\$0-0.1):(\$4/\$5) w boxes  title "lkl-musl", \
   '${OUTPUT}/udp-stream-musl-sendmmsg.dat' usin (\$0+0.1):(\$4/\$5) w boxes  title "lkl-musl (sendmmsg+skb prealloc)", \
   '${OUTPUT}/udp-stream-native-sendmmsg.dat' usin (\$0+0.3):(\$4/\$5) w boxes  title "native (sendmmsg)"


# set terminal png lw 3 16
# set xtics nomirror rotate by -45 font ",16"
# set output "rtt-bytes.png"
# replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

