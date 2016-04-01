#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
# This module contains helper methods for performing tasks on the world


import sys
import collections
from argparse import ArgumentParser

parser = ArgumentParser();
sparser = parser.add_subparsers()

p = sparser.add_parser("accumulate-times", 
        help="Helps accumulate times.csv files using a prefix")
p.add_argument("prefix", help="The prefix to accumulate under")
p.add_argument("results", nargs="+")
def accumulate_times(prefix, results=[], **kwargs):
    import csv;

p.set_defaults(function=accumulate_times)


def main(args):
    result = parser.parse_args(args)
    result.function(**result)

if __name__ == "__main__": 
    main(sys.argv[1:])
