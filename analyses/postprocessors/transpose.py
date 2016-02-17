#!/usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import sys
import re

f = csv.reader(sys.stdin)
table = {}
javas = set()
for l in f:
  (name, java, type) = re.match('(.+)J([0-9]+)-(.+)', l[0]).groups();  
  table.setdefault(name, {})[java] = '{} ({}s)'.format(l[2], l[1]);
  javas.add(java)

javaorder = sorted(javas)

writer = csv.writer(sys.stdout)

writer.writerow(['Benchmark'] + ['Java ' + java for java in javaorder]);
for name, col in sorted(table.items()):
  writer.writerow([name] + [col.get(java, 'N/A') for java in javaorder]);

