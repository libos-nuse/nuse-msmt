#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"

TRIALS=30
#TRIALS=1
OUTPUT="$SCRIPT_DIR/$(date "+%Y-%m-%d")"

RUNU_BUNDLE_DIR=/home/upa/bundle-runu
RUNU_BUNDLE_DIR=/home/tazaki/tmp/bundle-runu
RUNC_BUNDLE_DIR=/tmp/bundle-runc
RUNNC_BUNDLE_DIR=/tmp/bundle-runnc

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/py-coldstart-*.dat
  exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

  prepare_image
  # python-coldstart tests
  for num in $(seq 1 "$TRIALS"); do
    py-coldstart::run $num
  done

  bash "$SCRIPT_DIR/py-plot.sh" "$OUTPUT"
}

prepare_image() {
# for runc/runv/runsc
sudo rm -rf $RUNC_BUNDLE_DIR/
mkdir -p $RUNC_BUNDLE_DIR/rootfs
cd $RUNC_BUNDLE_DIR
docker export $(docker create --name=foo python-hub-greenlet) | tar -C rootfs -xf -
cp $SCRIPT_DIR/config-runv.json ./config.json
chmod 666 config.json
cp $SCRIPT_DIR/image/main.py ./rootfs
docker rm foo

# for runnc
sudo rm -rf $RUNNC_BUNDLE_DIR/
mkdir -p $RUNNC_BUNDLE_DIR/rootfs
cd $RUNNC_BUNDLE_DIR
docker export $(docker create --name=foo retrage/nabla-python:0.1 foo) | tar -C rootfs -xf -
cp $SCRIPT_DIR/config-runnc.json ./config.json
chmod 666 config.json
cp $SCRIPT_DIR/image/main.py ./rootfs
docker rm foo

# for runu
sudo rm -rf $RUNU_BUNDLE_DIR/
mkdir -p $RUNU_BUNDLE_DIR/rootfs
cd $RUNU_BUNDLE_DIR
docker export $(docker create --name=foo thehajime/runu-python:0.2 foo) | tar -C rootfs -xf -
docker rm foo

# loopback mount python.img for lkl rootfs
mkdir -p mnt
sudo mount rootfs/imgs/python.img mnt

cp $SCRIPT_DIR/config-runu.json ./config.json
sudo cp $SCRIPT_DIR/image/main.py ./mnt/

sudo umount mnt
}

py-coldstart::run() {
  py-coldstart::native "$@"
  py-coldstart::runu   "$@"
  py-coldstart::docker "$@" "runc"
  py-coldstart::docker "$@" "kata-runtime"
  py-coldstart::docker "$@" "kata-fc"
  py-coldstart::docker "$@" "kata-qemu"
  py-coldstart::docker "$@" "runsc-ptrace-user"
  py-coldstart::docker "$@" "runsc-kvm-user"
  py-coldstart::runnc  "$@"
  py-coldstart::graphene  "$@"
}

py-coldstart::native() {
(
  local num=$1
  local runtime=native

  echo "$(tput bold)== native ($num)  ==$(tput sgr0)"
  /usr/bin/time python3 $SCRIPT_DIR/image/main.py \
	  |& tee ${OUTPUT}/py-coldstart-native-$num.dat
)
}

py-coldstart::runu() {
(
  local num=$1
  local runtime=runu-dev

  echo "$(tput bold)== docker (runu-$num)  ==$(tput sgr0)"
  /usr/bin/time docker run -i --runtime=$runtime \
	  -e LKL_ROOTFS=imgs/python.img \
	  -e HOME=/ -e PYTHONHOME=/python \
	  -e PYTHONHASHSEED=1 --name=$runtime-test \
	  thehajime/runu-python:0.2 \
	  python /main.py -m main \
	  |& tee ${OUTPUT}/py-coldstart-runu-docker-$num.dat

  docker rm $runtime-test

  echo "$(tput bold)== oci (runu-$num)  ==$(tput sgr0)"
  cname=foo
  sudo /usr/bin/time /home/tazaki/work/runu/runu run \
	  --bundle $RUNU_BUNDLE_DIR $cname \
	  |& tee ${OUTPUT}/py-coldstart-runu-$num.dat

  sudo runu kill $cname
  sudo runu delete $cname
)
}

py-coldstart::docker() {
(
  local num=$1
  local runtime=$2

  case "$runtime" in
    "runc") rbin="docker-runc" ;;
    "kata-runtime") rbin="kata-runtime" ;;
    "runsc-ptrace-user") rbin="runsc" ;;
    "runsc-kvm-user") rbin="runsc --platform=kvm";;
  esac

  echo "$(tput bold)== docker ($runtime-$num)  ==$(tput sgr0)"
  /usr/bin/time sudo docker run -i --runtime=$runtime \
	  -v $SCRIPT_DIR/image:/root --name=$runtime-test \
	  python-hub-greenlet python /root/main.py -m main \
	  |& tee ${OUTPUT}/py-coldstart-$runtime-docker-$num.dat

  docker rm $runtime-test

  echo "$(tput bold)== oci ($runtime-$num)  ==$(tput sgr0)"
  cname=container-`date +%s`
  /usr/bin/time sudo $rbin --log=/dev/null \
	  run --bundle $RUNC_BUNDLE_DIR $cname \
	  |& tee ${OUTPUT}/py-coldstart-$runtime-$num.dat

  sudo rm -rf /var/run/runsc/$cname
  sudo rm -rf /run/user/0/runsc/$cname
)
}

py-coldstart::runnc() {
  local num=$1
  local runtime=runnc
  local rbin="/home/tazaki/go/src/github.com/nabla-containers/runnc/build/runnc"

  echo "$(tput bold)== docker ($runtime-$num)  ==$(tput sgr0)"
  /usr/bin/time docker run -i --runtime=$runtime \
    -e HOME=/ -e PYTHONHOME=/python --name=$runtime-test \
    retrage/nabla-python:0.1 \
    /python.nabla /main.py -m main \
    |& tee ${OUTPUT}/py-coldstart-$runtime-docker-$num.dat

  docker rm $runtime-test

#  echo "$(tput bold)== oci ($runtime-$num)  ==$(tput sgr0)"
#  cname=container-`date +%s`
#  sudo /usr/bin/time $rbin --log=/dev/null \
#    run --bundle $RUNNC_BUNDLE_DIR $cname \
#    |& tee ${OUTPUT}/py-coldstart-$runtime-$num.dat
#
#  sudo $rbin kill $cname
#  sudo $rbin delete $cname
}

py-coldstart::graphene() {
  local num=$1
  local runtime=graphene

  echo "$(tput bold)== docker ($runtime-$num)  ==$(tput sgr0)"
  /usr/bin/time docker run -i \
	  -e GSC_PAL=Linux --name=$runtime-test \
	  gsc-python-hub-greenlet-unsigned /root/main.py \
    |& tee ${OUTPUT}/py-coldstart-$runtime-docker-$num.dat

  docker rm $runtime-test

}

main
