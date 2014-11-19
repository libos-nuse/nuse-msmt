#!/usr/bin/env python


import re
import os
import sys

def gather_ping_avg (fname) :

    f = open (fname, 'r')

    max = 0.0
    min = 0.0

    sum = 0.0
    cnt = 0
    for l in f :

        if not re.search (r'rx', l) :
            continue

        ff = 0
        for w in l.split (' ') :
            if w != '' :
                if ff == 1 :
                    bps = float (w)
                    break
                else :
                    ff = 1
            
        if bps < 10 :
            bps = bps * 1000

        if max == 0 :
            max = bps
        if min == 0 :
            min = bps

        if bps > max :
            max = bps
        if bps < min :
            min = bps

        sum += bps
        cnt += 1

    return [sum / cnt, max, min]



sys.argv.pop (0)

for fname in sys.argv :
    (bpsavg, bpsmax, bpsmin) = gather_ping_avg (fname)

    si = fname.split('.')[0]
    nl = si.split ('/')
    type = nl[len(nl) - 1]

   
    print "%s\t%f\t%f\t%f" % (type, bpsavg, bpsmax, bpsmin)


