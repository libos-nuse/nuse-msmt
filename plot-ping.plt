

set terminal postscript eps enhanced color

set output output


#set yrange [0:15]
set ylabel "RTT (ms)"

set boxwidth 0.6 
set style fill solid 0.6

set key top right
set key box

set size 0.7,0.7

plot	input using 0:2:xtic(1) with boxes lw 0 lt 1 lc 1 notitle, 	\
	input using 0:3 with lp lt 1 lc 1 lw 3 pt 3 title "maximum",	\
	input using 0:4 with lp lt 1 lc 2 lw 3 pt 3 title "minimum"
