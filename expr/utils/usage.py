#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division

import sys
import csv
from collections import namedtuple
from subprocess import check_output

Usage = namedtuple("Usage", [
    "name", 
    "disk"
    ])

def read_usage(result):
    return Usage(
        name = result.split("-", 1)[1], 
        disk = check_output(["du", "-sh", result]).split()[0]
    )

def output_namedtuples(tuples, output, fieldnames=None):
    fieldnames = fieldnames or tuples[0]._fields;
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()
    for tuple in tuples:
        writer.writerow(tuple._asdict())

def main():
    results = sys.argv[1:]
    usages = map(read_usage, results);
    return output_namedtuples(usages, sys.stdout, Usage._fields);

if __name__ == "__main__":
    main();
