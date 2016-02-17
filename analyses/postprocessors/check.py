#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
The primary functionality of this script is to take a list of filenames, and then
to callculate a the superset, the subset and the revialing 3 numbers. 

subset_not_in / actual / not_in_superset

"""
import sys
import re

_fmatch = re.compile("(?P<name>[^=]+)=(?P<filename>.*)").match
def fmatch(arg):
    return _fmatch(arg).groupdict()

analyses = map(fmatch, sys.argv[1:])

for analysis in analyses:
    with open(analysis["filename"]) as f:
        analysis["result"] = set(f.readlines())

results = map(lambda a: a["result"], analyses)
superset = set.union(*results)
subset   = set.intersection(*results)

#print "".join(sorted(subset))
#print "total", len(subset), "-" ,len(superset)


for analysis in analyses:
    offmin = analysis["result"] - subset
    offmax = superset - analysis["result"]
    if analysis["name"] == "emma": 
        for line in sorted(offmin): print line[:-1];
    print analysis["name"], len(offmin), len(analysis["result"]), len(offmax)

