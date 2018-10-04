#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=$1

TESTS="ipv6 icmpv6 ipv6-ndp"

TEXT=""

for test in $TESTS
do
 if [ -n "${TEXT}" ] ; then
  TEXT="${TEXT} &"
 fi

 RESULT=$(grep Number ${OUTPUT}/$test-out.log | \
  grep -E "passed|run" | \
  awk '{num[$4]=$5} END { print num["passed:"] "/" num["run:"] }')
 TEXT="${TEXT} ${RESULT}"
done


echo -n "%" > ${OUTPUT}/result6.tbl
echo ${TESTS} | sed "s/ / \& /g" >> ${OUTPUT}/result6.tbl 
echo ${TEXT} >> ${OUTPUT}/result6.tbl

cat ${OUTPUT}/result6.tbl
