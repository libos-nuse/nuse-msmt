
OUTPUT=$1
mkdir -p ${OUTPUT}/out

RUNTIMES="runu kata-runtime runsc-ptrace-user runsc-kvm-user runc native"


# parse outputs

# delay (sec)
for rt in $RUNTIMES ; do
grep -h elaps ${OUTPUT}/py-coldstart-$rt-* | sed "s/elapsed.*//" \
	| awk '{print $3}' \
	| awk -F: '{secs=$2; secs+=$1*60; printf "%.3f\n", secs }' \
	| dbcoldefine delay | dbcolstats delay | dbcol mean stddev \
       	> ${OUTPUT}/py-coldstart-$rt-delay.dat
done

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/py-coldstart.eps"
set pointsize 2
set xzeroaxis
set grid mytics

set boxwidth 0.3
set style fill pattern
unset key
set size 1.0,0.7

set ylabel "Delay (msec)"
set ytics 10
set yrange [10:1500]
set logscale y
set xtics font ", 18"
set xtics ('runc' 0, 'runv' 1, 'runsc(p)' 2, 'runsc(k)' 3, 'runu' 4, 'native' 5)
set xrange [-1:6]

plot \
   '${OUTPUT}/py-coldstart-runc-delay.dat' usi (0):(\$1)*1000:(\$2)*1000 w boxerr lt 1 lc rgb "green" fill pattern 2 title "runc", \
   '${OUTPUT}/py-coldstart-kata-runtime-delay.dat' usi (1):(\$1)*1000:(\$2)*1000 w boxerr lt 1 lc rgb "gray" fill pattern 1 title "runv", \
   '${OUTPUT}/py-coldstart-runsc-ptrace-user-delay.dat' usi (2):(\$1)*1000:(\$2*1000) w boxerr lt 1 lc rgb "blue" fill pattern 3 title "runsc(ptrace)", \
   '${OUTPUT}/py-coldstart-runsc-kvm-user-delay.dat' usi (3):(\$1)*1000:(\$2)*1000 w boxerr lt 1 lc rgb "blue" fill pattern 5 title "runsc(kvm)", \
   '${OUTPUT}/py-coldstart-runu-delay.dat' usi (4):(\$1)*1000:(\$2)*1000 w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "runu", \
   '${OUTPUT}/py-coldstart-native-delay.dat' usi (5):(\$1)*1000:(\$2)*1000 w boxerr fill patter 0 lt 1 lc rgb "red" title "native"
   
set terminal png lw 3 14 crop
set output "${OUTPUT}/out/py-coldstart.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

