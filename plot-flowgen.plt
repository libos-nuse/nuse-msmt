

set terminal postscript eps enhanced color "Helvetica" 28 lw 3 

set output output


set ylabel "Throughput (Gbps)"
set yrange [0:6]

set boxwidth 0.6 
set style fill pattern 2 border lc rgb "black"


unset key

#set size 0.7,0.7

plot	input using 0:($2/1000):xtic(1) with boxes lt 1 linecolor rgb "gray" notitle

