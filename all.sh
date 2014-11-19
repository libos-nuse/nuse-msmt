

echo gathering ping result and plot them

RES="result-ping/nuse-to-other"
OUT="ping-n2o"
./gather-ping.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-ping.plt


RES="result-ping/other-to-nuse"
OUT="ping-o2n"
./gather-ping.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-ping.plt


RES="result-ping/other-to-other"
OUT="ping-o2o"
./gather-ping.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-ping.plt


echo gathering flowgen result and plot them

RES="result-flowgen/other-to-other"
OUT="flowgen-o2o"
./gather-flowgen.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt


RES="result-flowgen/nuse-to-other"
OUT="flowgen-n2o"
./gather-flowgen.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt


RES="result-flowgen/other-to-nuse"
OUT="flowgen-o2n"
./gather-flowgen.py $RES/* > $OUT.dat
gnuplot -e "input='$OUT.dat'; output='$OUT.eps'" plot-flowgen.plt

