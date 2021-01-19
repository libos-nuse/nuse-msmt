#!/bin/bash

source ./test-common.sh

mkdir -p $OUTPUT
exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

for dir in ${STACKS4}
do
  if [[ $dir =~ .*-nozebra ]] ; then
      export NO_ZEBRA=1
  elif [[ $dir =~ "osv" ]] ; then
      sudo ip ad add 10.1.0.100/24 dev eth0
      sudo ip ad add 10.2.0.100/24 dev eth1
  elif [[ $dir =~ "gvisor" ]] ; then
      sudo ip route add 10.1.0.50/32 via 10.0.39.2
  elif [[ $dir =~ "graphene" ]] ; then
      sudo ip route add 10.1.0.100/32 via 10.0.39.2
  fi

  cd $dir
  for test in $TESTS4
  do
      echo "==$dir-$test=="
      # exec a single test
      run_DUT $dir
      sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file ../$OUTPUT/$dir-$test-out.log \
	   -l low -f anvl$test $test

  done
  bash ../${SCRIPT_DIR}/test-parse.sh ../${OUTPUT} $dir "$TESTS4" 4
  cd ..

  if [[ $dir =~ "osv" ]] ; then
      sudo ip ad del 10.1.0.100/24 dev eth0
      sudo ip ad del 10.2.0.100/24 dev eth1
  elif [[ $dir =~ "gvisor" ]] ; then
      sudo ip route del 10.1.0.50/32 via 10.0.39.2
  elif [[ $dir =~ "graphene" ]] ; then
      sudo ip route delete 10.1.0.100/32 via 10.0.39.2
  fi
  unset NO_ZEBRA

  ### XXX
  ssh ${DUT_HOST} "sudo systemctl start firewalld.service"

done
bash  ${SCRIPT_DIR}/test4-csv.sh ${OUTPUT}
bash  ${SCRIPT_DIR}/test4-svg.sh ${OUTPUT}


for dir in ${STACKS6}
do

  cd $dir
  for test in $TESTS6
  do
      echo "==$dir-$test=="
      # exec a single test
      run_DUT $dir
      sudo /opt/Ixia/IxANVL900/ANVL-BIN/anvl -file ../$OUTPUT/$dir-$test-out.log \
	   -l medium -f anvl$test $test

  done
  bash ../${SCRIPT_DIR}/test-parse.sh ../${OUTPUT} $dir "$TESTS6" 6
  cd ..

done

PAYLOAD=`tail ${OUTPUT}/result4*.tbl`
bash -x ${SCRIPT_DIR}/slack-notify.sh "$PAYLOAD"

for test in ${TESTS4}
do
curl --silent -F file="@${OUTPUT}/$test.png" -F channels=${SLACK_CH} \
     -F token=`cat ~/.slack_token_iijlab_ra` \
     https://slack.com/api/files.upload > /dev/null
done

tail ${OUTPUT}/result*.tbl
