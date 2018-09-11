#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
#source "$SCRIPT_DIR/netperf-common.sh"

DEST_ADDR="3.3.3.2"
SELF_ADDR="3.3.3.3"
HOST_ADDR="3.3.3.5"
export FIXED_ADDRESS="$SELF_ADDR"
export FIXED_MASK=24
TRIALS=1

LKLMUSL_NGINX="$HOME/gitworks/rumprun-packages/"
NATIVE_WRK="work/wrk/"
export PATH=~/bin:~/gitworks/frankenlibc/rump/bin:${PATH}

OUTPUT="$(date "+%Y-%m-%d")"

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/nginx-*.dat

  # for nginx/wrk tests
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
  nginx::docker "$@"
}

nginx::lkl() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://$SELF_ADDR/${ex_arg}b.img"

  #setup_lkl

  echo "$(tput bold)== lkl ($test-$num-p${ex_arg}) ==$(tput sgr0)"
  sudo killall -9 nginx
  sudo rexec "$LKLMUSL_NGINX/nginx/bin/nginx" \
    "$LKLMUSL_NGINX/nginx/images/data.iso" tap:tap0 config:../lkl.json \
    | grep -v fallback &
  sleep 1
  sudo ifconfig tap0 up; sudo ifconfig bridge1 addm tap0

  ssh -t "$DEST_ADDR" sudo arp -d "$FIXED_ADDRESS"
  ssh "$DEST_ADDR" "$NATIVE_WRK/wrk" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-lkl-$num.dat"

  sudo kill $!
  sudo wait $! 2>/dev/null
)
}

nginx::native() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://${HOST_ADDR}:8080/${ex_arg}b.img"

  echo "$(tput bold)== native ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  nginx -s stop
  nginx
  ssh "$DEST_ADDR" "$NATIVE_WRK/wrk" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-native-$num.dat"
  nginx -s stop
)
}

nginx::docker() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://${HOST_ADDR}/${ex_arg}b.img"

  echo "$(tput bold)== docker ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --rm -p 80:80 \
   -v /Users/tazaki/gitworks/nuse-msmt/apsys/nginx/nginx-docker.conf:/etc/nginx/nginx.conf:ro \
  nginx-test nginx &

  sleep 5
  ssh "$DEST_ADDR" "$NATIVE_WRK/wrk" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-docker-$num.dat"

  kill $!
  wait $! 2>/dev/null
)
}


main
