#!/bin/bash

source ./test-common.sh
DIR4="linux-nozebra lkl-nozebra linux lwip osv gvisor lkl mtcp seastar"
DIR6="linux-nozebra lkl-nozebra linux lwip lkl linux-nozebra lkl-nozebra"
DIR4="linux-nozebra lkl-nozebra linux lkl"
#DIR4="linux-nozebra linux"
DIR6=""

mkdir -p $OUTPUT
exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

for dir in ${DIR4}
do
  if [[ $dir =~ .*-nozebra ]] ; then
      real_dir=${dir/-nozebra/}
      export NO_ZEBRA=1
  fi
  cd $dir; bash ../test4.sh; cd ..
  unset NO_ZEBRA
done

for dir in ${DIR6}
do
  cd $dir; bash ../test6.sh; cd ..
done

### XXX
ssh ${DUT_HOST} "sudo systemctl start firewalld.service"

PAYLOAD=`tail */${OUTPUT}/result4.tbl`
bash -x ${SCRIPT_DIR}/slack-notify.sh "$PAYLOAD"

tail */${OUTPUT}/result4.tbl
tail */${OUTPUT}/result6.tbl
