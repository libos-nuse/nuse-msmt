
PREFIX=netperf-bbr

# read vals
source ./netperf-common.sh

OUTPUT=$1
mkdir -p ${OUTPUT}/out

# override variables
QDISC_PARAMS="root|fq"

rm -f ${OUTPUT}/tcp-stream-hijack-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-musl-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-qemu-tap-*.dat
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

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-qemu-tap*$mem*$tcp_wmem-$qdisc_params*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e $mem mem \
| dbcolcreate -e $tcp_wmem tcp_wmem \
| dbcolcreate -e $qdisc_params qdisc \
>> ${OUTPUT}/tcp-stream-qemu-tap-$cc-$qdisc-$mem.dat

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

# nofq/nohrt plots

PREFIX=netperf-bbr-nohrt
grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap-nohrt-fq* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e "no-hrtimer,fq" mode \
>> ${OUTPUT}/tcp-stream-musl-tap-hrt-fq.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap-hrt-nofq* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e "hrtimer,no-fq" mode \
>> ${OUTPUT}/tcp-stream-musl-tap-hrt-fq.dat

#grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-hijack-tap-hrt-fq* \
#reuse from previous experiments
#grep -h bits ${OUTPUT}/netperf-bbr-TCP_ST*-hijack-tap-*-${SYS_MEM}-100000000-root\|fq-bbr*\
grep -h bits ${OUTPUT}/netperf-bbr-nohrt-TCP_ST*-musl-tap*-hrt-fq-*-10000M-400000000-root\|fq-bbr*\
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcol mean stddev \
| dbcolcreate -e "hrtimer,fq" mode \
>> ${OUTPUT}/tcp-stream-musl-tap-hrt-fq.dat

#generate latex table
cat ${OUTPUT}/tcp-stream-musl-tap-hrt-fq.dat | dbcol mode mean stddev | \
 grep -v "^#" | sed "s/\s/ \& /g" | sed "s/\$/ \\\\\\\\ \\\hline/" \
 > ${OUTPUT}/tcp-stream-musl-hrt-fq.tbl


gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-stream-${SYS_MEM}-fq.eps"
set yrange [0:]
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.1
set style fill pattern
set key top left
set size 1.0,0.6


set xrange [-1:4]
set yrange [:10]
set ylabel "Goodput (Gbps)"
set xlabel "size of sock tx buffer (bytes)"
set xtics ("4M" 0, "30M" 1, "100M" 2, "2G" 3)


plot \
   '${OUTPUT}/tcp-stream-musl-tap-bbr-fq-${SYS_MEM}.dat' usin (\$0-0.25):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL(bbr)", \
   '${OUTPUT}/tcp-stream-musl-tap-cubic-fq-${SYS_MEM}.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL(cubic)" ,\
   '${OUTPUT}/tcp-stream-qemu-tap-bbr-fq-${SYS_MEM}.dat' usin (\$0-0.05):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL-qemu(bbr)", \
   '${OUTPUT}/tcp-stream-qemu-tap-cubic-fq-${SYS_MEM}.dat' usin (\$0+0.05):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL-qemu(cubic)" ,\
   '${OUTPUT}/tcp-stream-native-bbr-fq-${SYS_MEM}.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "Linux(bbr)", \
   '${OUTPUT}/tcp-stream-native-cubic-fq-${SYS_MEM}.dat' usin (\$0+0.25):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "Linux(cubic)" 

   #'${OUTPUT}/tcp-stream-hijack-tap-bbr-fq-${SYS_MEM}.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL(bbr)", \
   #'${OUTPUT}/tcp-stream-hijack-tap-cubic-fq-${SYS_MEM}.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 title "LKL(cubic)" ,\

#   '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-${SYS_MEM}.dat' usin (\$0-0.15):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
#   '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-${SYS_MEM}.dat' usin (\$0-0.05):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
#   '${OUTPUT}/tcp-stream-native-bbr-none-${SYS_MEM}.dat' usin (\$0+0.25):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
#   '${OUTPUT}/tcp-stream-native-cubic-none-${SYS_MEM}.dat' usin (\$0+0.35):1:2 w boxerrorbar fill patter 0 title "cubic (native)"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-stream-${SYS_MEM}-fq.png"
replot


set terminal dumb
unset output
replot

## set output "${OUTPUT}/out/tcp-stream-${SYS_MEM}-nofq.eps"
## plot \
##    '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-${SYS_MEM}.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
##    '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-${SYS_MEM}.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
##    '${OUTPUT}/tcp-stream-native-bbr-none-${SYS_MEM}.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
##    '${OUTPUT}/tcp-stream-native-cubic-none-${SYS_MEM}.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"
## 
##    #'${OUTPUT}/tcp-stream-musl-tap-bbr-none-${SYS_MEM}.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=1G)", \
##    #'${OUTPUT}/tcp-stream-musl-tap-cubic-none-${SYS_MEM}.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=1G)" ,\
## 
## set terminal png lw 3 14 crop
## set output "${OUTPUT}/out/tcp-stream-${SYS_MEM}-nofq.png"
## replot
## 
## set output "${OUTPUT}/out/tcp-stream-512M-fq.eps"
## plot \
##    '${OUTPUT}/tcp-stream-hijack-tap-bbr-fq-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
##    '${OUTPUT}/tcp-stream-hijack-tap-cubic-fq-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
##    '${OUTPUT}/tcp-stream-native-bbr-fq-512M.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
##    '${OUTPUT}/tcp-stream-native-cubic-fq-512M.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"
## 
##    #'${OUTPUT}/tcp-stream-musl-tap-bbr-fq-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
##    #'${OUTPUT}/tcp-stream-musl-tap-cubic-fq-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
## 
## set terminal png lw 3 14 crop
## set output "${OUTPUT}/out/tcp-stream-512M-rq.png"
## replot
## 
## set output "${OUTPUT}/out/tcp-stream-512M-nofq.eps"
## plot \
##    '${OUTPUT}/tcp-stream-hijack-tap-bbr-none-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
##    '${OUTPUT}/tcp-stream-hijack-tap-cubic-none-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
##    '${OUTPUT}/tcp-stream-native-bbr-none-512M.dat' usin (\$0+0.1):1:2 w boxerrorbar fill patter 0 title "bbr (native)", \
##    '${OUTPUT}/tcp-stream-native-cubic-none-512M.dat' usin (\$0+0.3):1:2 w boxerrorbar fill patter 0 title "cubic (native)"
## 
##    #'${OUTPUT}/tcp-stream-musl-tap-bbr-none-512M.dat' usin (\$0-0.3):1:2 w boxerrorbar fill patter 0 title "bbr (lkl,sysmem=512M)", \
##    #'${OUTPUT}/tcp-stream-musl-tap-cubic-none-512M.dat' usin (\$0-0.1):1:2 w boxerrorbar fill patter 0 title "cubic (lkl,sysmem=512M)" ,\
## 
## set terminal png lw 3 14 crop
## set output "${OUTPUT}/out/tcp-stream-512M-nofq.png"
## replot
## 



# nohrt/nofq test
set output "${OUTPUT}/out/tcp-stream-bbr-hrt-fq.eps"
set boxwidth 0.2
unset yrange
reset xtics
set xrange [-1:3]
set xlabel ""

plot \
   '${OUTPUT}/tcp-stream-musl-tap-hrt-fq.dat' usin 0:1:2:xtic(3) w boxerrorbar notitle

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-stream-bbr-hrt-fq.png"
replot

quit
EndGNUPLOT

