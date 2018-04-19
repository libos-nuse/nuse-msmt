#!/bin/bash

TRIALS=1

OUTPUT="$(date "+%Y-%m-%d")"
export PATH=~/bin:~/gitworks/frankenlibc/rump/bin:${PATH}

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/mem-*.dat

  mem::run

  bash "$SCRIPT_DIR/mem-plot.sh" "$OUTPUT"
}

mem::run() {
  mem::lkl "$@"
  mem::noah "$@"
  mem::native "$@"
  mem::docker "$@"
}

mem::lkl() {
(

  echo "$(tput bold)== lkl ==$(tput sgr0)"
  rexec ./hello-lkl &
  vmmap $! | grep footprint | tee -a "$OUTPUT/mem-lkl.dat"
  kill $!
  wait $! 2>/dev/null
)
}

mem::noah() {
(
  echo "$(tput bold)== noah ==$(tput sgr0)"
  noah ./hello-noah &
  PID_NOAH=$(ps aux | grep -E "noah" |grep perl| awk '{print $2}')
  PID_VMM=$(ps aux | grep -E "noah" |grep tree| awk '{print $2}')
  sudo vmmap $PID_NOAH | grep footprint | tee -a "$OUTPUT/mem-noah.dat"
  sudo vmmap $PID_VMM | grep footprint | tee -a "$OUTPUT/mem-noah.dat"
 
  kill $PID_NOAH
  kill $PID_VMM
  wait $PID_NOAH $PID_VMM 2>/dev/null
)
}

mem::native() {
(
  echo "$(tput bold)== native  ==$(tput sgr0)"
  ./hello-macos &
  vmmap $! | grep footprint | tee -a "$OUTPUT/mem-native.dat"
  kill $!
  wait $! 2>/dev/null
)
}

mem::docker() {
(
  echo "$(tput bold)== docker ==$(tput sgr0)"

  docker run -v /Users/tazaki:/mnt/tazaki \
   thehajime/byte-unixbench:latest \
   /mnt/tazaki/gitworks/nuse-msmt/apsys/mem/hello-noah &

  PID_NS=$(ps aux | grep -E "hello" |grep -v grep| awk '{print $2}')
  PID_VMM=$(ps aux | grep -E "hyper" |grep -v grep| awk '{print $2}')
  sudo vmmap $PID_NS | grep footprint | tee -a "$OUTPUT/mem-docker.dat"
  sudo vmmap $PID_VMM | grep footprint | tee -a "$OUTPUT/mem-docker.dat"

  kill $!
  wait $! 2>/dev/null
)
}


main
