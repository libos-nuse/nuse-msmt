#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=$1

TESTS="arp ip icmp ipgw"

TEXT=""

for test in $TESTS
do
 if [ -n "${TEXT}" ] ; then
  TEXT="${TEXT} &"
 fi

 RESULT=$(grep Number ${OUTPUT}/$test-out.log | \
  grep -E "passed|run" | grep Number | \
  awk '{num[$4]=$5} END { print num["passed:"] "/" num["run:"] }')
 TEXT="${TEXT} ${RESULT}"
done


echo -n "%" > ${OUTPUT}/result4.tbl
echo ${TESTS} | sed "s/ / \& /g" >> ${OUTPUT}/result4.tbl 
echo ${TEXT} >> ${OUTPUT}/result4.tbl

cat ${OUTPUT}/result4.tbl
