#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module allows us to run analyses on a list of benchmarks.
"""

from functools import partial
from funcparse import *
import nixutils
import benchmark
import fetch

def test(info, transformers, analysis, opts):
    expr = benchmark.nixexpr(info)

    test_expr = ANALYSE_JSON_CMD.format(
        expr = "\n".join("    " + e for e in expr.split("\n")),
        transformers = transformers,
        analysis = analysis,
        **opts
    );

    nixutils.build(test_expr, **opts)

ANALYSE_JSON_CMD = """
let
  jbx = import {filename} {{}};
  java = jbx.java.java{java};

  env = import {environment};
  lib = jbx.pkgs.lib;

  benchmarkTemplate = {expr};

  benchmarks = (jbx.pkgs.callPackage benchmarkTemplate {{}}).all;
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
                action = nixutils.from_attrset_list("jbx.benchmarks.byName")
            ),
            tag = Arg("-t",
                help = "a single tag",
                action="jbx.benchmarks.byTag.{}".format
            ),
            json = Arg(None,
                help = "a json object representing the benchmark",
                action=fetch.parse_json
            )
        ),

    transformers:
        ListOf("-T",
            help = "transformers in order",
            action=nixutils.from_attrset_list("jbx.transformers")
        )
    = "[]",

    analysis:
        Arg("-a",
            help = "analysis of choice",
            action="jbx.analyses.{}".format
        )
    = "(b: env: b)", # do nothing

    **opts
    ):
    """ runs a series of analyses one or more benchmarks. """

    # JSON code path
    if (type(benchmarks) is dict):
        repo = fetch.fetchobj(benchmarks, **opts)
    
        info = benchmark.populate({
            "repo": repo,
            "subfolder": "",
            "sha256": ""
        }, **opts)
    
        test(info, transformers, analysis, opts)

    # NON-JSON code path
    else:
        cmd = ANALYSE_CMD.format(
            benchmarks = benchmarks,
            transformers = transformers,
            analysis = analysis,
            **opts
        )
        nixutils.build(
            cmd,
            keep_going = not opts["short_curcuit"],
            **opts
        )
