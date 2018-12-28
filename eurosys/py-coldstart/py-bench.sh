#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"

TRIALS=5
OUTPUT="$SCRIPT_DIR/$(date "+%Y-%m-%d")"

RUNU_BUNDLE_DIR=/home/upa/bundle-runu

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/py-coldstart-*.dat

  prepare_image
  # python-coldstart tests
  for num in $(seq 1 "$TRIALS"); do
    py-coldstart::run $num
  done

  bash "$SCRIPT_DIR/py-plot.sh" "$OUTPUT"
}

prepare_image() {
# for runc/runv/runsc
mkdir -p /tmp/bundle-runc/rootfs
cd /tmp/bundle-runc
docker export $(docker create python-hub-greenlet) | tar -C rootfs -xf -
cp $SCRIPT_DIR/config-runv.json ./config.json
chmod 666 config.json
cp $SCRIPT_DIR/main.py ./rootfs


# for runu
mkdir -p $RUNU_BUNDLE_DIR/rootfs
cd $RUNU_BUNDLE_DIR
docker export 07e3707a0c45 | tar -C rootfs -xf -

# loopback mount python.img for lkl rootfs
mkdir -p mnt
mount rootfs/imgs/python.img mnt

cp $SCRIPT_DIR/config-runu.json ./config.json
cp $SCRIPT_DIR/main.py ./mnt/

umount mnt
}

py-coldstart::run() {
  py-coldstart::native "$@"
  py-coldstart::runu   "$@"
  py-coldstart::docker "$@" "runc"
  py-coldstart::docker "$@" "kata-runtime"
  py-coldstart::docker "$@" "runsc-ptrace-user"
  py-coldstart::docker "$@" "runsc-kvm-user"
}

py-coldstart::native() {
(
  local num=$1
  local runtime=native

  echo "$(tput bold)== native ($num)  ==$(tput sgr0)"
  /usr/bin/time python3 $SCRIPT_DIR/main.py \
	  |& tee ${OUTPUT}/py-coldstart-native-$num.dat
)
}

py-coldstart::runu() {
(
  local num=$1
  local runtime=runu-dev

  echo "$(tput bold)== docker (runu-$num)  ==$(tput sgr0)"
#  /usr/bin/time docker run -i --runtime=$runtime \
#	  thehajime/runu-base:latest python \
#	  imgs/python.img -- /main.py -m main \
#	  |& tee ${OUTPUT}/py-coldstart-runu-$num.dat

  rm -rf /var/run/runu/foo

  /usr/bin/time runu run \
	  --bundle $RUNU_BUNDLE_DIR foo \
	  |& tee ${OUTPUT}/py-coldstart-runu-$num.dat

  rm -rf /var/run/runu/foo
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
#  /usr/bin/time docker run -i --runtime=$runtime \
#	  python-hub-greenlet python /root/main.py -m main \
#	  |& tee ${OUTPUT}/py-coldstart-$runtime-$num.dat

  cname=fooooo
  /usr/bin/time sudo $rbin --log=/dev/null \
	  run --bundle /tmp/bundle-runc $cname \
	  |& tee ${OUTPUT}/py-coldstart-$runtime-$num.dat

  rm -rf /var/run/runsc/$cname
)
}


main
