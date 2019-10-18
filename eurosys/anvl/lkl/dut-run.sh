#./tools/lkl/bin/lkl-hijack.sh sleep 10000

#set -x

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -z $NO_ZEBRA ] ; then
    ZEBRA_CONF=${SCRIPT_DIR}/zebra.conf
else
    ZEBRA_CONF=${SCRIPT_DIR}/nozebra.conf
fi

sudo LKL_HIJACK_DEBUG=1 LD_LIBRARY_PATH=`pwd`/../quagga/dest/usr/local/lib/ \
     LKL_HIJACK_CONFIG_FILE=`pwd`/${SCRIPT_DIR}/lkl-hijack.json \
     ./tools/lkl/bin/lkl-hijack.sh ../quagga/dest/usr/local/sbin/zebra \
     -f $ZEBRA_CONF -i /tmp/zebra.pid
