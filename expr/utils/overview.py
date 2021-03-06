#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
from __future__ import division

import sys
import csv
import os.path as path

from collections import Container, namedtuple

Stats = namedtuple("Stats", "name lower upper coverage precision excess missing")
Info = namedtuple("Info", "excess missing stats");

def readset(filename, default):
    try:
        with open(filename, "r") as f:
            return set(f.readlines())
    except:
        return default;

class Everything(Container):
    def __contains__ (self, other):
        return True

    def __len__ (self):
        return 0

class Result(object):

    """Docstring for Result. """

    def __init__(self, name, upper, lower):
        """A result of an analysis

        :name: TODO
        :upper: TODO
        :lower: TODO

        """
        self.name = name
        self.upper = upper
        self.lower = lower


    def info(self, underaprx, overaprx):
        excess = self.lower - overaprx if overaprx is not None else set();
        missing = underaprx - self.upper if self.upper is not None else set();

        stats = Stats(
            self.name,
            len(self.lower),
            len(self.upper) if self.upper is not None else "inf",
            (len(self.lower & overaprx) / len(overaprx)
               if len(overaprx) != 0 else 1.0)
               if overaprx is not None else "N/A"
            ,
            (len(underaprx) / len(self.upper)
               if len(self.upper) != 0 else "N/A")
               if self.upper is not None else 0.0,
            len(excess),
            len(missing)
        )

        return Info(excess, missing, stats);

    def limit(self, world):
        if not world is None:
            self.upper = self.upper and self.upper & world
            self.lower = self.lower & world
        return self

    @classmethod
    def from_folder(cls, folder):
        name = folder.split("-", 1)[1].split("+")[0]
        upper = readset(path.join(folder, "upper"), None)
        lower = readset(path.join(folder, "lower"), set())
        return cls(name, upper, lower);

    @staticmethod
    def overapproximation(results):
        list_of_elements = filter(
            lambda f: f is not None,
            map(lambda r: r.upper, results)
            );
        if not list_of_elements:
            return None
        else:
            return set.intersection(*list_of_elements);

    @staticmethod
    def underapproximation(results):
        list_of_elements = map(lambda r: r.lower, results)
        return set.union(*list_of_elements);

    def __str__(self):
        return "{} {} {}".format(self.name, len(self.upper) if self.upper is not None else "inf", len(self.lower))

def main():
    argv = list(sys.argv)[1:]

    if argv[0] == "-w":
        op, worldf = argv.pop(0), argv.pop(0)
        world = readset(worldf, None)
    else:
        world = None

    results = map(Result.from_folder, argv)

    print(" ".join(map(str, results)))

    if world is not None:
        results = [ r.limit(world) for r in results ]
        with open("world", "w") as f:
            f.writelines(sorted(world))

    over = Result.overapproximation(results)
    under = Result.underapproximation(results)

    if over is not None:
        with open("upper", "w") as f:
            f.writelines(sorted(over))

    with open("difference", "w") as f:
        if over is not None:
            f.writelines(sorted(under - over))
        else:
            f.writelines([])

    with open("lower", "w") as f:
        f.writelines(sorted(under))

    with open("overview.txt", "w") as f:
        writer = csv.DictWriter(f, fieldnames=Stats._fields)
        writer.writeheader()
        for result in results:
            excess, missing, stats = result.info(under, over);
            if excess:
                with open("excess-" + result.name + ".txt", "w") as e:
                    for excessive in excess:
                        e.write(str(excessive));
            if missing:
                with open("missing-" + result.name + ".txt", "w") as e:
                    for missed in missing:
                        e.write(str(missed));
            writer.writerow(stats._asdict())

if __name__ == "__main__":
    main()
