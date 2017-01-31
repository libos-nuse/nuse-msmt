PSIZES="64 128 256 512 1024 1500 65507"
PSIZE_XTICS="('64' 0, '128' 1, '256' 2, '512' 3, '1024' 4, '1500' 5, '65507' 6)"
SYS_MEM="512M 1G"
TCP_WMEM="4194304 30000000 100000000 2000000000"
QDISC_PARAMS="root|fq none"
CC_ALGO="bbr cubic"
OFFLOADS="0 0003 d903" #disable, CSUM, CSUM/TSO4/MRGRCVBUF/UFO + TSO6

TRIALS=5

LKLMUSL_NETPERF=/home/tazaki/work/netperf2/lkl/src/
NATIVE_NETPERF=/home/tazaki/work/netperf-2.7.0/src/
PATH=${PATH}:/home/tazaki/work/frankenlibc/rump/bin/:/home/tazaki/work/lkl-linux/tools/lkl/bin/

TASKSET="taskset -c 0"
OUTPUT=`date -I`

export LKL_HIJACK_OFFLOAD=0xc803
#export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem|4096 87380 100000000"
#export LKL_HIJACK_MEMSIZE=1G
#LKL_SYSCTL="net.ipv4.tcp_wmem|4096 87380 2147483647"
#LKL_MEMSIZE=1G

