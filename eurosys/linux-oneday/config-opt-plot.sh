#!/bin/sh

OUTPUT=$(pwd)
FILENAME=$OUTPUT/num-linux-options.dat
FILENAME_COMMIT=$OUTPUT/linux-commits.dat

gnuplot  << EndGNUPLOT

set terminal pdf enhanced color lw 3 font "Helvetica,16"
set output "linux-history.pdf"

set multiplot

set style fill solid

set xdata time
set timefmt "%Y-%m-%d"

set xtics format ""
set xtics scale 0
set grid front

set xrange ["1990-01-01 00:00":"2021-01-01 00:00"]

set ylabel "# of config options" offset +0.5 font "Helvetica,18"
set yrange [0:21000]
set ytics 5000
set format y "%.0s %c"

set lmargin screen 0.15
set rmargin screen 0.95
set tmargin screen 0.95
set bmargin screen 0.5

plot \
      "$FILENAME" using 1:4 w boxes lc "blue" notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v1.0.0" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v2.2.0" ? stringcolumn(2) : 1/0) w labels offset -2,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v2.4.0" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v2.6.0" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v2.6.20" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v3.0" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v4.0" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v4.17" ? stringcolumn(2) : 1/0) w labels offset -1,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v5.9" ? stringcolumn(2) : 1/0) w labels offset 0,1.4 notitle

#      "$FILENAME" using 1:3 w l title "mk config" ,\
#      "" using 2:3:1 w labels notitle


###
###  davem tree
###

set tmargin screen 0.5
set bmargin screen 0.1

set timefmt "%Y"
set xtics format "%Y"
set xtics offset -0.5,0.0
set ylabel "# of commits" offset +0.5
set yrange [0:100000]
set ytics 40000

set key left top

plot	"$FILENAME_COMMIT"	\
	using 1:2 \
	with boxes lw 0 lc "gray40" title "All", \
	"$FILENAME_COMMIT" \
	using 1:3 \
	with boxes lw 0 lc "gray10" title "Bug fixes"


EndGNUPLOT
