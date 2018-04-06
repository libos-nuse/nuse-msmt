#!/bin/bash

OUTPUT=$1

if [ -z $OUTPUT ] ; then
	echo "missing output dir"
	exit
fi

mkdir -p $OUTPUT/plots

# data convertion
TYPES="lkl,noah,macos,docker"
for type in $(eval echo "{$TYPES}")
do
  if [ ! -s ${OUTPUT}/$type.csv ] ; then
     echo "1,0,0,0,0,0,0,0,0,0,0" > ${OUTPUT}/$type.csv
  fi
done

cat $(eval echo "${OUTPUT}/{$TYPES}.csv") | grep -v Conc | datamash transpose -t, | tail -n +2 > ${OUTPUT}/ubench.dat

# table data for latex
cat ${OUTPUT}/ubench.dat | sed "s/,/ \& /g" |sed "s/\$/ \\\\\\\\ \\\hline/" \
 > ${OUTPUT}/ubench.tbl

gnuplot  << EndGNUPLOT

#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.25
set style fill pattern

set size 1.0,0.6
set key top left

#set xrange [-1:3]
#set yrange [0:10000]
set xtics ('fstime' 0, 'fsbuffer' 1, 'fsdisk' 2, 'fstime-r' 3, 'fsbuffer-r' 4, 'fsdisk-r' 5, 'fstime-w' 6, 'fsbuffer-w' 7, 'fsdisk-w' 8, 'pipe' 9)
set xtics rotate
set ylabel "Throughput (MBps)"

set datafile separator ","


set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/plots/unixbench.eps"

plot \
   '${OUTPUT}/ubench.dat' using (\$0-0.375):(\$1/1000) w boxes title "lkl", \
   '' using (\$0-0.125):(\$2/1000) w boxes title "noah", \
   '' using (\$0+0.125):(\$3/1000) w boxes title "macos", \
   '' us (\$0+0.375):(\$4/1000) w boxes title "docker"

set terminal png lw 3 14 crop
set output "${OUTPUT}/plots/unixbench.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

