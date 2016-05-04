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

from functools import partial

import nixutils
from funcparse import *
import addbm

def quote(item):
    return '"{}"'.format(item)

def to_nix_list(list): 
   return "[{}]".format(" ".join(map(quote, list))) 

def from_attrset_list(attrset):
    def from_attrset(list):
        return "lib.attrsets.attrVals {list} {attrset}".format(
            attrset = attrset,
            list = to_nix_list(list)
        )
    return from_attrset

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


RUN_CMD = """
let
  jbx = import {filename} {{}};
  java = jbx.java.java{java};
  
  env = import {environment};
  lib = jbx.pkgs.lib;

  benchmark = {benchmark};
  transformers = {transformers};

  transformed = 
    builtins.foldl' (b': t: t b') benchmark transformers;
  
  input = {input};

in jbx.analyses.{analysis} (transformed.withJava java) env input 
"""
def run(
    
    benchmark: 
        Arg(None, 
            help = "name of the benchmark to run",
            action="jbx.benchmarks.byName.{}".format 
        ),

    transformers:
        ListOf("-T", 
            help = "transformers in order",
            action=from_attrset_list("jbx.transformers")
        )
    = "[]",

    input_name: 
        Arg("-i", help = "the input to the dynamic analysis")
    = "",

    analysis: 
        Arg("-a", help = "the dynamic analyisis to run") 
    = "run.run",

    java: 
        Arg("-j", help = "Java version") 
    = 6,
    
    debug: 
        Arg("-d", help = "add debug settings to the run") 
    = False,
    
    environment: 
        Arg("-E", help = "the user environment to run things in") 
    = path.join(JBXFOLDER, "environment.nix"),
    
    keep_failed: 
        Arg("-K", help = "keeps the output even if the output fails.") 
    = False,
    
    dry_run: 
        Arg("-n", help = "do not execute, print nix command instead.") 
    = False,

    *args, 

    **opts
    ):
    """ run a dynamic analysis """

    if input_name:
        input = "getInput transformed {!r}".format(input_name)
    else:
        input = "{{ name = \"cmdline\"; args = {}; }}".format(to_nix_list(args))

    cmd = RUN_CMD.format(
        benchmark = benchmark,
        input = input,
        environment = environment,
        transformers = transformers,
        java = java,
        analysis = analysis,
        **opts
    )
    
    nixutils.build(
        cmd,
        debug = debug,
        dry_run = dry_run, 
        keep_failed = keep_failed,
        **opts
    )

ANALYSE_CMD = """
let
  jbx = import {filename} {{}};
  java = jbx.java.java{java};
  
  env = import {environment};
  lib = jbx.pkgs.lib;

  benchmarks = {benchmarks};
  transformers = {transformers};

  analysis = {analysis};

  transformed = 
    map 
      (b: builtins.foldl' (b': t: t b') b transformers) 
      benchmarks;

  results = 
    map 
      (b: analysis (b.withJava java) env) 
      transformed;

in results
"""
def analyse(

    benchmarks: 
        OneOf(
            only = ListOf("-o", 
                help = "a list of benchmarks", 
                action = from_attrset_list("jbx.benchmarks.byName")
            ),
            tag = Arg("-t", 
                help = "a single tag", 
                action="jbx.benchmarks.byTag.{}".format
            )
        ),

    transformers:
        ListOf("-T", 
            help = "transformers in order",
            action=from_attrset_list("jbx.transformers")
        )
    = "[]",

    analysis:
        Arg("-a", 
            help = "analysis of choice",
            action="jbx.analyses.{}".format 
        )
    = "(b: env: b)", # do nothing
        
    java: 
        Arg("-j", help = "Java version") 
    = 6,
    
    debug: 
        Arg("-d", help = "add debug settings to the run") 
    = False,
    
    environment: 
        Arg("-E", help = "the user environment to run things in") 
    = path.join(JBXFOLDER, "environment.nix"),
    
    keep_failed: 
        Arg("-K", help = "keeps the output even if the output fails.") 
    = False,
    
    dry_run: 
        Arg("-n", help = "do not execute, print nix command instead.") 
    = False,

    **opts
    ): 
    """ runs a series of analyses one or more benchmarks. """
    
    cmd = ANALYSE_CMD.format(
        java = java,
        environment = environment,
        benchmarks = benchmarks,
        transformers = transformers,
        analysis = analysis,
        keep_failed = keep_failed,
        dry_run = dry_run,
        **opts
    )
    nixutils.build(
        cmd,
        debug = debug,
        dry_run = dry_run, 
        keep_failed = keep_failed,
        **opts
    )


TOOL_CMD = """
let jbx = import {filename} {{}};
in jbx.pkgs.{tool}
"""
def tool(
        tool : Arg(None, help="the tool to install"), 
        **opts
    ):
    """ test a tool."""
    cmd = TOOL_CMD.format(tool=tool, **opts)
    nixutils.build(cmd, **opts)

def add(
    repo : Arg("-r", help = "the url of the repo to add"),
    **opts
    ):
    addbm.add(repo, **opts)
    
def main(
    command : 
        SubCommands(
            analyse, run, list, tool, add,
            help = "available sub-commands"        
        ),
        
    filename: 
        Arg("-f", 
            help = "the path to the jbx default.nix file."
        ) 
    = JBXPATH,
    
    ): 
    """Jbx is a collection of tools that helps you writing nix scripts
    for working with jbx.
    """
    return command(
        filename = filename,
    )

if __name__ == "__main__":
    parse_args(main)()
