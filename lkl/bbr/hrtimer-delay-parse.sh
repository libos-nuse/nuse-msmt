#!/bin/sh

# native from perf script output
sudo perf script > native-log.txt
cat native-log.txt |grep timer:hrtim | grep qdisc |\
       awk '{ gsub(/:/, "") } { gsub(/expires=/, "") } { gsub(/now=/, "") } $5 ~ /start/ { base = $8 } $5 ~ /expire/ { { printf "%.f %.f \n", $4 * 1000000, ($7 - base); base = 0 } }' > native-delay.dat

cat lkl-log.txt  |grep fq: | \
       awk  '{ gsub(/]/,"")} $4 ~ /sched/ { base = $9 } $4 ~ /fired/ { printf "%s %.f\n", $2, ($8 - base); base = 0 }'  > lkl-delay.dat

lkl-delay.dat| dbcoldefine time delay | dbcol delay | dbsort -n delay | dbrowenumerate | dbcolpercentile delay
