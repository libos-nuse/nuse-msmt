
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
set grid ytics

set boxwidth 0.3
set style fill pattern
set key top right
set size 1.0,0.7

set ylabel "Delay (sec)"
set ytics 5
set yrange [0:10]
unset xtics
unset xlabel
set xrange [-1:6]

plot \
   '${OUTPUT}/py-coldstart-runc-delay.dat' usi (0):(\$1):(\$2) w boxerr lc rgb "green" title "runc", \
   '${OUTPUT}/py-coldstart-kata-runtime-delay.dat' usi (1):(\$1):(\$2) w boxerr lc rgb "gray" title "runv", \
   '${OUTPUT}/py-coldstart-runsc-ptrace-user-delay.dat' usi (2):(\$1):(\$2) w boxerr lc rgb "blue" title "runsc(p)", \
   '${OUTPUT}/py-coldstart-runsc-kvm-user-delay.dat' usi (3):(\$1):(\$2) w boxerr lc rgb "red" title "runsc(k)", \
   '${OUTPUT}/py-coldstart-runu-delay.dat' usi (4):(\$1):(\$2) w boxerr lc rgb "cyan" title "runu" ,\
   '${OUTPUT}/py-coldstart-native-delay.dat' usi (5):(\$1):(\$2) w boxerr lc rgb "purple" title "native"
   
set terminal png lw 3 14 crop
set output "${OUTPUT}/out/py-coldstart.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

