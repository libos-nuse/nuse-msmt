

set terminal postscript eps enhanced color "Helvetica" 24

set output output


set ylabel "Throughput (Mbps)"
set yrange [0:]

set boxwidth 0.6 
set style fill solid 0.6

unset key

#set size 0.7,0.7

plot	input using 0:2:xtic(1) with boxes lw 0 lt 1 lc 1 notitle
