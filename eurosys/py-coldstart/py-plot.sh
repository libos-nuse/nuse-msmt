
OUTPUT=$1
mkdir -p ${OUTPUT}/out

RUNTIMES="runu kata-runtime runsc-ptrace-user runsc-kvm-user runc native runnc kata-fc kata-qemu"


# parse outputs

# delay (sec)
for rt in $RUNTIMES ; do
grep -h elaps ${OUTPUT}/py-coldstart-$rt-[1-9].dat | sed "s/elapsed.*//" \
	| awk '{print $3}' \
	| awk -F: '{msecs=$2*1000; msecs+=$1*60*1000; printf "%.3f\n", msecs }' \
	| dbcoldefine delay | dbcolstats -f "%.1f" delay | dbcol mean stddev \
       	> ${OUTPUT}/py-coldstart-$rt-delay.dat

if [ $rt == "native" ] ; then
	continue
fi

grep -h elaps ${OUTPUT}/py-coldstart-$rt-docker-[1-9].dat | sed "s/elapsed.*//" \
	| awk '{print $3}' \
	| awk -F: '{msecs=$2*1000; msecs+=$1*60*1000; printf "%.3f\n", msecs }' \
	| dbcoldefine delay | dbcolstats -f "%.1f" delay | dbcol mean stddev \
       	> ${OUTPUT}/py-coldstart-$rt-docker-delay.dat
done

gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/py-coldstart-docker.eps"
set pointsize 2
set xzeroaxis
set grid

set boxwidth 0.3
set style fill pattern
unset key
set size 1.0,0.7

set ylabel "Delay (msec)"
set yrange [0:3000]
#set logscale y
set xtics font ", 18"
set xtics ('runc' 0, 'kata' 1, 'gvisor(p)' 2, 'gvisor(k)' 3, 'nabla' 4, 'ukontainer' 5, 'native' 6, 'kata-fc' 7, 'kata-qemu' 8)
set xrange [-0.5:8.5]
set xtics nomirror

plot \
   '${OUTPUT}/py-coldstart-runc-docker-delay.dat' usi (0):(\$1):(\$2) w boxerr lt 1 lc rgb "green" fill pattern 2 title "runc", \
   '' usi (0):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-kata-runtime-docker-delay.dat' usi (1):(\$1):(\$2) w boxerr lt 1 lc rgb "gray" fill pattern 1 title "runv", \
   '' usi (1):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runsc-ptrace-user-docker-delay.dat' usi (2):(\$1):(\$2) w boxerr lt 1 lc rgb "blue" fill pattern 4 title "runsc(ptrace)", \
   '' usi (2):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runsc-kvm-user-docker-delay.dat' usi (3):(\$1):(\$2) w boxerr lt 1 lc rgb "blue" fill pattern 5 title "runsc(kvm)", \
   '' usi (3):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runnc-docker-delay.dat' usi (4):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 6 title "runu", \
   '' usi (4):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runu-docker-delay.dat' usi (5):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 3 title "runu", \
   '' usi (5):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-native-delay.dat' usi (6):(\$1):(\$2) w boxerr fill patter 0 lt 1 lc rgb "red" title "native" ,\
   '' usi (6):(\$1):(\$1) w labels offset 0,1 ,\
   '${OUTPUT}/py-coldstart-kata-fc-docker-delay.dat' usi (7):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 3 title "kata-fc", \
   '' usi (7):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-kata-qemu-docker-delay.dat' usi (8):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 3 title "kata-qemu", \
   '' usi (8):(\$1):(\$1) w labels offset 0,1
   
set terminal png lw 3 14 crop
set xtics nomirror rotate by -45
set output "${OUTPUT}/out/py-coldstart-docker.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/py-coldstart.eps"
#set ytics 10
set xtics ('runc' 0, 'kata' 1, 'gvisor(p)' 2, 'gvisor(k)' 3, 'ukontainer' 4, 'native' 5)
set xrange [-0.5:5.5]
set yrange [0:1000]
set xtics nomirror rotate by 0

plot \
   '${OUTPUT}/py-coldstart-runc-delay.dat' usi (0):(\$1):(\$2) w boxerr lt 1 lc rgb "green" fill pattern 2 title "runc", \
   '' usi (0):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-kata-runtime-delay.dat' usi (1):(\$1):(\$2) w boxerr lt 1 lc rgb "gray" fill pattern 1 title "runv", \
   '' usi (1):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runsc-ptrace-user-delay.dat' usi (2):(\$1):(\$2) w boxerr lt 1 lc rgb "blue" fill pattern 3 title "runsc(ptrace)", \
   '' usi (2):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runsc-kvm-user-delay.dat' usi (3):(\$1):(\$2) w boxerr lt 1 lc rgb "blue" fill pattern 5 title "runsc(kvm)", \
   '' usi (3):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-runu-delay.dat' usi (4):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "runu", \
   '' usi (4):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-native-delay.dat' usi (5):(\$1):(\$2) w boxerr fill patter 0 lt 1 lc rgb "red" title "native", \
   '' usi (5):(\$1):(\$1) w labels offset 0,1 ,\
   '${OUTPUT}/py-coldstart-kata-fc-delay.dat' usi (6):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "kata-fc", \
   '' usi (6):(\$1):(\$1) w labels offset 0,1, \
   '${OUTPUT}/py-coldstart-kata-qemu-delay.dat' usi (7):(\$1):(\$2) w boxerr lt 1 lc rgb "cyan" fill pattern 4 title "kata-qemu", \
   '' usi (7):(\$1):(\$1) w labels offset 0,1
   
set terminal png lw 3 14 crop
set xtics nomirror rotate by -45
set output "${OUTPUT}/out/py-coldstart.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

