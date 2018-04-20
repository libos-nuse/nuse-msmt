#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"

NOAH_DIR="$HOME/gitworks/noah/"
FRANKENLIBC_DIR="$HOME/gitworks/frankenlibc/"

OUTPUT="$(date "+%Y-%m-%d")"
mkdir -p $OUTPUT

cd $NOAH_DIR; gtags -i
NOAH=$(global DEFINE_SYSCALL --result ctags-x | wc -l)
cd $FRANKENLIBC_DIR; gtags -i
REXEC=$(global -r syscall_\* -S platform/darwin --result ctags-x | wc -l)

cd $SCRIPT_DIR
echo "$REXEC &  $NOAH \\\\" > $OUTPUT/num-syscall-tbl.dat


