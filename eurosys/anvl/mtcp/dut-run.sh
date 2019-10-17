sudo killall -q -9 epserver

sudo ./apps/example/epserver -p ./apps/example/rootd -f ./apps/example/epserver.conf -c 0 &

sleep 3
sudo brctl addif br-anvl0 tap-mtcp-0
sudo brctl addif br-anvl1 tap-mtcp-1

wait
