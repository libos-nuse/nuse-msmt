set -x

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

sudo killall -9 zebra
sudo sysctl -w net.ipv4.conf.all.forwarding=1
sudo sysctl -w net.ipv4.conf.all.accept_source_route=1
sudo sysctl -w net.ipv4.conf.z1-host.arp_accept=1
sudo sysctl -w net.ipv4.conf.z2-host.arp_accept=1
sudo sysctl -w net.ipv4.neigh.z1-host.locktime=-1
sudo systemctl stop firewalld.service

if [ -z $NO_ZEBRA ] ; then
    ZEBRA_CONF=${SCRIPT_DIR}/zebra.conf
else
    ZEBRA_CONF=${SCRIPT_DIR}/nozebra.conf
    sudo ip ad add 10.1.0.70/24 dev z1-host
    sudo ip ad add 10.2.0.70/24 dev z2-host
fi

sudo LD_LIBRARY_PATH=`pwd`/../anvl-dut/quagga/dest/usr/local/lib/ \
     ../anvl-dut/quagga/dest/usr/local/sbin/zebra -f $ZEBRA_CONF -i /tmp/zebra.pid 

if [ -z $NO_ZEBRA ] ; then
    echo ""
else
    sudo ip ad del 10.1.0.70/24 dev z1-host
    sudo ip ad del 10.2.0.70/24 dev z2-host
fi

sudo sysctl -w net.ipv4.conf.all.accept_source_route=0
sudo sysctl -w net.ipv4.conf.all.forwarding=0
sudo sysctl -w net.ipv4.conf.z1-host.arp_accept=0
sudo sysctl -w net.ipv4.conf.z2-host.arp_accept=0
sudo sysctl -w net.ipv4.neigh.z1-host.locktime=100
sudo systemctl start firewalld.service
