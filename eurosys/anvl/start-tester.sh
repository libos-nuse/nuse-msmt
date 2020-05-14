#!/bin/sh

# host network version
sudo ifconfig eth0 hw ether 8c:85:90:55:a5:ee 
docker run -it --detach-keys="ctrl-q,ctrl-q" --rm -v /home/tazaki:/home/tazaki \
       	--net=host  --privileged=True -e USER=tazaki --user=tazaki --hostname=ixanvl --name=ixanvl ixanvl:centos6.6 zsh

# BAK: mac-vlan version
#docker create -it --rm -v /home/tazaki:/home/tazaki  --mac-address="8c:85:90:55:a5:ee" \
#       	--net=anvl0 --privileged=True --user=tazaki --hostname=ixanvl --name=ixanvl \
#       	ixanvl:centos6.6 zsh
#docker network connect anvl1 ixanvl
#docker start --detach-keys="ctrl-q,ctrl-q" -i ixanvl
