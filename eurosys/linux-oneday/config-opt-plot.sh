#!/bin/sh

OUTPUT=$(pwd)
FILENAME=$OUTPUT/num-linux-options.dat

gnuplot  << EndGNUPLOT

set terminal pdf enhanced color fontscale 0.5 crop
set output "linux-config-options.pdf"

set multiplot

set size 1.0,0.5
set style fill solid

set xdata time
set timefmt "%Y-%m-%d"

set xtics format ""
set xtics scale 0
set grid front

set xrange ["1991-01-01 00:00":"2020-01-01 00:00"]

set ylabel "# of config options"
set ytics 5000

set lmargin screen 0.15
set rmargin screen 0.97
set tmargin screen 0.97
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
      "" using 1:4:(stringcolumn(2) eq "v4.17" ? stringcolumn(2) : 1/0) w labels offset 0,1 notitle ,\
      "" using 1:4:(stringcolumn(2) eq "v5.4" ? stringcolumn(2) : 1/0) w labels offset 0,1.3 notitle

#      "$FILENAME" using 1:3 w l title "mk config" ,\
#      "" using 2:3:1 w labels notitle


###
###  davem tree
###

set tmargin screen 0.5
set bmargin screen 0.1

set xtics format "%Y"
set xtics offset -0.5,0.0
set ylabel "# of changes"
set yrange [0:50]
set ytics 10

set key left top

old2 = 0
old3 = 0

plot	"netdev-pull-items.dat"	\
	using 1:(d2 = \$2-old2, old2 = \$2, d2) \
	with boxes lw 0 lc "gray40" title "All changes", \
	"netdev-pull-items.dat" \
	using 1:(d3=\$3-old3, old3=\$3, d3) \
	with boxes lw 0 lc "gray10" title "Fixes"


EndGNUPLOT
