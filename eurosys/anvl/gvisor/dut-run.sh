#!/bin/bash

docker create --runtime=runsc --network=br-anvl0 --ip=10.1.0.50 \
       --rm --name gvisor -it ubuntu-3nic sh
docker network connect br-anvl1 --ip=10.2.0.50 gvisor
docker start gvisor
