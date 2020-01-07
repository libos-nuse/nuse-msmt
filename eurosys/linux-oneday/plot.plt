
set terminal pdf enhanced color
set output "graph-netdev-items-cumulative.pdf"

set multiplot

#set size ratio 0.6
set size 1.0,0.5

set xdata time
set timefmt "%Y-%m-%d"


set xrange ["2002-01-01 00:00":"2020-01-01 00:00"]

set xtics format ""
set xtics scale 0
set ylabel "# of commits"
set yrange [0:6000]
set ytics 2000
set key left top reverse Left
#unset key

set grid front

set lmargin screen 0.15
set rmargin screen 0.9
set tmargin screen 0.95
set bmargin screen 0.5

plot	    \
	"linux-numstat-since-2002.dat"	\
	using 1:4 \
	with l lw 3 title "linux/net" , \
	"gvisor-numstat-since-2017.dat"	\
	using 1:4 \
	with l lw 3 title "gvisor" , \
	"seastar-numstat-since-2015.dat"	\
	using 1:4 \
	with l lw 3 title "seastar" , \
	"netbsd-numstat-since-2002.dat"	\
	using 1:4 \
	with l lw 3 title "netbsd(net*)" , \
	"lwip-numstat-since-2002.dat"	\
	using 1:4 \
	with l lw 3 title "lwip"

set lmargin screen 0.15
set rmargin screen 0.9
set tmargin screen 0.5
set bmargin screen 0.1

set xtics format "%Y"
set xtics offset -0.5,0.0
#set xtics 3600 * 24 * 31 * 6

set ylabel "# of changes"
set yrange [0:7000]
set ytics 2000

set key left top

plot	"netdev-pull-items.dat"	\
	using 1:2 \
	with filledcurves x1 lw 0 lc "gray40" title "All changes", \
	"netdev-pull-items.dat" \
	using 1:3 \
	with filledcurves x1 lw 0 lc "gray10" title "Fixes"

