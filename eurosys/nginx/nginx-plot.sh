
OUTPUT=$1
mkdir -p ${OUTPUT}/out

PKG_SIZES="64 128 256 512 1024 1500 2048"


# parse outputs

# thpt (req/sec)
grep -E -h Req/Sec  ${OUTPUT}/nginx*-lkl-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-lkl-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-native-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-native-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-runc-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-runc-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-kata-runtime-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-kata-runtime-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-runsc-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-runsc-thpt.dat
# latency
grep -E -h Latency ${OUTPUT}/nginx*-lkl-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-lkl.dat
grep -E -h Latency ${OUTPUT}/nginx*-native-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-native.dat
grep -E -h Latency ${OUTPUT}/nginx*-runc-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-runc.dat
grep -E -h Latency ${OUTPUT}/nginx*-kata-runtime-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-kata-runtime.dat
grep -E -h Latency ${OUTPUT}/nginx*-runsc-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-runsc.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.3
set style fill pattern
set key top left
set size 1.0,0.7

set ylabel "Throughput (KReq/sec)"
set ytics 5
set yrange [0:20]
set y2label "Latency (msec)"
set y2tics 5
set y2range [0:]
set xtics ("64" 0, "128" 1, "256" 2, "512" 3, "1024" 4, "1500" 5, "2048" 6)
set xlabel "File size (bytes)"
set xrange [-1:7]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"

plot \
   '${OUTPUT}/nginx-runc-thpt.dat' usi (\$0-0.3):(\$1/1000):(\$2/1000) w boxerr lc rgb "green" title "runc", \
   '${OUTPUT}/nginx-kata-runtime-thpt.dat' usi (\$0-0.1):(\$1/1000):(\$2/1000) w boxerr lc rgb "gray" title "kata-runtime", \
   '${OUTPUT}/nginx-runsc-thpt.dat' usi (\$0+0.1):(\$1/1000):(\$2/1000) w boxerr lc rgb "blue" title "runsc", \
   '${OUTPUT}/nginx-native-thpt.dat' usi (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr lc rgb "red" title "native", \
   '${OUTPUT}/nginx-lkl-thpt.dat' usi (\$0+0.5):(\$1/1000):(\$2/1000) w boxerr lc rgb "cyan" title "lkl", \
   '${OUTPUT}/nginx-runc.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "green" ax x1y2 notitle ,\
   '${OUTPUT}/nginx-kata-runtime.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "gray" ax x1y2 notitle ,\
   '${OUTPUT}/nginx-runsc.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "blue" ax x1y2 notitle ,\
   '${OUTPUT}/nginx-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "red" ax x1y2 notitle ,\
   '${OUTPUT}/nginx-lkl.dat' usin (\$0+0.5):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "cyan" ax x1y2 notitle

set terminal png lw 3 14 crop
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/out/nginx-wrk.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

