
import sys
import os
import re

from subprocess import check_output

build = sys.argv[1]

def run(*cmd):
    return check_output(cmd, universal_newlines=True)

def readfromfile(*filepath):
    with open(os.path.join(*filepath), "r") as f:
        return [line.strip() for line in f.readlines()]

def getclasses(cp):
    classes = []
    for fp in cp.split(":"):
        if fp.endswith(".jar"):
            result = run("unzip", "-Z1", fp).split("\n")
        else:
            result = run("find", fp, "-name", "*.class").split("\n")
        classes += [
            f.replace("/",".").replace(".class", "")
            for f in result if f.endswith(".class")
        ]
    return classes

helper = {
    "byte": "B",
    "char": "C",
    "double": "D",
    "float": "F",
    "int": "I",
    "long": "J",
    "short": "S",
    "boolean": "Z",
    "void": "V"
}


def qualify(t):
    res = ""
    while t.endswith("[]"):
        t = t[:-2]
        res += "["
    if t in helper:
        res += helper[t]
    else:
        res += "L" + t.replace(".", "/") + ";"
    return res


cp = os.getenv("classpath")
try:
    classes = readfromfile(build, "info", "classes")
except FileNotFoundError:
    classes = getclasses(cp)

methods = []

RX = re.compile("(?P<ret>\S+)? (?P<name>\S+)\((?P<args>.*)\)")
RXS = re.compile("static {};")

from multiprocessing import Pool

def findmethods(cls):
    cls_ = cls.replace(".","/")
    clsn = ".".join(cls.split("$",1))
    output = run("javap","-p", "-classpath", cp, clsn)
    methods = []
    for m in RX.finditer(output):
        match = m.groupdict()
        name = match["name"]
        if name == cls:
            name = '"<init>"'
            qret = "V"
        else:
            qret = qualify(match["ret"])
        args = match["args"].split(", ") if match["args"] else []
        qargs = "".join([qualify(m) for m in args])
        methods.append(
            "{cls}.{name}:({args}){ret}".format(
                cls=cls_, name=name, args=qargs, ret=qret
            )
        )
    x = RXS.search(output)
    if x is not None:
        methods.append('{cls}."<clinit>":()V'.format(cls=cls_))
    return methods

with Pool() as p:
    for x in sorted(sum(p.map(findmethods, classes), [])):
        print(x)
