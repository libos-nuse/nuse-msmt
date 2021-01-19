#!/bin/bash

docker create --network=br-anvl0 --ip=10.1.0.100 \
       -v /home/tazaki:/home/tazaki --privileged=True --user tazaki \
       --rm --name graphene -it graphene-u1804 sh
docker network connect br-anvl1 --ip=10.2.0.100 graphene
docker start graphene


# start zebra
docker exec -d -it -w /home/tazaki/work/graphene/Examples/bench graphene \
	./pal_loader ./zebra -f zebra.conf  -i /zebra.pid

# config sysctl
docker exec -i graphene \
  sudo sysctl -w net.ipv4.conf.all.forwarding=1 
docker exec -i  graphene \
  sudo sysctl -w net.ipv4.conf.all.accept_source_route=1
docker exec -i graphene \
  sudo sysctl -w net.ipv4.conf.eth0.arp_accept=1
docker exec -i graphene \
  sudo sysctl -w net.ipv4.conf.eth1.arp_accept=1
docker exec -i graphene \
  sudo sysctl -w net.ipv4.neigh.eth0.locktime=-1

