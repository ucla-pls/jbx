#!/usr/bin/env python3
# -*- coding: utf-8 -*-

""" 
This is the main file of the scripting related to JBX. 
"""

import inspect
import os.path as path

CURRENTFILE = inspect.getfile(inspect.currentframe())
CURRENTFOLDER = path.dirname(path.abspath(CURRENTFILE))
JBXPATH = path.join(path.dirname(CURRENTFOLDER), "expr", "default.nix")

import nixutils
from funcparse import *

benchmarkSelector = Arg("-b", "a list of benchmarks")

LIST_CMD = """
let
  jbx = import {filename} {{}};
in {query}
"""
def list(
        what : Enum(["analyses", "benchmarks", "translators" ],
                "what do you want information about"
            ) = "benchmarks",
        **opts
    ):
    """ returns a list of the things """
    if what == "benchmarks":
        query = "builtins.attrNames jbx.benchmarks.byName"
    elif what == "analyses":
        query = "builtins.attrNames jbx.analyses"
    else:
        query = "builtins.attrNames jbx.translators"

    cmd = LIST_CMD.format(query = query, **opts)
    for item in nixutils.evaluate(cmd):
        print(item)


BUILD_CMD = """
let
  jbx = import {filename} {{}};
  inherit (jbx.utils) withJava;
  java = jbx.java.java{java};
  fetch = (b: {fetch});
in map fetch (map (withJava java) {benchmarks})
"""
def build(
        benchmarks : benchmarkSelector = [],
        src_only : Arg(None, 
            "only fetch the source of the benchmark."
        ) = False,
        **opts
    ):
    """Builds a benchmark"""
    fetch = "b.build.src" if src_only else "b.build"
    cmd = BUILD_CMD.format(
        fetch = fetch, 
        benchmarks = benchmarks, 
        **opts
    )
    nixutils.build(cmd, **opts)

def main(
        command : SubCommands(build, list,
            help="available sub-commands"        
            ),
        java : Arg("-j",
            "Java version"
        ) = 6,
        filename : Arg("-f", 
            "the path to the jbx default.nix file."
        ) = path.relpath(JBXPATH),
        keep_failed : Arg("-K", 
            "keeps the output even if the output fails"
        ) = False,
        dry_run : Arg("-n",
            "do not execute, print nix command instead"
        ) = False
    ): 
    """Jbx is a collection of tools that helps you writing nix scripts
    for working with jbx.
    """
    opts = dict(
        java = java, 
        keep_failed = keep_failed, 
        dry_run = dry_run,
        filename = filename
    )
    print(opts)
    return command(**opts)

if __name__ == "__main__":
    parse_args(main)()
