#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source ${SCRIPT_DIR}/test-common.sh

OUTPUT=$1
#PRINT_NZ="print"

mkdir -p ${OUTPUT}

rm -f ${OUTPUT}/{${TESTS4// /,}}.svg
for test in $TESTS4
do

    ln=0
    cat <<EOF > ${OUTPUT}/$test.svg
<?xml version="1.0" encoding="utf-8"?>

<svg xmlns="http://www.w3.org/2000/svg" width="1500" height="210" viewBox="0 0 1500 200">


<defs>
  <pattern id="no_test" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse" viewBox="0 0 20 20">
    <path d="M 0,0 l 20,20 M 20,0 l -20,20" stroke="black" stroke-width="2" />
  </pattern>
</defs>

<g text-anchor="left" dominant-baseline="central" font-size="15">
  <text x="0" y="50" transform="translate(0, 100) rotate(270)">($test)</text>
  <text x="0" y="10">lwip</text>
  <text x="0" y="30">seastar</text>
  <text x="0" y="50">osv</text>
  <text x="0" y="70">gvisor</text>
  <text x="0" y="90">mtcp</text>
  <text x="0" y="110">rump</text>
  <text x="0" y="130">graphene</text>
  <text x="0" y="150">linux</text>
  <text x="0" y="170">lkl</text>
  <text x="0" y="190">lkl-osx</text>
EOF

  if [ -n "$PRINT_NZ" ] ; then
  echo '<text x="0" y="170">linux-nz</text>' >> ${OUTPUT}/$test.svg
  echo '<text x="0" y="190">lkl-nz</text>' >> ${OUTPUT}/$test.svg
  fi

    cat <<EOF >> ${OUTPUT}/$test.svg
</g>

<g stroke='black' stroke-width="2">
EOF
    while read row; do
	columns=(${row// /_})
	columns=(${columns//,/ })
	x=$((ln*20+60))
	results=""

#	echo ${columns[@]}
#	echo ${columns[8]}
#	echo ${result[8]}
	for idx in {1..10} ; do
	    if [ "${columns[$idx]}" == "!INCONCLUSIVE!" ] ; then
		result[$idx]="yellow"
	    elif [ "${columns[$idx]}" == "!FAILED!" ] ; then
		result[$idx]="red"
	    elif [ "${columns[$idx]}" == "!NO_RESPONSE!" ] ; then
		result[$idx]="black"
	    elif [ "${columns[$idx]}" == "_" ] ; then
		result[$idx]="#00f200"
	    elif [ "${columns[$idx]}" == "n/a" ] ; then
		result[$idx]="white"
	    elif [ "${columns[$idx]}" == "" ] ; then
		result[$idx]="#00f200"
	    fi
	done
	cat <<EOF >> ${OUTPUT}/$test.svg
//${columns[@]}
<rect y="0"   x="$x" width='20' height='20' fill="${result[1]}">
  <title>lwip: ${columns[0]}</title>
</rect>
<rect y="20"  x="$x" width='20' height='20' fill="${result[2]}">
  <title>seastar: ${columns[0]}</title>
</rect>
<rect y="40"  x="$x" width='20' height='20' fill="${result[3]}">
  <title>osv: ${columns[0]}</title>
</rect>
<rect y="60"  x="$x" width='20' height='20' fill="${result[4]}">
  <title>gvisor: ${columns[0]}</title>
</rect>
<rect y="80"  x="$x" width='20' height='20' fill="${result[5]}">
  <title>mtcp: ${columns[0]}</title>
</rect>
<rect y="100" x="$x" width='20' height='20' fill="${result[6]}">
  <title>rump: ${columns[0]}</title>
</rect>
<rect y="120" x="$x" width='20' height='20' fill="${result[7]}">
  <title>graphene: ${columns[0]}</title>
</rect>
<rect y="140" x="$x" width='20' height='20' fill="${result[8]}">
  <title>linux: ${columns[0]}</title>
</rect>
<rect y="160" x="$x" width='20' height='20' fill="${result[9]}">
  <title>lkl: ${columns[0]}</title>
</rect>
<rect y="180" x="$x" width='20' height='20' fill="${result[10]}">
  <title>lkl-osx: ${columns[0]}</title>
</rect>
EOF

  if [ -n "$PRINT_NZ" ] ; then
	cat <<EOF >> ${OUTPUT}/$test.svg
<rect y="180" x="$x" width='20' height='20' fill="${result[11]}">
  <title>linux-nozebra: ${columns[0]}</title>
</rect>
<rect y="200" x="$x" width='20' height='20' fill="${result[12]}">
  <title>lkl-nozebra: ${columns[0]}</title>
</rect>
EOF
  fi

	ln=$((++ln))
    done < ${OUTPUT}/$test.csv

    cat <<EOF >> ${OUTPUT}/$test.svg
</g>
</svg>
EOF

convert -transparent white ${OUTPUT}/$test.svg ${OUTPUT}/$test.png
inkscape ${OUTPUT}/$test.svg -E ${OUTPUT}/$test.eps --export-ignore-filters
done

# generate legend information
cat <<EOF > ${OUTPUT}/legend.svg
<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="210" height="60" viewBox="0 0 210 60">

<g text-anchor="left" dominant-baseline="central" font-size="15">
  <rect x="0"   y="10" width='20' height='20' fill="#00f200" />
  <text x="30"  y="20">Pass</text>
  <rect x="80"  y="10" width='20' height='20' fill="red" />
  <text x="110" y="20">Fail</text>
  <rect x="150" y="10" width='20' height='20' fill="yellow" />
  <text x="180" y="20">Fail (Inconclusive)</text>
  <rect x="0" y="40" width='20' height='20' fill="black" />
  <text x="30" y="50">Error</text>
  <rect x="80" y="40" width='20' height='20' fill="white" stroke="black" />
  <text x="110" y="50">No Test</text>
</g>
</svg>
EOF

convert -transparent white ${OUTPUT}/legend.svg ${OUTPUT}/legend.png
inkscape ${OUTPUT}/legend.svg -E ${OUTPUT}/legend.eps --export-ignore-filters
