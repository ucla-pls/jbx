#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import csv
import sys
import os

def readFile(folder):
    filename = os.path.join(folder, "table.csv")
    with open(filename) as f:
        reader = csv.DictReader(f);
        return (reader.fieldnames, list(reader))
   

data = map(readFile, sys.argv[1:]);

fieldnames = []
records = []
for d in data:
    for name in d[0]:
        if not name in fieldnames:
            fieldnames.append(name)
    records.extend(d[1]) 

writer = csv.DictWriter(sys.stdout, fieldnames)
writer.writeheader()
writer.writerows(records)
