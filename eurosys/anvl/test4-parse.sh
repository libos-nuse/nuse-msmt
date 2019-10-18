#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1

TEXT=""

for test in $TESTS4
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
echo ${TESTS4} | sed "s/ / \& /g" >> ${OUTPUT}/result4.tbl
echo ${TEXT} >> ${OUTPUT}/result4.tbl

cat ${OUTPUT}/result4.tbl
