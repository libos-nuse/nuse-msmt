#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=$1

mkdir -p ${OUTPUT}

STACKS="lwip seastar osv gvisor mtcp rump linux lkl"
TESTS="arp ip icmp ipgw"

for stack in $STACKS
do
for test in $TESTS
do

 cd $stack
 # echo "test-$stack,$stack" > ${OUTPUT}/$test.csv
 grep "<<" ${OUTPUT}/$test-out.log | \
   sed -e 's/<< //' -e 's/://' -e 's/ /,/' -e 's/Passed/-/' \
   -e 's/NO RESPONSE/NO-RESPONSE/' \
   > ${OUTPUT}/$test.csv
 cd ..

done
done

for test in $TESTS
do

# join lwip + seastar
q -d, "select l.c1,l.c2,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from lwip/${OUTPUT}/$test.csv l \
  left join seastar/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + osv
q -d, "select l.c1,l.c2,l.c3,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join osv/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + gvisor
q -d, "select l.c1,l.c2,l.c3,l.c4,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join gvisor/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + mtcp
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join mtcp/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + rump
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join rump/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + linux
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join linux/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# join all + lkl
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join lkl/${OUTPUT}/$test.csv r \
  on l.c1==r.c1" | \
# cosmetic
  sed "s/\-/ /g" \
  > ${OUTPUT}/$test.csv


## paste -d ',' {lwip,seastar,osv,gvisor,mtcp,rump,linux,lkl}/${OUTPUT}/$test.csv | \
##   sed "s/,,/,n\/a,n\/a,/g" | csv_to_db | \
##   dbcoldefine test lwip dum1 seastar dum2 osv dum3 gvisor dum4 mtcp dum5 rump dum6 linux dum7 lkl | \
##   dbcol test lwip seastar osv gvisor mtcp rump linux lkl | \
##   db_to_csv | grep -v \# | sed "s/\-/ /g" \
##   > ${OUTPUT}/$test.csv

done
