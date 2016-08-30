#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
from __future__ import division

import sys
import csv
import os.path as path

from collections import Container, namedtuple

Stats = namedtuple("Stats", "name lower upper hitrate coverrate time exitcode")

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

    def stats(self, underaprx, overaprx):
        hits  = len(overaprx & self.lower) if overaprx is not None else len(self.lower)
        cover = len(underaprx & self.upper) if self.upper is not None else len(underaprx)
        return Stats(
            self.name,
            len(self.lower),
            len(self.upper) if self.upper is not None else "inf",
            # Did the analysis hit everything in the
            # underapproximation
            hits  / len(self.lower) if self.lower else "N/A",
            cover / len(underaprx) if underaprx else "N/A",
            "Pending", # self._time.real,
            "Pending", # reduce(lambda a, b: a + 1 if b.exitcode != 0 else a, self._result.times, 0)
        )

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
    results = map(Result.from_folder, sys.argv[1:]);

    over = Result.overapproximation(results)
    under = Result.underapproximation(results)

    writer = csv.DictWriter(sys.stdout, fieldnames=Stats._fields)

    writer.writeheader()
    for result in results:
        writer.writerow(result.stats(under, over)._asdict())

if __name__ == "__main__":
    main()
