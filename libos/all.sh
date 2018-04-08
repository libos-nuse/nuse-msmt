
echo gathering ping result and plot them

_RES="result-ping/nuse-to-other"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="ping-n2o"
./gather-ping.py $RES > $OUT.dat
DELAY=`cat $OUT.dat | grep dpdk | awk '{print $2}'`
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'; _DELAY_=$DELAY" plot-ping.plt


_RES="result-ping/other-to-nuse"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="ping-o2n"
./gather-ping.py $RES > $OUT.dat
DELAY=`cat $OUT.dat | grep dpdk | awk '{print $2}'`
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'; _DELAY_=$DELAY" plot-ping.plt


_RES="result-ping/other-to-other"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="ping-o2o"
./gather-ping.py $RES > $OUT.dat
DELAY=`cat $OUT.dat | grep dpdk | awk '{print $2}'`
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'; _DELAY_=$DELAY" plot-ping.plt


echo gathering flowgen result and plot them

_RES="result-flowgen/other-to-other"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="flowgen-o2o"
./gather-flowgen.py $RES > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt


_RES="result-flowgen/nuse-to-other"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="flowgen-n2o"
./gather-flowgen.py $RES > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt


_RES="result-flowgen/other-to-nuse"
RES="${_RES}/native.txt ${_RES}/dpdk.txt ${_RES}/netmap.txt ${_RES}/raw.txt ${_RES}/tap.txt"
OUT="flowgen-o2n"
./gather-flowgen.py $RES > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt

