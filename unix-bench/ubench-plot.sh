#!/bin/bash

OUTPUT=$1
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE:-$0})" ; pwd )

if [ -z $OUTPUT ] ; then
	echo "missing output dir"
	exit
fi

mkdir -p $OUTPUT/plots

# data convertion
TYPES="lkl,noah,docker,macos"
for type in $(eval echo "{$TYPES}")
do
  if [ ! -s ${OUTPUT}/$type.csv ] ; then
     echo "1,0,0,0,0,0,0,0,0,0,0,0" > ${OUTPUT}/$type.csv
  fi
done

cat $(eval echo "${OUTPUT}/{$TYPES}.csv") | grep -v Conc | datamash transpose -t, | tail -n +2 > ${OUTPUT}/ubench-2.csv

# table data for latex
cat ${OUTPUT}/ubench-2.csv | sed "s/,/ \& /g" > ${OUTPUT}/ubench.tbl.in.2
paste $SCRIPT_DIR/ubench.tbl.in ${OUTPUT}/ubench.tbl.in.2 > ${OUTPUT}/ubench.tbl.in.3
cat ${OUTPUT}/ubench.tbl.in.3 | \
  awk -F'&' '{print $0 " \\\\ \n"    " & "  "("($2/$5)*100 "\\%) & "  "("($3/$5)*100 "\\%) & "  "("($4/$5)*100 "\\%)& "  " \\\\"}' > ${OUTPUT}/ubench.dat

gnuplot  << EndGNUPLOT

#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.25
set style fill pattern

#set size 1.0,0.6
set key top left

#set xrange [-1:3]
#set yrange [0:10000]
set xtics ('fstime' 0, 'fsbuffer' 1, 'fsdisk' 2, 'fstime-r' 3, 'fsbuffer-r' 4, 'fsdisk-r' 5, 'fstime-w' 6, 'fsbuffer-w' 7, 'fsdisk-w' 8, 'pipe' 9, 'syscall' 10)
set xtics rotate
set ylabel "Throughput (MBps)"

set datafile separator ","


set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/plots/unixbench.eps"

plot \
   '${OUTPUT}/ubench-2.csv' using (\$0-0.375):(\$1/1000) w boxes \
    fill patter 0 lc rgb "red" title "lkl", \
   '' using (\$0-0.125):(\$2/1000) w boxes \
    fill patter 1 lc rgb "green" title "noah", \
   '' us (\$0+0.125):(\$3/1000) w boxes \
    fill patter 2 lc rgb "gray" title "docker", \
   '' us (\$0+0.375):(\$4/1000) w boxes \
    fill patter 3 lc rgb "blue" title "macos"

set terminal png lw 3 14 crop
set output "${OUTPUT}/plots/unixbench.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

