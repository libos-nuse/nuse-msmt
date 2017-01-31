#!/bin/sh

# native
sudo perf record  -e timer:hrtimer_start -e timer:hrtimer_expire_entry -e probe:qdisc_watchdog  -e probe:qdisc_watchdog_schedule_ns  -aR -C0 taskset -c 0 netperf -H 2.1.1.2 -l3 -- -K bbr
sudo perf script > native-log.txt

# lkl
sudo ./bin/uprobe 'p:/home/tazaki/gitworks/netperf2/lkl/src/netperf:rumpns_qdisc_watchdog_timestamp idx=%di:s32 ts=%si:s64' > log-lkl.txt &

FIXED_GATEWAY=10.1.0.1 \
FIXED_ADDRESS=10.1.0.2 \
FIXED_MASK=24 \
LKL_SYSCTL="net.ipv4.tcp_wmem|4096 87380 100000000" \
LKL_NET_QDISC="root|fq" \
LKL_MEMSIZE=1G \
rexec ./src/netperf tap:tap0 -- -H 10.1.0.1  -- -K bbr

kill -9 %1
rm -f /var/tmp/.ftrace-lock


