# collect the number of system calls

## Prerequisite
- frankenlibc (https://github.com/libos-nuse/frankenlibc)
- noah (https://github.com/linux-noah/noah or `brew install linux-noah/noah/noah`)
- GNU global

## Setup

Nothing is needed except installation of software.

## How to conduct an experiment

```
% ./mem-numsyscall.sh
```

## Result

You should have results in `${DATE}/` directory.

The following is an example output of the result obtained with the script.

| uni-LKL | Noah |
|---:|---:|
|22 |  163 |

