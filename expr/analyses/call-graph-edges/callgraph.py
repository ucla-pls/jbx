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

Node = namedtuple("Node", "outedges inedges data")

def empty_node(outedges = None, inedges = None, data = None):
    return Node(outedges or set(), inedges or set(), data or dict())

class Graph:
    """ This graph keeps track of stdlib nodes
    """

    def __init__(self, lookup=None, nodes=None):
        self.lookup = lookup or {}
        self.nodes = nodes or [empty_node() for i in range(max(lookup.values()) + 1)]

    def new_node(self):
        """Create a new node"""
        newnode = empty_node()
        idx = len(self.nodes)
        self.nodes.append(newnode)
        return idx

    def node(self, node, create=False):
        """Add a node to the graph from a name"""
        try:
            return self.lookup[node]
        except KeyError:
            if create:
                idx = self.new_node()
                self.lookup[node] = idx
                return idx
            else:
                raise

    def add_edge(self, i, j):
        """ Add an edge to the graph.  """
        self.nodes[i].outedges.add(j)
        self.nodes[j].inedges.add(i)
    
    def add_edge_from_nodes(self, a, b, create=False):
        """ Add an edge to the graph.  """
        i, j = self.node(a, create), self.node(b, create)
        self.add_edge(i, j)
        return (i, j)

    def postorder(self):
        """ Return the list of nodes in postorder """
        visited = [False] * len(self.nodes)

        State = namedtuple("State", "idx report")

        dfs = queue.LifoQueue(State(i, False) for i in range(len(self.nodes)))
        while not dfs.empty():
            elem, report = dfs.get()
            if report:
                yield elem

            if visited[elem]:
                continue

            for i in self.nodes[elem].outedges:
                if not visited[i]:
                    dfs.put(State(i, False))

            visited[elem] = True
            dfs.put(State(elem, True))


    def join(self, sets):
        """ Given a list of compute the trasitive union of sets in the list.
        Returns
        -------
        list
            A list of closures of the missing edeges.
        """
        closures = list(sets)

        update = queue.LifoQueue(reversed(list(self.postorder())))
        while not update.empty():
            i = update.get()
            closure = closures[i]
            updated = False
            for j in self.nodes[i].outedges:
                outclosure = closures[j]
                if closure > outclosure:
                    continue
                else:
                    closure = closure | outclosure
                    updated = True

            if updated:
                closures[i] = closure
                for j in self.nodes[i].inedges:
                    update.put(j)

        return closures



def remove_stdlib(edges, stdlib):
    graph = Graph(lookup=stdlib)
    references = [set() for i in graph.nodes]

    missed = []
    for edge in edges:
        _from, _, _to = edge
        try:
            i = graph.node(_from)
        except KeyError as e:
            missed.append(edge) 
            continue

        try:
            j = graph.node(_to)
            graph.add_edge(i, j)
        except KeyError as e:
            references[i].add(_to)

    closures = graph.join(references)
   
    for edge in missed:
        _from, bcode, _to = edge
        try:
            j = graph.node(_to)
        except KeyError as e:
            yield (_from, bcode, _to)
        else:
            for _to in closures[j]:
                yield (_from, bcode, _to)

def main(args):
    with open(args.stdlib) as fp:
        stdlib = {line.strip(): i for i, line in enumerate(fp)}

    callsites = None
    if args.callsites:
        callsites = defaultdict(set)
        with open(args.callsites) as fp:
            for row in csv.DictReader(fp):
                callsites[row["method"]].add(row["offset"])
        callsites = dict(callsites)

    methods = None
    if args.methods: 
        with open(args.methods) as fp:
            methods = set(line.strip() for line in fp)

    writer = csv.writer(sys.stdout)
    bad_callsites = set()
    bad_targets = set()
    for edge in remove_stdlib(csv.reader(sys.stdin), stdlib):
        _from, offset, _to = edge
        instr = callsites.get(_from, set())

        success = True
        
        if not instr or not offset in instr:
            bad_callsites.add((_from, offset))
            success = False

        if not _to in methods:
            bad_targets.add(_to)
            success = False
       
        if success:
            writer.writerow(edge)

    if bad_targets:
        print(f"Had {len(bad_targets)} invalid targets:", file=sys.stderr)
        for _to in sorted(bad_targets):
            print(f"  {_to}", file=sys.stderr)

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


