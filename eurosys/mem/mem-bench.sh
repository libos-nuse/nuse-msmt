#!/bin/bash

TRIALS=1

OUTPUT="$(date "+%Y-%m-%d")"
SCRIPT_DIR=$(cd $(dirname $0); pwd)
TEST_DOCKER_IMG=thehajime/ukontainer-bench-alpine:0.1

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/mem-*.dat
  exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

  mem::run

  bash "$SCRIPT_DIR/mem-plot.sh" "$OUTPUT"
}

mem::run() {
  mem::lkl "$@"
  mem::gvisor "$@"
  mem::kata "$@"
  mem::runc "$@"
}

mem::lkl() {
(

  echo "$(tput bold)== lkl ==$(tput sgr0)"
  runtime=runu-dev

  docker run -i -d --runtime=$runtime \
	 --name=hello \
	 -e LKL_BOOT_CMDLINE="mem=4m" --rm \
	 $TEST_DOCKER_IMG \
	 /root/hello.runu
  sleep 1
  ps auxw |grep -E "[h]ello|[r]unu" | tee "$OUTPUT/mem-runu-hello.log"
  docker kill hello

  echo "$(tput bold)== lkl-nginx ==$(tput sgr0)"
  # XXX: runu can't run alpine+nginx with libc.so replacement
  docker run -i --runtime=$runtime --rm \
	 -e LKL_ROOTFS=imgs/data.iso \
	 -e LKL_BOOT_CMDLINE="mem=4m" \
	 --name=nginx -d \
	 thehajime/runu-nginx:0.3 nginx

  sleep 1
  ps auxw |grep -E "[n]ginx|[r]unu" | tee "$OUTPUT/mem-runu-nginx.log"
  docker kill nginx

  echo "$(tput bold)== lkl-python ==$(tput sgr0)"
  # XXX: runu can't run alpine+python with libc.so replacement
  docker run -i --runtime=$runtime --rm \
	 -e LKL_BOOT_CMDLINE="mem=8m" \
	 --name=python -d \
	 thehajime/runu-python:0.3 \
	 python -c "import time; time.sleep(5)"

  sleep 1
  ps auxw |grep -E "[p]ython.*sleep|[r]unu" | tee "$OUTPUT/mem-runu-python.log"
  docker kill python
)
}

mem::gvisor() {
(
  echo "$(tput bold)== gvisor ==$(tput sgr0)"
  runtime=runsc-ptrace-user

  docker run -i -d --runtime=$runtime --rm \
	 --name=hello \
	 $TEST_DOCKER_IMG \
	 /root/hello
  sleep 1
  ps auxw |grep "[r]unsc" | tee "$OUTPUT/mem-gvisor-hello.log"
  docker kill hello

  echo "$(tput bold)== gvisor-nginx ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=nginx \
	 $TEST_DOCKER_IMG  \
	 /usr/sbin/nginx -c /root/nginx.conf
  sleep 1
  ps auxw |grep -E "[r]unsc" | tee "$OUTPUT/mem-gvisor-nginx.log"
  docker kill nginx

  echo "$(tput bold)== gvisor-python ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=python \
	 $TEST_DOCKER_IMG  \
	 /usr/bin/python3 -c "import time; time.sleep(5)"
  sleep 1
  ps auxw |grep -E "[r]unsc" | tee "$OUTPUT/mem-gvisor-python.log"
  docker kill python
)
}

mem::kata() {
(
  echo "$(tput bold)== kata ==$(tput sgr0)"
  runtime=kata-runtime

  docker run -i -d --runtime=$runtime --rm \
	 --name=hello \
	 $TEST_DOCKER_IMG \
	 /root/hello
  sleep 1
  ps auxw |grep -E "[k]ata|[q]emu|[h]ello" | tee "$OUTPUT/mem-kata-hello.log"
  docker kill hello

  echo "$(tput bold)== kata-nginx ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=nginx \
	 $TEST_DOCKER_IMG \
	 /usr/sbin/nginx -c /root/nginx.conf
  sleep 1
  ps auxw |grep -E "[k]ata|[q]emu|[n]ginx" | tee "$OUTPUT/mem-kata-nginx.log"
  docker kill nginx

  echo "$(tput bold)== kata-python ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=python \
	 $TEST_DOCKER_IMG  \
	 /usr/bin/python3 -c "import time; time.sleep(5)"
  sleep 1
  ps auxw |grep -E "[k]ata|[q]emu|([p]ython.*sleep)" | tee "$OUTPUT/mem-kata-python.log"
  docker kill python
)
}

mem::runc() {
(
  echo "$(tput bold)== runc ==$(tput sgr0)"
  runtime=runc
  docker run -d -i --runtime=$runtime --rm \
	 --name=hello \
	 $TEST_DOCKER_IMG \
	 /root/hello
  sleep 1
  CID=`docker ps |grep hello |awk '{print $1}'`
  ps auxw |grep -E "[h]ello|$CID" | tee "$OUTPUT/mem-runc-hello.log"
  docker kill hello

  echo "$(tput bold)== runc-nginx ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=nginx \
	 $TEST_DOCKER_IMG \
	 /usr/sbin/nginx -c /root/nginx.conf
  sleep 1
  CID=`docker ps |grep nginx |awk '{print $1}'`
  ps auxw |grep -E "[n]ginx|$CID" | tee "$OUTPUT/mem-runc-nginx.log"
  docker kill nginx

  echo "$(tput bold)== runc-python ==$(tput sgr0)"
  docker run -i -d --runtime=$runtime --rm \
	 --name=python \
	 $TEST_DOCKER_IMG  \
	 /usr/bin/python3 -c "import time; time.sleep(5)"
  sleep 1
  CID=`docker ps |grep python |awk '{print $1}'`
  ps auxw |grep -E "([p]ython.*sleep)|$CID" | tee "$OUTPUT/mem-runc-python.log"
  docker kill python
)
}



main
