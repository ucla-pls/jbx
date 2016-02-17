#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-

import sys
import xml.etree.ElementTree as ET
import re

tree = ET.parse(sys.argv[1]);
root = tree.getroot()

expr = re.compile("(?P<name>\S+) (?P<param>\\(.*?\\)): (?P<rtype>.*)"); #: (?P<name>\S+) (?P<param>\\(.*?\\))");

for pkg in root.iter("package"):
    pkgname = pkg.attrib["name"]
    for cls in pkg.iter("class"):
        clsname = cls.attrib["name"]
        for method in cls.iter("method"):
            if method.attrib["name"] == "<static initializer>": continue
            mdict = expr.search(method.attrib["name"]).groupdict();
            if mdict["name"] == clsname: mdict["name"] = "<init>"
            mdict["param"] = ", ".join(map(lambda p: "".join(p.split()), mdict["param"].split(",")))
            mdict["rtype"] = "".join(mdict["rtype"].split())
            coverage = method.find("./coverage[@type='method, %']") 
            if coverage.attrib["value"] == "100% (1/1)":
                #<org.apache.commons.cli.Option: void <init>(String, String, boolean, String)>
                print "<{0}.{1}: {2[rtype]} {2[name]}{2[param]}>".format(pkgname, clsname, mdict);

