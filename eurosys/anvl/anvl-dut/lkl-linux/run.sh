#sudo ip tuntap add tap-lkl-0 mode tap
#sudo ip tuntap add tap-lkl-1 mode tap
#sudo ip tuntap add tap-lkl-2 mode tap
#sudo brctl addif br-anvl1 tap-lkl-0
#sudo brctl addif br-anvl1 tap-lkl-2
#sudo brctl addif br-anvl2 tap-lkl-1
#sudo ifconfig tap-lkl-0 up
#sudo ifconfig tap-lkl-1 up
#sudo ifconfig tap-lkl-2 up

#./tools/lkl/bin/lkl-hijack.sh sleep 10000
sudo LKL_HIJACK_DEBUG=1 LD_LIBRARY_PATH=`pwd`/../quagga/dest/usr/local/lib/ ./tools/lkl/bin/lkl-hijack.sh ../quagga/dest/usr/local/sbin/zebra -f zebra.conf -i /tmp/zebra.pid
#LKL_HIJACK_DEBUG=1 ./tools/lkl/bin/lkl-hijack.sh sleep 1000000
