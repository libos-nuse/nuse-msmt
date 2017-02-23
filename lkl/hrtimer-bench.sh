#!/bin/bash
# sudo required

source ./netperf-common.sh
mkdir -p ${OUTPUT}/hrtimer
exec > >(tee ${OUTPUT}/hrtimer/$0.log) 2>&1

DELAYED_DEST=2.1.1.2
DELAYED_SELF=2.1.1.3

NETPERF_ARGS="-H ${DELAYED_DEST} -l30 -- -K bbr -o"

# native
sudo tc qdisc replace dev ens3f0 root fq pacing
sudo perf record -e timer:hrtimer_start -e timer:hrtimer_expire_entry \
 -aR -C0 -o ${OUTPUT}/hrtimer/perf.data \
 ${TASKSET} netperf ${NETPERF_ARGS} 
sudo perf script -i ${OUTPUT}/hrtimer/perf.data > ${OUTPUT}/hrtimer/native-log.txt

# lkl
sudo tc qdisc del dev ens3f0 root fq pacing

# printf based
# LKL_HIJACK_DEBUG=1 LKL_HIJACK_BOOT_CMDLINE="mem=1G" \
#  LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 1000000000" \
#  LKL_HIJACK_NET_QDISC="root|fq" LKL_HIJACK_OFFLOAD=0xd903 \
#  LKL_HIJACK_NET_IFTYPE=tap LKL_HIJACK_NET_IFPARAMS=tap1 \
#  LKL_HIJACK_NET_IP=${DELAYED_SELF} LKL_HIJACK_NET_NETMASK_LEN=24 \
#  lkl-hijack.sh netperf ${NETPERF_ARGS} |& tee ${OUTPUT}/hrtimer/lkl-log.txt


#sudo /home/tazaki/work/perf-tools/bin/uprobe 'p:/home/tazaki/work/netperf2/lkl/src/netperf:rumpns_qdisc_watchdog_timestamp idx=%di:s32 ts=%si:s64'\
# > ${OUTPUT}/hrtimer/lkl-log.txt &

# musl libc based
FIXED_ADDRESS=${DELAYED_SELF} FIXED_MASK=24 \
LKL_SYSCTL="net.ipv4.tcp_wmem=4096 87380 1000000000" \
LKL_NET_QDISC="root|fq" \
LKL_BOOT_CMDLINE="mem=9G" \
RUMP_VERBOSE=1 \
rexec ${LKLMUSL_NETPERF}/netperf.qdisc-debug tap:tap1 -- ${NETPERF_ARGS} | tee ${OUTPUT}/hrtimer/lkl-log.txt

# kill -9 %1
# rm -f /var/tmp/.ftrace-lock


#/home/tazaki/work/perf-tools/bin/uprobe 'p:/home/tazaki/work/netperf2/lkl/src/netperf:rumpns_qdisc_watchdog_timestamp idx=%di:s32 ts=%si:s64' > /dev/null


sh ./hrtimer-delay-plot.sh ${OUTPUT}
sudo chown -R tazaki ${OUTPUT}/hrtimer
