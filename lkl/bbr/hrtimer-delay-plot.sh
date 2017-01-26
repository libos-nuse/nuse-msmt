#!/bin/sh

OUTPUT=$1

cat ${OUTPUT}/native-delay.dat| dbcoldefine time delay | dbcol delay | \
	dbsort -n delay | dbrowenumerate | dbcolpercentile delay > ${OUTPUT}/native-delay-cdf.dat
cat ${OUTPUT}/lkl-delay.dat| dbcoldefine time delay | dbcol delay | \
	dbsort -n delay | dbrowenumerate | dbcolpercentile delay > ${OUTPUT}/lkl-delay-cdf.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/hrtimer-delay.eps"
#set xtics font "Helvetica,14"
set pointsize 1
set xzeroaxis
set grid ytics


#set xrange [:10000]
set xlabel "Delay (usec)"
set ylabel "CDF"
set logscale x
#unset xlabel
#unset xtics


plot \
       '${OUTPUT}/native-delay-cdf.dat' usi 1:3 w lp pt 1 title "native", \
       '${OUTPUT}/lkl-delay-cdf.dat' usi 1:3 w lp pt 2 title "lkl"

set terminal png lw 3 14
set xtics nomirror rotate by -45 font ",14"
set output "${OUTPUT}/hrtimer-delay.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT
