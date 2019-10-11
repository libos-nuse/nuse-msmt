#!/bin/bash

source ./test-common.sh
DIR4="linux lwip osv gvisor lkl mtcp seastar"
DIR6="linux lwip lkl"
DIR4="linux lkl"
DIR6=""

for dir in ${DIR4}
do
  cd $dir; bash ../test4.sh; cd ..
done

for dir in ${DIR6}
do
  cd $dir; bash ../test6.sh; cd ..
done

PAYLOAD=`tail */${OUTPUT}/result4.tbl`
bash -x ${SCRIPT_DIR}/slack-notify.sh "$PAYLOAD"

tail */${OUTPUT}/result4.tbl
tail */${OUTPUT}/result6.tbl
