#!/bin/bash

OUTPUT=$1
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE:-$0})" ; pwd )

if [ -z $OUTPUT ] ; then
	echo "missing output dir"
	exit
fi

PROG="hello nginx python"

# data convertion
echo " " > $OUTPUT/mem-footprint.tbl

RUNC_DAT=""
KATA_DAT=""
GVISOR_DAT=""
RUNU_DAT=""

for prog in $PROG
do

RUNU=$(cat ${OUTPUT}/mem-runu-$prog.log | grep -v docker |grep -v tee| grep -v grep | awk '{print $6/1000}')
GVISOR=$(cat ${OUTPUT}/mem-gvisor-$prog.log | grep runsc-sandbox | grep -v grep | awk '{printf "%.3f", $6/1000}')
KATA=$(cat ${OUTPUT}/mem-kata-$prog.log | grep qemu-lite-system | grep -v grep | awk '{printf "%.3f", $6/1000}')
RUNC=$(cat ${OUTPUT}/mem-runc-$prog.log | grep -v docker |grep -v tee | grep -v grep | awk '{print $6/1000}')

RUNU_ALL=$(cat ${OUTPUT}/mem-runu-$prog.log |grep -v tee | awk '{sum += $6}END{print sum/1000}')
GVISOR_ALL=$(cat ${OUTPUT}/mem-gvisor-$prog.log | grep -v tee | awk '{sum += $6}END{print sum/1000}')
KATA_ALL=$(cat ${OUTPUT}/mem-kata-$prog.log | grep -v tee | awk '{sum += $6}END{print sum/1000}')
RUNC_ALL=$(cat ${OUTPUT}/mem-runc-$prog.log | grep -v tee | awk '{sum += $6}END{print sum/1000}')


# for latex table
echo " $prog & $RUNC &  $KATA & $GVISOR &  $RUNU \\\\" >> $OUTPUT/mem-footprint.tbl
#echo " $prog (total) & $RUNC_ALL &  $KATA_ALL & $GVISOR_ALL &  $RUNU_ALL \\\\" >> $OUTPUT/mem-footprint.tbl

# for gnuplot
RUNC_DAT=$RUNC_DAT" "${RUNC:-0}
KATA_DAT=$KATA_DAT" "${KATA:-0}
GVISOR_DAT=$GVISOR_DAT" "${GVISOR:-0}
RUNU_DAT=$RUNU_DAT" "${RUNU:-0}

done

echo "runc $RUNC_DAT" > $OUTPUT/mem-footprint.dat
echo "kata $KATA_DAT" >> $OUTPUT/mem-footprint.dat
echo "gvisor $GVISOR_DAT" >> $OUTPUT/mem-footprint.dat
echo "ukontainer $RUNU_DAT" >> $OUTPUT/mem-footprint.dat


# plot
gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/mem-footprint.eps"
set pointsize 2
set xzeroaxis
set grid

set boxwidth 0.3
set style fill pattern
#set key top center
set size 1.0,0.7

set ylabel "Memory usage (Mbyte)"
set yrange [0:200]
#set logscale y
set xtics font ", 18"
set xtics ('runc' 0, 'kata' 1, 'gvisor' 2, 'ukontainer' 3)
set xrange [-0.5:3.5]
set xtics nomirror

plot \
   '${OUTPUT}/mem-footprint.dat' usi (\$0-0.3):(\$2) w boxes lt 1 lc rgb "green" fill pattern 2 title "hello", \
   '' usi (\$0):(\$3) w boxes lt 1 lc rgb "blue" fill pattern 1 title "nginx", \
   '' usi (\$0+0.3):(\$4) w boxes lt 1 lc rgb "red" fill pattern 4 title "python"
  
set terminal png lw 3 14 crop
#set xtics nomirror rotate by -45
set output "${OUTPUT}/mem-footprint.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT


# report
echo "  & RUNC &  KATA & GVISOR &  RUNU"
cat $OUTPUT/mem-footprint.tbl
