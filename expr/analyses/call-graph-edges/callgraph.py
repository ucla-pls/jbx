#!/usr/bin/env python3
'''
The goal of this module is to read a csv file of edges and then transitive
close the ones that are through the standard library.

This script also has as job to find any inconsistencies in the output.

'''

import queue
import csv
import sys
from collections import namedtuple, defaultdict

import graph_tool as gt
import graph_tool.topology as gt_top


def progress(iterator, incr=100, file=sys.stderr):
    try:
        total = len(iterator)
    except TypeError:
        total = "??"

    for n, i in enumerate(iterator):
        if n % incr == 0:
            print(f"At {n} / {total}", file=file)
        yield i

def remove_stdlib(edges, stdlib):
    g = gt.Graph()
    
    keep = g.new_vertex_property("bool", False)
    method = g.new_vertex_property("string")
    verticies = defaultdict(g.add_vertex)

    print("Iterating through edges", file=sys.stderr)
    missed = defaultdict(list)
    for edge in edges:
        _from, offset, _to = edge

        j = verticies[_to]
        if not _to in stdlib:
            method[j] = _to
            keep[j] = True
            
        if not _from in stdlib:
            missed[_from, offset].append(_to) 
            keep[j] = True
        else:
            i = verticies[_from]
            g.add_edge(i, j)


    print(f"Graph computed {g}", file=sys.stderr)

    print("Computing the trasitive closure", file=sys.stderr)
    tgc = gt_top.transitive_closure(g);
    tgc.set_vertex_filter(keep)
    
    print(f"Restricting nodes={tgc.num_vertices()} edges={tgc.num_edges()}", file=sys.stderr)

    references = dict()
    for (_from, offset), tos in missed.items():
        alls = set()
        for _to in tos:
            if not _to in stdlib:
                alls.add((_to, True))
            else:
                try:
                    refs = references[_to]
                except KeyError:
                    j = verticies[_to]
                    refs = { (method[x], False) for x in
                            tgc.get_out_neighbors(j)} - {("", False)}
                    references[_to] = refs
                alls |= refs
        yield from (((_from, offset, t), direct) for t, direct in alls)
        
def main(args):
    with open(args.stdlib) as fp:
        stdlib = {line.strip() for line in fp}

    callsites = None
    if args.callsites:
        callsites = defaultdict(set)
        callsites["<boot>"].add("0")
        with open(args.callsites) as fp:
            for row in csv.DictReader(fp):
                callsites[row["method"]].add(row["offset"])
        callsites = dict(callsites)

    methods = None
    if args.methods: 
        with open(args.methods) as fp:
            methods = set(line.strip() for line in fp)

    writer = csv.writer(sys.stdout)
    bad_callsites = dict()
    bad_targets = dict()
    for edge, direct in remove_stdlib(csv.reader(sys.stdin), stdlib):
        _from, offset, _to = edge

        success = True

        try:
            classname, methodname = _to.split('.')
            if methodname == "<clinit>:()V":
                _from, offset = "<boot>", "0"
        except ValueError:
            pass
       
        if callsites:
            instr = callsites.get(_from, set())
            if not instr or not offset in instr:
                bad_callsites[(_from, offset)] = edge
                success = False
        if methods:
            if not _to in methods:
                bad_targets[_to] = edge
                success = False
       
        if success:
            writer.writerow([_from, offset, _to, (1 if direct else 0)])

    if bad_targets:
        print(f"Had {len(bad_targets)} invalid targets:", file=sys.stderr)
        for _to, edge in sorted(bad_targets.items()):
            print(f"  {_to} ---- {edge}", file=sys.stderr)

    if bad_callsites:
        print(f"Had {len(bad_callsites)} invalid callsites:", file=sys.stderr)
        for _from, offset in sorted(bad_callsites):
            instr = callsites.get(_from, set())
            print(f"  {_from}!{offset} {list(instr)}", file=sys.stderr)



def parse_args():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--stdlib", help="A list of std library methods.")
    p.add_argument("--callsites", help="A list of application callsites.")
    p.add_argument("--methods", help="A list of application methods.")
    return p.parse_args()

if __name__ == "__main__":
    main(parse_args())


