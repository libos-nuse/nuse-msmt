#!/bin/bash

source ./test-common.sh

mkdir -p $OUTPUT
exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

for dir in ${STACKS4}
do
  if [[ $dir =~ .*-nozebra ]] ; then
      real_dir=${dir/-nozebra/}
      export NO_ZEBRA=1
  fi
  cd $dir; bash ../test4.sh; cd ..
  unset NO_ZEBRA
done
bash  ${SCRIPT_DIR}/test4-csv.sh ${OUTPUT}
bash  ${SCRIPT_DIR}/test4-svg.sh ${OUTPUT}


for dir in ${STACKS6}
do
  cd $dir; bash ../test6.sh; cd ..
done

PAYLOAD=`tail */${OUTPUT}/result4.tbl`
bash -x ${SCRIPT_DIR}/slack-notify.sh "$PAYLOAD"

for test in ${TESTS4}
do
curl --silent -F file="@${OUTPUT}/$test.png" -F channels=${SLACK_CH} \
     -F token=`cat ~/.slack_token_iijlab_ra` \
     https://slack.com/api/files.upload > /dev/null
done

tail */${OUTPUT}/result4.tbl
tail */${OUTPUT}/result6.tbl
