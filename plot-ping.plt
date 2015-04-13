
set terminal postscript eps enhanced color "Helvetica" 24 fontscale 1.16

set output output


set yrange [0:1.1]
set ylabel "RTT (ms)"

set boxwidth 1.6
set style fill pattern 2 border lc rgb "black"

dpdk = _DELAY_
set label 1 sprintf("avg=%.2f ms}", dpdk) center at 1,1 front

unset key

#set size 0.7,0.7

set xtics offset first 0.2,0

set style data histogram
set style histogram errorbars 
plot input using 2:3:4:xticlabels(1) linecolor rgb "gray" lw 3 notitle

