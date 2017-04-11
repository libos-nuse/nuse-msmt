#!/bin/sh

OUTPUT=$1
mkdir -p ${OUTPUT}/out

cat ${OUTPUT}/hrtimer/native-log.txt |grep timer:hrtim | grep qdisc |\
       awk '{ gsub(/:/, "") } { gsub(/expires=/, "") } { gsub(/now=/, "") } $5 ~ /start/ { base = $8 }  $5 ~ /expire/  { if (base != 0) delay=$7 - base; else delay=0; { printf "%.f %.f \n", $4 * 1000000, delay; base = 0 } }' \
  > ${OUTPUT}/hrtimer/native-delay.dat

# v1 printk based
cat ${OUTPUT}/hrtimer/lkl-log.txt  |grep fq: | \
       awk  '{ gsub(/]/,"")} $4 ~ /sched/ { base = $8 } $4 ~ /fired/ { printf "%s %.f\n", $2, ($8 - base); base = 0 }'  \
> ${OUTPUT}/hrtimer/lkl-delay.dat

# v2 uprobe based
# cat ${OUTPUT}/hrtimer/lkl-log.txt | \
#        sed "s/ts=//" | sed "s/://" | awk '$7 ~ /idx=0/ { base = $8 } $7 ~ /idx=1/ { if (base != 0) delay=$8 - base ; else delay=0 ; printf "%s %.f\n", $4*1000000, delay; base = 0 }' \
#   > ${OUTPUT}/hrtimer/lkl-delay.dat

# CDF
cat ${OUTPUT}/hrtimer/native-delay.dat| dbcoldefine time delay | dbcol delay | \
	dbsort -n delay | dbrowenumerate | dbcolpercentile delay > ${OUTPUT}/hrtimer/native-delay-cdf.dat
cat ${OUTPUT}/hrtimer/lkl-delay.dat| dbcoldefine time delay | dbcol delay | \
	dbsort -n delay | dbrowenumerate | dbcolpercentile delay > ${OUTPUT}/hrtimer/lkl-delay-cdf.dat

# histogram
cat ${OUTPUT}/hrtimer/native-delay.dat | dbcoldefine time delay | dbcolhisto -S 1 -E 1000000000 -W 500 delay \
	> ${OUTPUT}/hrtimer/native-delay-histo.dat
cat ${OUTPUT}/hrtimer/lkl-delay.dat | dbcoldefine time delay | dbcolhisto -S 1 -E 1000000000 -W 500 delay \
	> ${OUTPUT}/hrtimer/lkl-delay-histo.dat

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/hrtimer-delay.eps"
set xlabel "elasped time"
set ylabel "Delay (nsec)"
set pointsize 1
set xzeroaxis
set grid ytics

plot \
       '${OUTPUT}/hrtimer/lkl-delay.dat' usi 0:2 w p pt 2 title "LKL", \
       '${OUTPUT}/hrtimer/native-delay.dat' usi 0:2 w p pt 1 title "Linux"

set terminal png lw 3 14 crop
set xtics nomirror
set output "${OUTPUT}/out/hrtimer-delay.png"
replot


# CDF
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/hrtimer-delay-cdf.eps"
set xlabel "Delay (nsec)"
set ylabel "CDF"
set logscale x
set xrange [:100000000]
unset logscale y
#unset xlabel
#unset xtics
set size 1.0,0.6
set ytics 0,0.5,1
set format y "%0.1f"
set key bottom right


plot \
       '${OUTPUT}/hrtimer/lkl-delay-cdf.dat' usi 1:3 w lp pt 2 ps 2 title "LKL" ,\
       '${OUTPUT}/hrtimer/native-delay-cdf.dat' usi 1:3 w lp pt 1 ps 2 title "Linux"

set terminal png lw 3 14 crop
set xtics nomirror
set output "${OUTPUT}/out/hrtimer-delay-cdf.png"
replot

# histo
reset
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/hrtimer-delay-histo.eps"
set xlabel "Delay (nsec)"
set ylabel "Events (n)"
#set xrange [1:]
set logscale xy
#unset xlabel
#unset xtics
set xtics 1,1000,1000000000
set size 1.0,0.6
unset ytics
unset format y
set key top right


plot \
       '${OUTPUT}/hrtimer/lkl-delay-histo.dat' usin 1:2 w lp ps 2  title "LKL" ,\
       '${OUTPUT}/hrtimer/native-delay-histo.dat' usin 1:2 w lp ps 2 title "Linux"

set terminal png lw 3 14 crop
set xtics nomirror
set output "${OUTPUT}/out/hrtimer-delay-histo.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT
