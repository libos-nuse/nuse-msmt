# microbenchmark with UnixBench

## Prerequisite
- macOS (we tested with 10.12 and 10.13)
- modified version of unixbench (https://github.com/thehajime/byte-unixbench)
- frankenlibc (https://github.com/libos-nuse/frankenlibc)
- noah (https://github.com/linux-noah/noah or `brew install linux-noah/noah/noah`)
- docker for macOS (https://www.docker.com/docker-mac, tested with 18.03.0-ce)
- gnuplot
- datamash
- e2fsprogs

## Setup
- build unixbench for each environment
 - change environment variable `PROGDIR` to each environment


## How to conduct an experiment

```
% ./ubench-run.sh
```

## Result

You should have results in `output/${DATE}/plots` directory.

The following is an example plot of the result obtained with the script.

![](https://raw.githubusercontent.com/libos-nuse/nuse-msmt/master/apsys/unixbench/unixbench-example.png)