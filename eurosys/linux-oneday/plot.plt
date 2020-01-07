
set terminal pdf enhanced color fontscale 0.72
set output "graph-netdev-items-cumulative.pdf"

set size ratio 0.6

set xdata time
set timefmt "%Y-%m-%d"

set key below box

set xtics format "%Y/%m"
set xtics rotate by -45
set xtics offset -0.5,0.0
#set xtics 3600 * 24 * 31 * 6
set xrange ["2008-01-01 00:00":"2019-12-01 00:00"]

#set ylabel "# of changes at netdev \n(cumulative)"
set ylabel "# of changes (cumulative)"

set y2tics
set y2label "# of commits to linux/net/\nper year"
set y2label "# of commits per year"
set y2range [0:7000]
set y2tics 1000

set grid front

plot	"netdev-pull-items.dat"	\
	using 1:2 axis x1y1 \
	with filledcurves x1 lw 0 lc "gray40" title "All changes", \
	"netdev-pull-items.dat" \
	using 1:3 axis x1y1 \
	with filledcurves x1 lw 0 lc "gray10" title "Fixes",	\
	"linux-numstat-under-net-since-2008.dat"	\
	using 1:4 axis x1y2 \
	with lp lw 3 lc "gray20" lt 1 title "commits"
