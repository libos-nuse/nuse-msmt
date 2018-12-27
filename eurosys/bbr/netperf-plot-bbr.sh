
PREFIX=netperf-bbr

# read vals
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

OUTPUT=$1

# override variables
CC_ALGO="cubic bbr"

rm -f ${OUTPUT}/tcp-stream-*.dat

for cc in ${CC_ALGO}
do

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap*-root*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e lkl-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-musl-tap-$cc.dat
 
grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e native-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-native-$cc.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-noah*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e noah-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-noah-$cc.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-docker*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e docker-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-docker-$cc.dat

done

#generate latex table
cat ${OUTPUT}/tcp-stream-*.dat | dbcol mode mean stddev | \
grep -v '#' | sed "s/\t/ \& /g" | sed "s/\(.*\)/\1 \\\\\\\\/" \
| sed "s/lkl-/ukontainer-/" \
 > ${OUTPUT}/tcp-stream-thpt.tbl


cat ${OUTPUT}/tcp-stream-thpt.tbl

