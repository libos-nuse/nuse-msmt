# memory footprint measurement

## Prerequisite
- macOS (we tested with 10.12 and 10.13)
- netperf2 (https://github.com/HewlettPackard/netperf)
- frankenlibc (https://github.com/libos-nuse/frankenlibc)
- noah (https://github.com/linux-noah/noah or `brew install linux-noah/noah/noah`)
- docker for macOS (https://www.docker.com/docker-mac, tested with 18.03.0-ce)

## Setup

We will use a hello world-like program, which can be compiled like this:

```
% rumprun-cc hello.c -o hello-lkl
% clang -o hello-macos hello.c
% noah
I have no name!@mercury: gcc hello.c -o hello-noah
```

## How to conduct an experiment

```
% ./mem-bench.sh
```

## Result

You should have results in `${DATE}/` directory.

The following is an example output of the result obtained with the script.

|  | uni-LKL | Noah | Docker | macOS |
|:---|---:|---:|---:|---:|
|memory |6200K |  7448K  |  7108K | 292K |
|  |  |  (1008K)  |  (3.0G) |  |
