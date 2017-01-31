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


def json_to_nix (string):
    benchmarks = fetch.parse_json(string);
    expr = benchmark.nixexpr(benchmarks)
    return "(jbx.pkgs.callPackage ({}) {{}}).all".format(expr)

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
                action=json_to_nix
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
