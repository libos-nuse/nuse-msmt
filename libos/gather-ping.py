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

        if not re.match (r'64 bytes from', l) :
            continue

        if re.search (r'seq=1', l) :
            continue

        rtt = float (l.split (' ')[6].split ('=')[1])

        if max == 0 :
            max = rtt
        if min == 0 :
            min = rtt

        if rtt > max :
            max = rtt
        if rtt < min :
            min = rtt

        sum += rtt
        cnt += 1

    return [sum / cnt, max, min]



sys.argv.pop (0)

for fname in sys.argv :
    if os.path.exists(fname) is False:
        continue

    (rttavg, rttmax, rttmin) = gather_ping_avg (fname)

    si = fname.split('.')[0]
    nl = si.split ('/')
    type = nl[len(nl) - 1]

   
    print "%s\t%f\t%f\t%f" % (type, rttavg, rttmax, rttmin)


