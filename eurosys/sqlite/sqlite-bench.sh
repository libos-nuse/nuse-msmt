#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"

# macos has different syntax
OUTPUT=$SCRIPT_DIR/$(date "+%Y-%m-%d")

PREFIX=sqlite-bench
TRIALS="1"
ENTRIES="1000000"
VSIZES="1 8 256 1024 8192"
TESTNAMES="fillseq fillrandom readseq readrandom"
DB_PATH=/tmp/

SRC_DIR=/home/tazaki/work/ukontainer/
FRANKENLIBC_DIR=${SRC_DIR}/frankenlibc
SQLITE_BENCH_DIR=${SRC_DIR}/sqlite-bench
#TMP variable
export PATH=${FRANKENLIBC_DIR}/rump/bin:${PATH}
export PATH=${FRANKENLIBC_DIR}/liunx/tools/lkl/bin:${PATH}

main() {
  initialize

  # for sqlite-bench tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $VSIZES; do
      for test in $TESTNAMES; do
        sqlite::run $test $num $size \
        "--value_size=$size --num=$ENTRIES --db=$DB_PATH"
      done
    done
  done

  bash "$SCRIPT_DIR/sqlite-plot.sh" "$OUTPUT"
}

initialize() {
  export LKL_BOOT_CMDLINE="mem=16G"

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$0.log") 2>&1
}

sqlite::run() {
  sqlite::lkl    "$@"
  sqlite::native "$@"
  sqlite::docker "$@" "runc"
  sqlite::docker "$@" "kata-runtime"
  sqlite::docker "$@" "runsc-ptrace-user"
}

sqlite::lkl() {
(
  local test="$1"
  local num="$2"
  local vsize="$3"
  local ex_arg="$4"
  local sqlite_args="--raw=1 --benchmarks=$test $ex_arg"

  echo "$(tput bold)== lkl-musl ($test-$num-$vsize)  ==$(tput sgr0)"
  docker run -i --net=none --runtime=runu-dev --rm  \
	  -e LKL_BOOT_CMDLINE=$LKL_BOOT_CMDLINE \
	  -e LKL_ROOTFS=imgs/python.img \
	  thehajime/runu-base:0.1 sqlite-bench $sqlite_args \
   | tee "$OUTPUT/$PREFIX-$test-lkl-vs$size-$num.dat"
  wait
)
}

sqlite::native() {
(
  local test="$1"
  local num="$2"
  local vsize="$3"
  local ex_arg="$4"
  local sqlite_args="--raw=1 --benchmarks=$test $ex_arg"

  echo "$(tput bold)== native ($test-$num-$vsize)  ==$(tput sgr0)"
  ${SQLITE_BENCH_DIR}/sqlite-bench \
   $sqlite_args > "$OUTPUT/$PREFIX-$test-native-vs$size-$num.dat"
)
}

sqlite::docker() {
( 
  local test="$1"
  local num="$2"
  local vsize="$3"
  local ex_arg="$4"
  local runtime="$5"
  local sqlite_args="--raw=1 --benchmarks=$test $ex_arg"
  
  echo "$(tput bold)== docker ($runtime) ($test-$num-$vsize)  ==$(tput sgr0)"
  docker run --runtime=$runtime --rm \
   retrage/sqlite-bench:latest \
   $sqlite_args > "$OUTPUT/$PREFIX-$test-$runtime-vs$size-$num.dat"
)
}

main
