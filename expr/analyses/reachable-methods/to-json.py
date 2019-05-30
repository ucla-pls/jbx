#!/usr/bin/env python3

import json
import sys
import os
import collections


def readset(fn, default):
    try:
        with open(fn, "r") as fp:
           return set(map(str.strip,fp.readlines()))
    except Exception:
        return default

def extend_dict(dct, methods, key):
    for m in methods:
        cls, mth = m.split('.');
        dct[cls][mth] += key
    return dct

if __name__ == "__main__": 
    cmd, world_path, *args = sys.argv
    analyses = { k:v for k,v in (arg.split(':') for arg in args) }

    world = readset(os.path.join(world_path, "upper"), set())
  
    results = collections.defaultdict(lambda: {})
    for m in world:
        cls, mth = m.split('.');
        results[cls][mth] = ''

    for key in analyses: 
        path = analyses[key]
        lower = readset(os.path.join(path, "lower"), set()) & world
        upper = readset(os.path.join(path, "upper"), set()) & world

        extend_dict(results, lower | upper, key)

    json.dump(results, sys.stdout)
    print()
