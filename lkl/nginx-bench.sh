#!/bin/sh

TESTNAMES="TCP_STREAM"
#TESTNAMES=""
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
HOST_ADDR="1.1.1.1"
export FIXED_ADDRESS=${SELF_ADDR}
export FIXED_MASK=24
TRIALS=1

# disable offload
sudo ethtool -K br0 tso off gso off rx off tx off
sudo ethtool -K ens3f1 tso off gro off gso off rx off tx off

LKLMUSL_NGINX=/home/tazaki/work/rump-nginx/
NATIVE_WRK=/home/tazaki/work/wrk/
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/
/wrk 

OUTPUT=`date -I`

mkdir -p ${OUTPUT}

run_nginx_turn()
{
pkill nginx

test=$1
num=$2
ex_arg=$3

echo "== lkl-musl ($test-$num) =="
WRK_ARGS="http://${SELF_ADDR}/${ex_arg}b.img"
taskset 3 rexec ${LKLMUSL_NGINX}/nginx/objs/nginx \
  ${LKLMUSL_NGINX}/images/full.iso tap:tap0 -- -c /data/conf/nginx.conf &

ssh -t ${DEST_ADDR} sudo arp -d ${FIXED_ADDRESS}
ssh ${DEST_ADDR} ${NATIVE_WRK}/wrk ${WRK_ARGS} |& tee -a ${OUTPUT}/nginx-$test-musl-$num.dat
pkill nginx


echo "== native ($test-$num)  =="
WRK_ARGS="http://${HOST_ADDR}/${ex_arg}b.img"
ssh ${DEST_ADDR} ${NATIVE_WRK}/wrk ${WRK_ARGS} |& tee -a ${OUTPUT}/nginx-$test-native-$num.dat


}


rm -f ${OUTPUT}/nginx-*.dat

# for netserver (rx) tests
# for TCP_xx tests (netperf)
for num in `seq 1 ${TRIALS}`
do
for size in 64 128 256 512 1024 1500 2048
do

run_nginx_turn wrk $num $size

done
done

sh `dirname ${BASH_SOURCE:-$0}`/nginx-plot.sh ${OUTPUT}
