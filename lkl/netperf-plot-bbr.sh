
OUTPUT=$1
PREFIX=netperf
mkdir -p ${OUTPUT}

# parse outputs

# TCP_STREAM
SYS_MEM="512M 1G"
TCP_WMEM="4194304 1000000000 2147483647"
QDISC_PARAMS="root|fq"
CC_ALGO="bbr cubic"

rm -f ${OUTPUT}/tcp-stream-hijack-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-native-*.dat

for mem in ${SYS_MEM}
do
for tcp_wmem in ${TCP_WMEM}
do
for cc in ${CC_ALGO}
do

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-tap*$mem*$tcp_wmem*$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
>> ${OUTPUT}/tcp-stream-hijack-tap-$cc-$mem.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native*$mem*$tcp_wmem*$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
>> ${OUTPUT}/tcp-stream-native-$cc-$mem.dat

done
done
done

## grep -E -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native-[0-9]* \
## | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
## | dbcolstats thpt | dbcol mean stddev \
## > ${OUTPUT}/${DIR}/tcp-stream-native.dat

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


set xrange [-1:3]
set yrange [:10000]
set ylabel "Goodput (Mbps)"
set xlabel "size of sock tx buffer (bytes)"
set xtics ("4M" 0, "1G" 1, "2.1G" 2)


plot \
   '${OUTPUT}/tcp-stream-hijack-tap-bbr-1G.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
   '${OUTPUT}/tcp-stream-hijack-tap-cubic-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-1G.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
   '${OUTPUT}/tcp-stream-native-cubic-1G.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"

#   '${OUTPUT}/tcp-stream-hijack-tap-bbr-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (sysmem=512M)", \
#   '${OUTPUT}/tcp-stream-hijack-tap-cubic-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (sysmem=512M)" ,\

set terminal png lw 3 14
set output "${OUTPUT}/tcp-stream.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

