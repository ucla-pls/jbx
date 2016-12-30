#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re

fn = re.compile("<(?P<pkgcls>[^\s:]+): (?P<rtype>\S+) (?P<name>[^(]+)\\((?P<params>[^)]*)\\)>");

remove_inclosing_class = re.compile(r"[^/]+\$");

transformer = {
    "boolean": "Z",
    "char": "C",
    "byte": "B",
    "short": "S",
    "int": "I",
    "float": "F",
    "long": "J",
    "double": "D",
    "void": "V",
    "": "V"
}

def parseline(line):
    if line == "PETABLOX_SCOPE_EXCLUDE_STR=\n": return None
    d = fn.search(line).groupdict()
    if d["params"]:
        d["params"] = "".join(map(transform, d["params"].split(",")))
    d["rtype"] = transform(d["rtype"])
    d["pkgcls"] = to_class(d["pkgcls"]);
    d["name"] = '"' + d["name"] + '"' if d["name"].startswith("<") else d["name"]
    return "{pkgcls}.{name}:({params}){rtype}\n".format(**d);

from collections import deque

def transform(param):
    array = deque(param.split("[]"));
    item = array.popleft();

    if item in transformer:
        type_ = transformer[item]
    else:
        type_ = "L" + to_class(item) + ";";

    for a in array:
        type_ = "[" + type_

    return type_

def to_class(string):
    return string.replace(".", "/")

try:
    with open(sys.argv[1]) as f:
        lines = filter(lambda x: x, map(parseline, f))
        sys.stdout.writelines(sorted(lines))
except IOError as e:
    sys.stderr.write("No reachable method files found.")
