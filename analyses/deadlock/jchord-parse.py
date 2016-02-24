#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET
from collections import namedtuple
import sys
import os

d = sys.argv[1]
tree = ET.parse(os.path.join(d, "deadlocklist.xml"))

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

for deadlock in deadlocks:
    print(deadlock)
