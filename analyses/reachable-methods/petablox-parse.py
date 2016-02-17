#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re

fn = re.compile("<(?P<pkgcls>[^\s:]+): (?P<rtype>\S+) (?P<name>[^(]+)\\((?P<params>[^)]*)\\)>");

def striptype(string):
    return string.rsplit(".",1)[-1]

with open(sys.argv[1]) as f: 
    for line in f:
        if line == "PETABLOX_SCOPE_EXCLUDE_STR=\n": continue
        d = fn.search(line).groupdict();
        d["params"] = ", ".join(map(striptype, d["params"].split(",")));
        d["rtype"] = striptype(d["rtype"]);
        print "<{pkgcls}: {rtype} {name}({params})>".format(**d);

