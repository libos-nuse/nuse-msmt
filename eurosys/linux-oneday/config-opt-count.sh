#!/bin/sh

OUTPUT=$(pwd)
FILENAME=$OUTPUT/num-linux-options.dat

exec > "$OUTPUT/$(basename $0).log" 2>&1

cd git/linux
TAGS=$(git tag -l | sort -V)

rm -f $FILENAME

for tag in $TAGS
do

    if [[ "$tag" =~ rc || "$tag" =~ v2.6.11 ]] ; then
	continue
    fi
    # checkout tag
    git reset --hard
    git clean -f -d
    git checkout $tag

    # 0. first try `make allyesconfig`
    rm -f .config
    make allyesconfig > /dev/null

    # 1. if failed, try `make oldconfig`
    if [ $? -ne 0 ] ; then
	make oldconfig > /dev/null

	# 2. if failed, try `make oldconfig ARCH=i386`
	if [ $? -ne 0 ] ; then
	    make oldconfig ARCH=i386 > /dev/null 2>&1
	fi
    fi

    # 3. count by grep
    GREP1=$(find ./ -name config.in | xargs grep -h CONFIG |grep -E "bool|tristate" | grep -v "^#" | sed "s/.*\(CONFIG_.*\)/\1/"| sed "s/[y|n]//" | sed "s/ //" | sort -u | wc -l)
    GREP2=$(find ./ -name Kconfig\* | xargs grep -h config | grep -v -E "source|menu" | sort -u | wc -l)
    GREP=$(expr $GREP1 + $GREP2)
    NUM=$(grep CONFIG .config| wc -l)
    DATE=$(git log --date=format:"%Y-%m-%d"  --pretty="%ad" $tag |head -n1)
    echo "$DATE $tag $NUM $GREP" >> $FILENAME

done

sh $OUTPUT/config-opt-plot.sh
