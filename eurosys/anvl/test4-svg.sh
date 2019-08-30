#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
OUTPUT=$1

mkdir -p ${OUTPUT}

STACKS="lwip seastar osv gvisor mtcp rump linux lkl"
TESTS="arp ip icmp ipgw"

rm -f ${OUTPUT}/{${TESTS// /,}}.svg
for test in $TESTS
do

    ln=0
    cat <<EOF > ${OUTPUT}/$test.svg
<?xml version="1.0" encoding="utf-8"?>

<svg xmlns="http://www.w3.org/2000/svg" width="1500" height="200" viewBox="0 0 1500 200">

<g text-anchor="left" dominant-baseline="central">
  <text x="0" y="10">lwip</text>
  <text x="0" y="30">seastar</text>
  <text x="0" y="50">osv</text>
  <text x="0" y="70">gvisor</text>
  <text x="0" y="90">mtcp</text>
  <text x="0" y="110">rump</text>
  <text x="0" y="130">linux</text>
  <text x="0" y="150">lkl</text>
</g>

<g stroke='black' stroke-width="2">
EOF
    while read row; do
	columns=(${row// /_})
	columns=(${columns//,/ })
	x=$((ln*20+50))
	results=""

#	echo ${columns[@]}
#	echo ${columns[8]}
#	echo ${result[8]}
	for idx in {1..8} ; do
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
<rect y="80"  x="$x" width='20' height='20' fill="${result[5]}"/>
<rect y="100" x="$x" width='20' height='20' fill="${result[6]}"/>
<rect y="120" x="$x" width='20' height='20' fill="${result[7]}"/>
<rect y="140" x="$x" width='20' height='20' fill="${result[8]}"/>
EOF

	ln=$((++ln))
    done < ${OUTPUT}/$test.csv

    cat <<EOF >> ${OUTPUT}/$test.svg
</g>
</svg>
EOF
done
