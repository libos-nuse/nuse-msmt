#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1
mkdir -p ${OUTPUT}

for stack in $STACKS4
do
for test in $TESTS4
do

 # echo "test-$stack,$stack" > ${OUTPUT}/$test.csv
 if [ -f ${OUTPUT}/$stack-$test-out.log ] ; then
     grep "<<" ${OUTPUT}/$stack-$test-out.log | \
	 sed -e 's/<< //' -e 's/://' -e 's/ /,/' -e 's/Passed/-/' \
	     -e 's/NO RESPONSE/NO-RESPONSE/' \
	     > ${OUTPUT}/$stack-$test.csv
 else
     mkdir -p ${OUTPUT}
     echo "," > ${OUTPUT}/$stack-$test.csv
 fi

done
done

for test in $TESTS4
do

# join lwip + seastar
q -d, "select l.c1,l.c2,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from ${OUTPUT}/lwip-$test.csv l \
  left join ${OUTPUT}/seastar-$test.csv r \
  on l.c1==r.c1" | \
# join all + osv
q -d, "select l.c1,l.c2,l.c3,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/osv-$test.csv r \
  on l.c1==r.c1" | \
# join all + gvisor
q -d, "select l.c1,l.c2,l.c3,l.c4,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/gvisor-$test.csv r \
  on l.c1==r.c1" | \
# join all + mtcp
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/mtcp-$test.csv r \
  on l.c1==r.c1" | \
# join all + rump
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/rump-$test.csv r \
  on l.c1==r.c1" | \
# join all + graphene
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/graphene-$test.csv r \
  on l.c1==r.c1" | \
# join all + linux
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/linux-$test.csv r \
  on l.c1==r.c1" | \
# join all + lkl
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,l.c9,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/lkl-$test.csv r \
  on l.c1==r.c1" | \
# join all + lkl-osx
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,l.c9,l.c10,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/lkl-osx-$test.csv r \
  on l.c1==r.c1" | \
# join all + linux-nozebra
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,l.c9,l.c10,l.c11,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/linux-nozebra-$test.csv r \
  on l.c1==r.c1" | \
# join all + lkl-nozebra
q -d, "select l.c1,l.c2,l.c3,l.c4,l.c5,l.c6,l.c7,l.c8,l.c9,l.c10,l.c11,l.c12,CASE when r.c1 is NULL then 'n/a' else r.c2 END \
  from - l \
  left join ${OUTPUT}/lkl-nozebra-$test.csv r \
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
