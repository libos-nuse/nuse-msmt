
OUTPUT=$1

# parse outputs

grep -h bits ${OUTPUT}/netperf-TCP_ST*-hijack* > ${OUTPUT}/tcp-stream-hijack.dat
grep -h bits ${OUTPUT}/netperf-TCP_ST*-musl* > ${OUTPUT}/tcp-stream-musl.dat
grep -h bits ${OUTPUT}/netperf-TCP_ST*-native* > ${OUTPUT}/tcp-stream-native.dat

grep -h Trans ${OUTPUT}/netperf-TCP_RR*-hijack* > ${OUTPUT}/tcp-rr-hijack.dat
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-musl* > ${OUTPUT}/tcp-rr-musl.dat
grep -h Trans ${OUTPUT}/netperf-TCP_RR*-native* > ${OUTPUT}/tcp-rr-native.dat

grep -h bits ${OUTPUT}/netperf-UDP_ST*-hijack* > ${OUTPUT}/udp-stream-hijack.dat
grep -h bits ${OUTPUT}/netperf-UDP_ST*-musl* > ${OUTPUT}/udp-stream-musl.dat
grep -h bits ${OUTPUT}/netperf-UDP_ST*-native* > ${OUTPUT}/udp-stream-native.dat

grep -h bits ${OUTPUT}/netperf-omni*-hijack* > ${OUTPUT}/omni-hijack.dat
grep -h bits ${OUTPUT}/netperf-omni*-musl* > ${OUTPUT}/omni-musl.dat
grep -h bits ${OUTPUT}/netperf-omni*-native* > ${OUTPUT}/omni-native.dat

gnuplot  << EndGNUPLOT
set ylabel "Goodput (Mbps)"
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/tcp-stream.eps"
set yrange [0:]
set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set key left top
set boxwidth 0.1
set style fill pattern

set datafile separator "," 

plot \
   '${OUTPUT}/tcp-stream-hijack.dat' usin (\$0-0.1):5 w boxes  title "hijack", \
   '${OUTPUT}/tcp-stream-musl.dat' usin 0:5 w boxes  title "lkl-musl", \
   '${OUTPUT}/tcp-stream-native.dat' usin (\$0+0.1):5 w boxes  title "native"

set output "${OUTPUT}/omni.eps"
plot \
   '${OUTPUT}/omni-hijack.dat' usin (\$0-0.1):5 w boxes  title "hijack", \
   '${OUTPUT}/omni-musl.dat' usin 0:5 w boxes  title "lkl-musl", \
   '${OUTPUT}/omni-native.dat' usin (\$0+0.1):5 w boxes  title "native"

set output "${OUTPUT}/udp-stream.eps"
plot \
   '${OUTPUT}/udp-stream-hijack.dat' usin (\$0-0.1):5 w boxes  title "hijack", \
   '${OUTPUT}/udp-stream-musl.dat' usin 0:5 w boxes  title "lkl-musl", \
   '${OUTPUT}/udp-stream-native.dat' usin (\$0+0.1):5 w boxes  title "native"

set output "${OUTPUT}/tcp-rr.eps"
set ylabel "Goodput (Trans/sec)"
plot \
   '${OUTPUT}/tcp-rr-hijack.dat' usin (\$0-0.1):8 w boxes  title "hijack", \
   '${OUTPUT}/tcp-rr-musl.dat' usin 0:8 w boxes  title "lkl-musl", \
   '${OUTPUT}/tcp-rr-native.dat' usin (\$0+0.1):8 w boxes  title "native"

# set terminal png lw 3 16
# set xtics nomirror rotate by -45 font ",16"
# set output "rtt-bytes.png"
# replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

