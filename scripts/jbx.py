#!/usr/bin/env python3
# -*- coding: utf-8 -*-

""" 
This is the main file of the scripting related to JBX. 
"""

import inspect
import os.path as path

CURRENTFILE = inspect.getfile(inspect.currentframe())
CURRENTFOLDER = path.dirname(path.abspath(CURRENTFILE))
JBXFOLDER = path.dirname(CURRENTFOLDER)
JBXPATH = path.join(JBXFOLDER, "expr", "default.nix")

import nixutils
from funcparse import *
import addbm

def quote(item):
    return '"{}"'.format(item)

def to_nix_list(list): 
   return "[{}]".format(" ".join(map(quote, list))) 

def to_benchmark_list(list): 
    return "lib.attrsets.attrVals {list} jbx.benchmarks.byName".format(
        list=to_nix_list(list)
    )

def by_tag(tag):
    return "jbx.benchmarks.byTag.{}".format(tag)

benchmarkSelector = OneOf(
    only = ListOf("-o", 
        help = "a list of benchmarks", 
        action=to_benchmark_list
    ),
    tag = Arg("-t", 
        help = "a single tag", 
        action=by_tag
    )
)

def format_transformer(transformer):
    if transformer is None:
        return "b: b"
    else:
        return "b: jbx.transformers.{} b".format(transformer)

transformerSelector = Arg("-T",
    help = "a transforms benchmark, from jbx.transformers",
    action=format_transformer
) 

LIST_CMD = """
let
  jbx = import {filename} {{}};
  lib = jbx.pkgs.lib;
in {query}
"""
def list(
        what : Enum(["analyses", "benchmarks", "transformers", "tags"],
                help = "what do you want information about"
            ) = "benchmarks",
        **opts
    ):
    """ returns a list of the things """
    if what == "benchmarks":
        query = "builtins.attrNames jbx.benchmarks.byName"
    elif what == "tags":
        query = "builtins.attrNames jbx.benchmarks.byTag"
    elif what == "analyses":
        query = "builtins.attrNames jbx.analyses"
    else:
        query = "builtins.attrNames jbx.transformer"

    cmd = LIST_CMD.format(query = query, **opts)
    for item in nixutils.evaluate(cmd):
        print(item)


BUILD_CMD = """
let
  jbx = import {filename} {{}};
  inherit (jbx.utils) withJava;
  java = jbx.java.java{java};
  lib = jbx.pkgs.lib;
in 
  map (b: {fetch}) (
    map (withJava java) (
      map ({transformer}) (
        {benchmarks}
      )
    )
  )
"""
def build(
        benchmarks : benchmarkSelector,
        transformer: transformerSelector = None,
        src_only : Arg(None, 
            help = "only fetch the source of the benchmark."
        ) = False,
        **opts
    ):
    """Builds a benchmark"""
    
    fetch = "b.build.src" if src_only else "b.build"

    cmd = BUILD_CMD.format(
        fetch = fetch, 
        benchmarks = benchmarks, 
        transformer = transformer,
        **opts
    )
    nixutils.build(cmd, **opts)

RUN_CMD = """
let
  jbx = import {filename} {{}};
  env = import {environment};
  inherit (jbx.utils) withJava analyseInput;
  java = jbx.java.java{java};
  lib = jbx.pkgs.lib;
in 
  map (b: analyseInput jbx.analyses.{analysis} b env "{input}") (
    map (withJava java) (
      map ({transformer}) (
        {benchmarks}
      )
    )
  )
"""
def run(
    input : Arg("-i", help = "the input to the dynamic analysis"),
    benchmarks : benchmarkSelector,
    transformer: transformerSelector = None,
    analysis : Arg("-a", help = "the dynamic analyisis to run") = "run.run",
    **opts
    ):
    """ run an dynamic analysis """

    cmd = RUN_CMD.format(
        benchmarks = benchmarks,
        input = input,
        transformer = transformer,
        analysis = analysis,
        **opts
    )
    nixutils.build(cmd, **opts)

ANALYSE_CMD = """
let
  jbx = import {filename} {{}};
  env = import {environment};
  inherit (jbx.utils) withJava analyseInput;
  java = jbx.java.java{java};
  lib = jbx.pkgs.lib;
in 
  map (b: jbx.analyses.{analysis} b env ) (
    map (withJava java) (
      map ({transformer}) (
        {benchmarks}
      )
    )
  )
"""
def analyse(
    benchmarks : benchmarkSelector,
    transformer: transformerSelector = None,
    analysis : Arg("-a", help = "the analysis to run") = "run.runAll",
    **opts
    ):
    """ run an dynamic analysis """

    cmd = ANALYSE_CMD.format(
        benchmarks = benchmarks,
        transformer = transformer,
        analysis = analysis,
        **opts
    )
    nixutils.build(cmd, **opts)

TOOL_CMD = """
let jbx = import {filename} {{}};
in jbx.pkgs.{tool}
"""
def tool(
    tool : Arg(None, help="the tool to install"), 
    **opts
    ):
    cmd = TOOL_CMD.format(tool=tool, **opts)
    nixutils.build(cmd, **opts)

def add(
    repo : Arg("-r", help = "the url of the repo to add"),
    **opts
    ):
    addbm.add(repo, **opts)
    
def main(
        command : SubCommands(
            build, list, run, tool, analyse, add,
            help = "available sub-commands"        
            ),
        java : Arg("-j",
            help = "Java version"
        ) = 6,
        filename : Arg("-f", 
            help = "the path to the jbx default.nix file."
        ) = JBXPATH,
        keep_failed : Arg("-K", 
            help = "keeps the output even if the output fails."
        ) = False,
        dry_run : Arg("-n",
            help = "do not execute, print nix command instead."
        ) = False,
        debug : Arg("-d",
            help = "add debug settings to the run"
        ) = False,
        environment : Arg("-E",
            help = "the user environment to run things in",
        ) = path.join(JBXFOLDER, "environment.nix")
    ): 
    """Jbx is a collection of tools that helps you writing nix scripts
    for working with jbx.
    """
    print(command)
    return command(
        java = java, 
        keep_failed = keep_failed, 
        dry_run = dry_run,
        filename = filename,
        environment = environment,
        debug = debug
    )


if __name__ == "__main__":
    parse_args(main)()
