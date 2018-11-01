#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=$1

mkdir -p ${OUTPUT}

STACKS="lwip rump linux lkl"
TESTS="ipv6 icmpv6 ipv6-ndp"

for stack in $STACKS
do
for test in $TESTS
do

 cd $stack
 echo "test,$stack" > ${OUTPUT}/$test.csv
 grep "<<" ${OUTPUT}/$test-out.log | \
   sed -e 's/<< //' -e 's/://' -e 's/ /,/' -e 's/Passed/-/' \
   >> ${OUTPUT}/$test.csv
 cd ..

done
done

for test in $TESTS
do

paste {lwip,rump,linux,lkl}/${OUTPUT}/$test.csv | \
  csv_to_db| \
  dbcoldefine test lwip dum1 rump dum6 linux dum7 lkl | \
  dbcol test lwip rump linux lkl | \
  db_to_csv | grep -v \# | sed "s/\-/ /g" \
   > ${OUTPUT}/$test.csv

done
