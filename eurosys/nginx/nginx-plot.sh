
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
grep -E -h Req/Sec  ${OUTPUT}/nginx*-docker-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/k/ 1000/g" | awk '{print $1*$2*2 " " $3}' \
 > ${OUTPUT}/nginx-docker-thpt.dat
# latency
grep -E -h Latency ${OUTPUT}/nginx*-lkl-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-lkl.dat
grep -E -h Latency ${OUTPUT}/nginx*-native-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-native.dat
grep -E -h Latency ${OUTPUT}/nginx*-docker-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-docker.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.3
set style fill pattern
set key top righ
set size 1.0,0.7

# trans/sec
set ylabel "Throughput (KReq/sec)"
set ytics 5
set yrange [0:20]
set xtics ("64" 0, "128" 1, "256" 2, "512" 3, "1024" 4, "1500" 5, "2048" 6)
set xlabel "File size (bytes)"
set xrange [-1:7]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk-thpt.eps"

plot \
   '${OUTPUT}/nginx-docker-thpt.dat' usi (\$0-0.3):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb "green" fill pattern 2 title "docker(mac)" ,\
   '${OUTPUT}/nginx-lkl-thpt.dat' usi (\$0-0):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "lkl", \
   '${OUTPUT}/nginx-native-thpt.dat' usi (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr fill pattern 0 lt 1 lc rgb "red" title "native(mac)" 

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/nginx-wrk-thpt.png"
replot

# latency
set ylabel "Latency (msec)"
set ytics 1
set yrange [0:3.5]
set xtics ("64" 0, "128" 1, "256" 2, "512" 3, "1024" 4, "1500" 5, "2048" 6)
set xlabel "File size (bytes)"
set xrange [-1:7]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk-latency.eps"

plot \
   '${OUTPUT}/nginx-docker.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerr fill pattern 2 lt 1 lc rgb "green"  title "docker(mac)" ,\
   '${OUTPUT}/nginx-lkl.dat' usin (\$0-0):(\$1/1000):(\$2/1000) w boxerr fill pattern 4 lt 1 lc rgb "cyan" title "lkl", \
   '${OUTPUT}/nginx-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr fill pattern 0 lt 1 lc rgb "red" title "native(mac)" 

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/nginx-wrk-latency.png"
replot

# combined
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
set output "${OUTPUT}/out/nginx-wrk-combined.eps"

plot \
   '${OUTPUT}/nginx-docker-thpt.dat' usi (\$0-0.3):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb "green" fill pattern 2 title "docker(mac)" ,\
   '${OUTPUT}/nginx-lkl-thpt.dat' usi (\$0-0):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "lkl", \
   '${OUTPUT}/nginx-native-thpt.dat' usi (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb "red" fill pattern 0 title "native(mac)" ,\
   '${OUTPUT}/nginx-docker.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "green" ax x1y2 notitle ,\
   '${OUTPUT}/nginx-lkl.dat' usin (\$0-0):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "cyan" ax x1y2 notitle, \
   '${OUTPUT}/nginx-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "red" ax x1y2 notitle

set terminal png lw 3 14 crop
set xtics nomirror font ",14"
set output "${OUTPUT}/out/nginx-wrk-combined.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

