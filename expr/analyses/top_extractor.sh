#!/bin/bash

<$1 sed -n -E '
    /^top/ { 
        s/top - ([0-9:]*).*/\1/; h; d;
    }; 
    
    /^[0-9]/ { 
        G; s/(.*)\n(.*)/\2 \1/; p;
    }
' | python -c ' 
import sys
import datetime

pids = []
times = []
d = {}

for l in sys.stdin:
    a = l.split()
    t, p, mem = datetime.datetime.strptime(a[0], "%H:%M:%S"), a[1] + ":" + a[-1], float(a[10])
    d.setdefault(t, {})[p] = mem 
    pids.append(p)
    times.append(t)

# Be afraid of changes in date
t0 = times[0]

pids = sorted(set(pids));

impact = sorted([(sum(d[t].get(p, 0) for t in times),p) for p in pids], reverse=True)
ps = map(lambda x: x[1], impact[0:5])

others = [ p for p in pids if p not in ps ]

table = [["time"] + ps + ["rest"] ] + [
        [str((t - t0).total_seconds())] + 
        [str(d[t].get(p, 0)) for p in ps] + 
        [str(sum(d[t].get(p, 0) for p in others))] 
    for t in times]

for line in map(" ".join, table):
    print line
'
