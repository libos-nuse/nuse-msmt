#!/bin/sh

set -e

mkdir -p git

stage1() {
    REPO=$1
    URL=$2
    START=$3
    FILTER=$4
git clone $URL git/$REPO || true
(
    cd git/$REPO

    git fetch origin 'refs/replace/*:refs/replace/*'
    git log --date=iso --no-merges --pretty="%H %cd %s" --numstat --since="$START-01-01 00:00:00" \
	$FILTER > ../../$REPO-numstat-since-$START.txt

    cd ../..
)

}

stage2() {
    REPO=$1
    START=$2
    ./parse-git.py -u year $REPO-numstat-since-$START.txt > $REPO-numstat-since-$START.dat
}

# linux
#stage1 linux https://github.com/torvalds/linux 2002 net
stage1 linux https://github.com/mpe/linux-fullhistory 2002 "--all net"
stage2 linux 2002

# lwip
stage1 lwip git://git.savannah.gnu.org/lwip.git 2002
stage2 lwip 2002

# gvisor
stage1 gvisor https://github.com/google/gvisor 2017
stage2 gvisor 2017

# seastar
stage1 seastar https://github.com/scylladb/seastar 2015
stage2 seastar 2015

# netbsd
stage1 netbsd https://github.com/NetBSD/src 2002 "sys/net*"
stage2 netbsd 2002


