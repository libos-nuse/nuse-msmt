
set terminal postscript eps enhanced color "Helvetica" 28

set output output


#set yrange [0:15]
set ylabel "RTT (ms)"

#set boxwidth 0.6 
set style fill solid 0.6

unset key

#set size 0.7,0.7

set xtics offset first 0.15,0

set style data histogram
set style histogram errorbars 
plot input using 2:3:4:xticlabels(1) lc 0 lw 3 notitle

