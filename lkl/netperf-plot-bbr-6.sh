
source ./netperf-common.sh

OUTPUT=$1
PREFIX=netperf6
mkdir -p ${OUTPUT}


# override
SYS_MEM="1G"
TCP_WMEM="100000000"
QDISC_PARAMS="root|fq"
CC_ALGO="bbr"
OFFLOADS="0 d903" #disable, CSUM/TSO4/MRGRCVBUF/UFO + TSO6

rm -f ${OUTPUT}/${PREFIX}-tcp6-stream-hijack-tap-*.dat
rm -f ${OUTPUT}/${PREFIX}-tcp6-stream-native-*.dat

for mem in ${SYS_MEM}
do
for tcp_wmem in ${TCP_WMEM}
do
for cc in ${CC_ALGO}
do
for qdisc_params in ${QDISC_PARAMS}
do
for off in ${OFFLOADS}
do

qdisc=${qdisc_params/root\|/}

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-tap*$mem*$tcp_wmem-$qdisc_params*-$cc-off$off* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/${PREFIX}-tcp6-stream-hijack-tap-$cc-$qdisc-$mem.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native*$mem*$tcp_wmem-$qdisc_params*-$cc-off$off* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/${PREFIX}-tcp6-stream-native-$cc-$qdisc-$mem.dat

done
done
done
done
done

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/${DIR}/tcp6-stream-1G-fq.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern
set size 1.0,0.6


set xrange [-1:2]
set yrange [:10000]
set ylabel "Goodput (Mbps)"
set xlabel "Offload features"
set xtics ("disable" 0, "TSO6" 1)


plot \
   '${OUTPUT}/${PREFIX}-tcp6-stream-hijack-tap-bbr-fq-1G.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "LKL", \
   '${OUTPUT}/${PREFIX}-tcp6-stream-native-bbr-fq-1G.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "Linux"

set terminal png lw 3 14
set output "${OUTPUT}/tcp6-stream-1G-fq.png"
replot


set terminal dumb
unset output
replot


quit
EndGNUPLOT

