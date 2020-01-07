
Create graph
- gnuplot plot.plt



To create the gnuplot data files, 1 clone source data

- mkdir git
- cd git
- git clone https://lore.kernel.org/netdev/0 0.git
- git clone https://lore.kernel.org/netdev/1 1.git
- git clone https://github.com/torvalds/linux linux-github
- cd ..


2 Create gnuplot dat file from the netdev ml

- ./extract-git-networking.sh
  - extract "[GIT](:) Networking" mails from git/0.git and git/1.git and save the results to git/commits-{0,1}.git.txt
- ./parse-netdev-ml.py > netdev-pull-items.dat
  - count changes of davem's pull requests


3 Create gnuplot dat file from the linux source

- cd git/linux-github
- git log --date=iso --no-merges --pretty="%H %cd %s" --numstat --since="2008-01-01 00:00:00" net/ > ../../linux-numstat-under-net-since-2008.txt
  - save the git log output to a file
- cd ../..
- ./parse-git.py -u year linux-numstat-under-net-since-2008.txt > linux-numstat-under-net-since-2008.dat


