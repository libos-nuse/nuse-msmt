

set terminal postscript eps enhanced color "Helvetica" 24 fontscale 1.25

set output output


set ylabel "Throughput (Mbps)"
set yrange [0:6000]

set boxwidth 0.6 
set style fill pattern 2 border lc rgb "black"


unset key

#set size 0.7,0.7

plot	input using 0:2:xtic(1) with boxes lw 0 lt 1 linecolor rgb "gray" notitle

