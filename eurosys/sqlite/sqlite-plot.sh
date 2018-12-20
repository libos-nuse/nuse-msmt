#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PYTHON="python3"
SCRIPT="sqlite-plot.py"

OUTPUT="$1"
DIRS="read fill"
PREFIX=sqlite-bench-write

mkdir -p "$OUTPUT/out/"

# parse outputs

${PYTHON} ${SCRIPT} ${OUTPUT}

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/fillseq.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.15
set style fill pattern

set size 1.0,0.8
set key top left

set xrange [-0.5:6.5]
set xtics ('1' 0, '16' 1, '256' 2, '1024' 3, '8192' 4)
set xlabel "Value size (bytes)"
set yrange [1:1000]
set ylabel "Latency (usec)"
set logscale y

plot \
   '${OUTPUT}/fillseq-runc.dat' usin (\$0-0.3):(\$1):(\$2) w boxerrorbar fill patter 2 lt 1 lc rgb "green" title "runc" ,\
   '${OUTPUT}/fillseq-kata-runtime.dat' usin (\$0-0.15):(\$1):(\$2) w boxerrorbar fill patter 1 lt 1 lc rgb "gray" title "runv" ,\
   '${OUTPUT}/fillseq-runsc-ptrace.dat' usin (\$0-0.0):(\$1):(\$2) w boxerrorbar fill patter 3 lt 1 lc rgb "blue" title "runsc" ,\
   '${OUTPUT}/fillseq-lkl.dat' usin (\$0+0.15):(\$1):(\$2) w boxerrorbar fill patter 4 lt 1 lc rgb "cyan" title "runu" ,\
   '${OUTPUT}/fillseq-native.dat' usin (\$0+0.3):(\$1):(\$2) w boxerrorbar fill patter 0 lt 1 lc rgb "red" title "native"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/fillseq.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/fillrandom.eps"
#set ytics ('0.0001' 0.0001, '1' 1, '10000' 10000)

plot \
   '${OUTPUT}/fillrandom-runc.dat' usin (\$0-0.3):(\$1):(\$2) w boxerrorbar fill patter 2 lt 1 lc rgb "green" title "runc" ,\
   '${OUTPUT}/fillrandom-kata-runtime.dat' usin (\$0-0.15):(\$1):(\$2) w boxerrorbar fill patter 1 lt 1 lc rgb "gray" title "runv" ,\
   '${OUTPUT}/fillrandom-runsc-ptrace.dat' usin (\$0-0.0):(\$1):(\$2) w boxerrorbar fill patter 3 lt 1 lc rgb "blue" title "runsc" ,\
   '${OUTPUT}/fillrandom-lkl.dat' usin (\$0+0.15):(\$1):(\$2) w boxerrorbar fill patter 4 lt 1 lc rgb "cyan" title "runu" ,\
   '${OUTPUT}/fillrandom-native.dat' usin (\$0+0.3):(\$1):(\$2) w boxerrorbar fill patter 0 lt 1 lc rgb "red" title "native"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/fillrandom.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/readseq.eps"
set yrange [0.1:10]

plot \
   '${OUTPUT}/readseq-runc.dat' usin (\$0-0.3):(\$1):(\$2) w boxerrorbar fill patter 2 lt 1 lc rgb "green" title "runc" ,\
   '${OUTPUT}/readseq-kata-runtime.dat' usin (\$0-0.15):(\$1):(\$2) w boxerrorbar fill patter 1 lt 1 lc rgb "gray" title "runv" ,\
   '${OUTPUT}/readseq-runsc-ptrace.dat' usin (\$0-0.0):(\$1):(\$2) w boxerrorbar fill patter 3 lt 1 lc rgb "blue" title "runsc" ,\
   '${OUTPUT}/readseq-lkl.dat' usin (\$0+0.15):(\$1):(\$2) w boxerrorbar fill patter 4 lt 1 lc rgb "cyan" title "runu" ,\
   '${OUTPUT}/readseq-native.dat' usin (\$0+0.3):(\$1):(\$2) w boxerrorbar fill patter 0 lt 1 lc rgb "red" title "native"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/readseq.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/readrandom.eps"

plot \
   '${OUTPUT}/readrandom-runc.dat' usin (\$0-0.3):(\$1):(\$2) w boxerrorbar fill patter 2 lt 1 lc rgb "green" title "runc" ,\
   '${OUTPUT}/readrandom-kata-runtime.dat' usin (\$0-0.15):(\$1):(\$2) w boxerrorbar fill patter 1 lt 1 lc rgb "gray" title "runv" ,\
   '${OUTPUT}/readrandom-runsc-ptrace.dat' usin (\$0-0.0):(\$1):(\$2) w boxerrorbar fill patter 3 lt 1 lc rgb "blue" title "runsc" ,\
   '${OUTPUT}/readrandom-lkl.dat' usin (\$0+0.15):(\$1):(\$2) w boxerrorbar fill patter 4 lt 1 lc rgb "cyan" title "runu" ,\
   '${OUTPUT}/readrandom-native.dat' usin (\$0+0.3):(\$1):(\$2) w boxerrorbar fill patter 0 lt 1 lc rgb "red" title "native"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/readrandom.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

