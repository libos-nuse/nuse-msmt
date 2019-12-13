#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1

mkdir -p ${OUTPUT}

rm -f ${OUTPUT}/{${TESTS6// /,}}.svg
for test in $TESTS6
do

    ln=0
    cat <<EOF > ${OUTPUT}/$test.svg
<?xml version="1.0" encoding="utf-8"?>

<svg xmlns="http://www.w3.org/2000/svg" width="4000" height="200" viewBox="0 0 4000 200">

<g text-anchor="left" dominant-baseline="central">
  <text x="0" y="50" transform="translate(0, 100) rotate(270)">($test)</text>
  <text x="0" y="10">lwip</text>
  <text x="0" y="30">rump</text>
  <text x="0" y="50">linux</text>
  <text x="0" y="70">lkl</text>
</g>

<g stroke='black' stroke-width="2">
EOF
    while read row; do
	if [ $ln == 0 ] ; then
	    ln=$((++ln))
	    continue
	fi
	columns=(${row// /_})
	columns=(${columns//,/ })
	x=$((ln*20+50))
	results=""

#	echo ${columns[@]}
#	echo ${columns[8]}
#	echo ${result[8]}
	for idx in {1..4} ; do
	    if [ "${columns[$idx]}" == "!INCONCLUSIVE!" ] ; then
		result[$idx]="yellow"
	    elif [ "${columns[$idx]}" == "!FAILED!" ] ; then
		result[$idx]="red"
	    elif [ "${columns[$idx]}" == "!NO_RESPONSE!" ] ; then
		result[$idx]="pink"
	    elif [ "${columns[$idx]}" == "_" ] ; then
		result[$idx]="green"
	    elif [ "${columns[$idx]}" == "n/a" ] ; then
		result[$idx]="gray"
	    elif [ "${columns[$idx]}" == "" ] ; then
		result[$idx]="green"
	    fi
	done
	cat <<EOF >> ${OUTPUT}/$test.svg
//${columns[@]}
<rect y="0"   x="$x" width='20' height='20' fill="${result[1]}"/>
<rect y="20"  x="$x" width='20' height='20' fill="${result[2]}"/>
<rect y="40"  x="$x" width='20' height='20' fill="${result[3]}"/>
<rect y="60"  x="$x" width='20' height='20' fill="${result[4]}"/>
EOF

	ln=$((++ln))
    done < ${OUTPUT}/$test.csv

    cat <<EOF >> ${OUTPUT}/$test.svg
</g>
</svg>
EOF
done
