#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module allows us to run dynamic analyses on benchmarks.
"""

from functools import partial
from funcparse import *
import nixutils

RUN_CMD = """
let
  jbx = import {filename} {{}};
  java = jbx.java.java{java};

  env = import {environment};
  lib = jbx.pkgs.lib;
  inherit (jbx.utils) getInput;

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
            action=nixutils.from_attrset_list("jbx.transformers")
        )
    = "[]",

    input_name:
        Arg("-i", help = "the input to the dynamic analysis")
    = "",

    analysis:
        Arg("-a", help = "the dynamic analyisis to run")
    = "run.run",

    *args,
    **opts
    ):
    """ run a dynamic analysis """

    if input_name:
        input = "getInput transformed \"{}\"".format(input_name)
    else:
        input_string = "{{ name = \"cmdline\"; args = {}; }}"
        input = input_string.format(nixutils.to_nix_list(args))

    cmd = RUN_CMD.format(
        benchmark = benchmark,
        input = input,
        transformers = transformers,
        analysis = analysis,
        **opts
    )

    nixutils.build(
        cmd,
        **opts
    )
