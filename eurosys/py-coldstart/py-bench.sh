#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"

TRIALS=5
OUTPUT="$SCRIPT_DIR/$(date "+%Y-%m-%d")"

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/py-coldstart-*.dat

  # python-coldstart tests
  for num in $(seq 1 "$TRIALS"); do
    py-coldstart::run $num
  done

  bash "$SCRIPT_DIR/py-plot.sh" "$OUTPUT"
}

py-coldstart::run() {
  py-coldstart::runu   "$@"
  py-coldstart::docker "$@" "runc"
  py-coldstart::docker "$@" "kata-runtime"
  py-coldstart::docker "$@" "runsc-ptrace-user"
  py-coldstart::docker "$@" "runsc-kvm-user"
}

py-coldstart::runu() {
(
  local num=$1
  local runtime=runu-dev

  echo "$(tput bold)== docker (runu-$num)  ==$(tput sgr0)"
  /usr/bin/time docker run -i --runtime=$runtime \
	  thehajime/runu-base:latest python \
	  imgs/python.img -- /main.py -m main \
	  |& tee ${OUTPUT}/py-coldstart-runu-$num.dat
)
}

py-coldstart::docker() {
(
  local num=$1
  local runtime=$2

  echo "$(tput bold)== docker ($runtime-$num)  ==$(tput sgr0)"
  /usr/bin/time docker run -i --runtime=$runtime \
	  python-hub-greenlet python /root/main.py -m main \
	  |& tee ${OUTPUT}/py-coldstart-$runtime-$num.dat
)
}


main
