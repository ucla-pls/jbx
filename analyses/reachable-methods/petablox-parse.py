#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re

fn = re.compile("<(?P<pkgcls>[^\s:]+): (?P<rtype>\S+) (?P<name>[^(]+)\\((?P<params>[^)]*)\\)>");

def striptype(string):
    return string.rsplit(".",1)[-1]

def parseline(line):
    if line == "PETABLOX_SCOPE_EXCLUDE_STR=\n": return None
    d = fn.search(line).groupdict()
    d["params"] = ", ".join(map(striptype, d["params"].split(",")));
    d["rtype"] = striptype(d["rtype"]);
    return "<{pkgcls}: {rtype} {name}({params})>\n".format(**d);

try: 
    with open(sys.argv[1]) as f: 
        lines = filter(lambda x: x, map(parseline, f))
        sys.stdout.writelines(lines)
except:
    pass

