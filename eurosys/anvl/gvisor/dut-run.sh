#!/bin/bash

docker create --runtime=runsc --network=br-anvl0 --ip=10.1.0.50 \
	-v /home:/home --privileged=True \
       --rm --name gvisor -it ubuntu-3nic \
       zebra -f /home/tazaki/work/nuse-msmt/eurosys/anvl/lkl/zebra.conf  -i /tmp/zebra.pid
docker network connect br-anvl1 --ip=10.2.0.50 gvisor
docker start gvisor
