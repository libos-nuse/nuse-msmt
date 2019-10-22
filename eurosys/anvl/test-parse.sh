#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1
STACK=$2
TESTS=$3
PROTO=$4

TEXT=""

for test in $TESTS
do
 if [ -n "${TEXT}" ] ; then
  TEXT="${TEXT} &"
 fi

 RESULT=$(grep Number ${OUTPUT}/$STACK-$test-out.log | \
  grep -E "passed|run" | grep Number | \
  awk '{num[$4]=$5} END { print num["passed:"] "/" num["run:"] }')
 TEXT="${TEXT} ${RESULT}"
done


echo -n "%" > ${OUTPUT}/result$PROTO-$STACK.tbl
echo ${TESTS} | sed "s/ / \& /g" >> ${OUTPUT}/result$PROTO-$STACK.tbl
echo ${TEXT} >> ${OUTPUT}/result$PROTO-$STACK.tbl

cat ${OUTPUT}/result$PROTO-$STACK.tbl
