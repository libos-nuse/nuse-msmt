#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1
mkdir -p ${OUTPUT}

for stack in $STACKS6
do
for test in $TESTS6
do

 echo "test,$stack" > ${OUTPUT}/$stack-$test.csv
 grep "<<" ${OUTPUT}/$stack-$test-out.log | \
   sed -e 's/<< //' -e 's/://' -e 's/ /,/' -e 's/Passed/-/' \
   >> ${OUTPUT}/$stack-$test.csv
 cd ..

done
done

for test in $TESTS6
do

paste ${OUTPUT}/{lwip,rump,linux,lkl}-$test.csv | \
  csv_to_db| \
  dbcoldefine test lwip dum1 rump dum6 linux dum7 lkl | \
  dbcol test lwip rump linux lkl | \
  db_to_csv | grep -v \# | sed "s/\-/ /g" \
   > ${OUTPUT}/$test.csv

done
