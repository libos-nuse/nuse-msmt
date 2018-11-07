#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PYTHON="python"
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

set boxwidth 0.2
set style fill pattern

set size 1.0,0.8
set key top left

set xrange [-1.5:7.5]
set xtics ('128' 0, '256' 1, '512' 2, '1024' 3, '1500' 4, '4096' 5, '8192' 6)
set xlabel "Value size (bytes)"
set yrange [0.0001:300]
set ytics ('0' 0.0001, '100' 100, '300' 300)
set ylabel "microseconds/op"
set logscale y

plot \
   '${OUTPUT}/fillseq-runc.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "runc" ,\
   '${OUTPUT}/fillseq-kata-runtime.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "kata-runtime" ,\
   '${OUTPUT}/fillseq-runsc-ptrace.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "runsc(ptrace)" ,\
   '${OUTPUT}/fillseq-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "native" ,\
   '${OUTPUT}/fillseq-lkl.dat' usin (\$0+0.5):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "cyan" title "lkl"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/fillseq.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/fillrandom.eps"
set xrange [-1.5:7.5]
set xtics ('128' 0, '256' 1, '512' 2, '1024' 3, '1500' 4, '4096' 5, '8192' 6)
set xlabel "Value size (bytes)"
set yrange [0.0001:300]
set ytics ('0' 0.0001, '100' 100, '300' 300)
set ylabel "microseconds/op"
set logscale y

plot \
   '${OUTPUT}/fillrandom-runc.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "runc" ,\
   '${OUTPUT}/fillrandom-kata-runtime.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "kata-runtime" ,\
   '${OUTPUT}/fillrandom-runsc-ptrace.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "runsc(ptrace)" ,\
   '${OUTPUT}/fillrandom-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "native" ,\
   '${OUTPUT}/fillrandom-lkl.dat' usin (\$0+0.5):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "cyan" title "lkl"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/fillrandom.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/readseq.eps"
set xrange [-1.5:7.5]
set xtics ('128' 0, '256' 1, '512' 2, '1024' 3, '1500' 4, '4096' 5, '8192' 6)
set xlabel "Value size (bytes)"
set yrange [0.0001:10]
set ytics ('0' 0.0001, '0.5' 0.5, '10' 10)
set ylabel "microseconds/op"
set logscale y

plot \
   '${OUTPUT}/readseq-runc.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "runc" ,\
   '${OUTPUT}/readseq-kata-runtime.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "kata-runtime" ,\
   '${OUTPUT}/readseq-runsc-ptrace.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "runsc(ptrace)" ,\
   '${OUTPUT}/readseq-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "native" ,\
   '${OUTPUT}/readseq-lkl.dat' usin (\$0+0.5):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "cyan" title "lkl"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/readseq.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/readrandom.eps"
set xrange [-1.5:7.5]
set xtics ('128' 0, '256' 1, '512' 2, '1024' 3, '1500' 4, '4096' 5, '8192' 6)
set xlabel "Value size (bytes)"
set yrange [0.0001:10]
set ytics ('0' 0.0001, '0.5' 0.5, '10' 10)
set ylabel "microseconds/op"
set logscale y

plot \
   '${OUTPUT}/readrandom-runc.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "runc" ,\
   '${OUTPUT}/readrandom-kata-runtime.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "kata-runtime" ,\
   '${OUTPUT}/readrandom-runsc-ptrace.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "runsc(ptrace)" ,\
   '${OUTPUT}/readrandom-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "native" ,\
   '${OUTPUT}/readrandom-lkl.dat' usin (\$0+0.5):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "cyan" title "lkl"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/readrandom.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

