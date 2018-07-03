# nginx benchmark with wrk

## Prerequisite
- macOS (we tested with 10.12 and 10.13)
- modified version of unixbench (https://github.com/thehajime/byte-unixbench)
- frankenlibc (https://github.com/libos-nuse/frankenlibc)
- noah (https://github.com/linux-noah/noah or `brew install linux-noah/noah/noah`)
- docker for macOS (https://www.docker.com/docker-mac, tested with 18.03.0-ce)
- brew install gnuplot datamash e2fsprogs nginx
- image files

## Setup

## How to conduct an experiment

```
% ./nginx-bench.sh
```

## Result

You should have results in `${DATE}/out` directory.

The following is an example plot of the result obtained with the script.

![](https://raw.githubusercontent.com/libos-nuse/nuse-msmt/master/apsys/nginx/nginx-wrk-eample.png)

