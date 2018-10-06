#!/bin/bash

DIR4="linux lwip osv gvisor lkl mtcp seastar"
DIR6="linux lwip lkl"

for dir in ${DIR4}
do
  cd $dir; bash ../test4.sh; cd ..
done

for dir in ${DIR6}
do
  cd $dir; bash ../test6.sh; cd ..
done
