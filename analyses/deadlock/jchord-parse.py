#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET
from collections import namedtuple
import sys
import os

d = sys.argv[1]
try: tree = ET.parse(os.path.join(d, "deadlocklist.xml"))
except: sys.exit()

Deadlock = namedtuple("Deadlock", "threads locations")
Location = namedtuple("Location", "context lock method object");

deadlocks = set()
for t in tree.findall("deadlock"):
    locations = []
    for i in range(1,4):
        C = t.attrib["C{}id".format(i)];
        L = t.attrib["L{}id".format(i)];
        M = t.attrib["M{}id".format(i)];
        O = t.attrib["O{}id".format(i)];
        locations.append(Location(C, L, M, O))
    ts = tuple(t.attrib["T{}id".format(i)] for i in [1,2])
    deadlocks.add(Deadlock(ts, tuple(locations)))

locations = set()
for deadlock in deadlocks:
    locations.add(tuple(sorted(map(lambda l: l.lock, deadlock))))

for location in locations:
    print(location);
