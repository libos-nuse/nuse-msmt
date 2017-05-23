#!/bin/sh

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/netperf-common.sh"

TESTNAMES="TCP_STREAM"
DEST_ADDR="1.1.1.2"
SELF_ADDR="1.1.1.3"
HOST_ADDR="1.1.1.1"
export FIXED_ADDRESS="$SELF_ADDR"
export FIXED_MASK=24
TRIALS=1

LKLMUSL_NGINX="$PROJECT_ROOT/rump-nginx/"
NATIVE_WRK="$PROJECT_ROOT/wrk/"

OUTPUT="$(date -I)"

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/nginx-*.dat

  # for netserver (rx) tests
  # for TCP_xx tests (netperf)
  for num in $(seq 1 "$TRIALS"); do
    for size in 64 128 256 512 1024 1500 2048; do
      nginx::run wrk $num $size
    done
  done

  bash "$SCRIPT_DIR/nginx-plot.sh" "$OUTPUT"
}

nginx::run() {
  nginx::lkl "$@"
  nginx::native "$@"
}

nginx::lkl() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://$SELF_ADDR/$ex_argb.img"

  setup_lkl

  echo "$(tput bold)== lkl-musl ($test-$num) ==$(tput sgr0)"
  pkill nginx
  taskset 3 rexec "$LKLMUSL_NGINX/nginx/objs/nginx" \
    "$LKLMUSL_NGINX/images/full.iso" tap:tap0 -- -c /data/conf/nginx.conf &

  ssh -t "$DEST_ADDR" sudo arp -d "$FIXED_ADDRESS"
  ssh "$DEST_ADDR" "$NATIVE_WRK/wrk" "$wrk_args" \
    |& tee -a "$OUTPUT/nginx-$test-musl-$num.dat"
)
}

nginx::native() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://${HOST_ADDR}/${ex_arg}b.img"

  echo "$(tput bold)== native ($test-$num)  ==$(tput sgr0)"
  pkill nginx
  ssh "$DEST_ADDR" "$NATIVE_WRK/wrk" "$wrk_args" \
    |& tee -a "$OUTPUT/nginx-$test-native-$num.dat"
)
}

main
