
PREFIX=netperf-bbr

# read vals
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../../lkl/netperf-common.sh"

OUTPUT=$1

# override variables
CC_ALGO="cubic bbr"

rm -f ${OUTPUT}/tcp-stream-musl-tap-*.dat
rm -f ${OUTPUT}/tcp-stream-native-*.dat

for cc in ${CC_ALGO}
do

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-musl-tap*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e lkl-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-musl-tap-$cc.dat

grep -h bits ${OUTPUT}/${PREFIX}-TCP_ST*-native*-$cc* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 thpt d5 \
| dbcolstats thpt | dbcolcreate -e native-$cc mode | dbcol mode mean stddev \
>> ${OUTPUT}/tcp-stream-native-$cc.dat

done

#generate latex table
cat ${OUTPUT}/tcp-stream-*.dat | dbcol mode mean stddev | \
grep -v '#' | sed "s/\t/ \& /g" \
 > ${OUTPUT}/tcp-stream-thpt.tbl



