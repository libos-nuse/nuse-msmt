#./tools/lkl/bin/lkl-hijack.sh sleep 10000

if [ -z $NO_ZEBRA ] ; then
    ZEBRA_CONF=zebra.conf
else
    ZEBRA_CONF=nozebra.conf
fi

sudo LKL_HIJACK_DEBUG=1 LD_LIBRARY_PATH=`pwd`/../quagga/dest/usr/local/lib/ \
     ./tools/lkl/bin/lkl-hijack.sh ../quagga/dest/usr/local/sbin/zebra \
     -f $ZEBRA_CONF -i /tmp/zebra.pid
