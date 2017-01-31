
OUTPUT=$1
PREFIX=netperf-bbr
mkdir -p ${OUTPUT}

# read vals
source ./netperf-common.sh

# override variables
QDISC_PARAMS="root|fq"

rm -f ${OUTPUT}/tcp-stream-hijack-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-musl-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-native-*.dat

for mem in ${SYS_MEM}
do
for tcp_wmem in ${TCP_WMEM}
do
for cc in ${CC_ALGO}
do
for qdisc_params in ${QDISC_PARAMS}
do

qdisc=${qdisc_params/root\|/}

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-tap*$mem*$tcp_wmem-$qdisc_params*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/tcp-stream-hijack-tap-$cc-$qdisc-$mem.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap*$mem*$tcp_wmem-$qdisc_params*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/tcp-stream-musl-tap-$cc-$qdisc-$mem.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native*$mem*$tcp_wmem-$qdisc_params*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/tcp-stream-native-$cc-$qdisc-$mem.dat

done
done
done
done

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/tcp-stream-1G-fq.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern
set key top left
set size 1.0,0.6


set xrange [-1:4]
set yrange [:6000]
set ylabel "Goodput (Mbps)"
set xlabel "size of sock tx buffer (bytes)"
set xtics ("4M" 0, "30M" 1, "100M" 2, "2G" 3)


plot \
   '${OUTPUT}/tcp-stream-hijack-tap-bbr-fq-1G.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "LKL(bbr)", \
   '${OUTPUT}/tcp-stream-hijack-tap-cubic-fq-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "LKL(cubic)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-fq-1G.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "Linux(bbr)", \
   '${OUTPUT}/tcp-stream-native-cubic-fq-1G.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "Linux(cubic)" 

#   '${OUTPUT}/tcp-stream-musl-tap-bbr-fq-1G.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "LKL(bbr)", \
#   '${OUTPUT}/tcp-stream-musl-tap-cubic-fq-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "LKL(cubic)" ,\

#   '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-1G.dat' usin (\$0-0.15):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
#   '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-1G.dat' usin (\$0-0.05):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
#   '${OUTPUT}/tcp-stream-native-bbr-none-1G.dat' usin (\$0+0.25):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
#   '${OUTPUT}/tcp-stream-native-cubic-none-1G.dat' usin (\$0+0.35):1:2 w boxerrorbar fill patter 0 title "cubic (native)"


set terminal png lw 3 14
set output "${OUTPUT}/tcp-stream-1G-fq.png"
replot


set terminal dumb
unset output
replot

set output "${OUTPUT}/${DIR}/tcp-stream-1G-nofq.eps"
plot \
   '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-1G.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
   '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-none-1G.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
   '${OUTPUT}/tcp-stream-native-cubic-none-1G.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"

   #'${OUTPUT}/tcp-stream-musl-tap-bbr-none-1G.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
   #'${OUTPUT}/tcp-stream-musl-tap-cubic-none-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\

set terminal png lw 3 14
set output "${OUTPUT}/tcp-stream-1G-nofq.png"
replot

set output "${OUTPUT}/${DIR}/tcp-stream-512M-fq.eps"
plot \
   '${OUTPUT}/tcp-stream-hijack-tap-bbr-fq-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
   '${OUTPUT}/tcp-stream-hijack-tap-cubic-fq-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-fq-512M.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
   '${OUTPUT}/tcp-stream-native-cubic-fq-512M.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"

   #'${OUTPUT}/tcp-stream-musl-tap-bbr-fq-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
   #'${OUTPUT}/tcp-stream-musl-tap-cubic-fq-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\

set terminal png lw 3 14
set output "${OUTPUT}/tcp-stream-512M-rq.png"
replot

set output "${OUTPUT}/${DIR}/tcp-stream-512M-nofq.eps"
plot \
   '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
   '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-none-512M.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
   '${OUTPUT}/tcp-stream-native-cubic-none-512M.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"

   #'${OUTPUT}/tcp-stream-musl-tap-bbr-none-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
   #'${OUTPUT}/tcp-stream-musl-tap-cubic-none-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\

set terminal png lw 3 14
set output "${OUTPUT}/tcp-stream-512M-nofq.png"
replot

quit
EndGNUPLOT

