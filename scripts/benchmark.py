#!/usr/bin/evn python3

"""
This module handles new benchmarks.
"""

import collections
import json
import os.path
import sys
import logging

from funcparse import *
import nixutils
import fetch

logger = logging.getLogger("jbx.benchmark")


def getfile(path, filename):
    with open(os.path.join(path, filename)) as f:
        return [ v for v in map(str.strip,f.read().splitlines()) if v];


def handle_results(path):
    classes = getfile(path, "info/classes")
    name = path.split("-", 1)[1];

    try:
        subfolder = getfile(path, "info/subfolder")[0]
    except:
        subfolder = ""

    buildwith = getfile(path, "info/buildwith")[0]

    mainclasses = sorted(set(getfile(path, "info/mainclasses")));

    benchmarks = [
        { "name":  name + "_" + class_.replace(".","_").lower(),
          "mainclass":  class_,
          "inputs": [
              { "name": "empty",
                "args": [],
                "stdin": ""
              }
          ]
        }
        for class_ in mainclasses
    ]

    return {
        # "classes": classes,
        "name": name,
        "path": path,
        "classes": len(classes),
        "benchmarks": benchmarks,
        "subfolder": subfolder,
        "buildwith": buildwith
    };

def output_json(info, opts):
    print(json.dumps(info, indent=2, separators=(",", ": "), sort_keys=True));


def output_nix(info, opts):
    print(nixexpr(info))

TEST_EXPR = """
let
  jbx = import {filename} {{}};
  env = import {environment};
  java = jbx.java.java{java};

  analysis =
    jbx.analyses.reachable-methods.overview;

  benchmarkTemplate =
{expr};

  benchmarks =
    (jbx.pkgs.callPackage benchmarkTemplate {{}}).all;

  results =
    map
      (b: analysis (b.withJava java) env)
      benchmarks;

in results
"""

def test(info, opts):
    expr = nixexpr(info);

    test_expr = TEST_EXPR.format(
        expr = "\n".join("    " + e for e in expr.split("\n")),
        **opts
    );
    nixutils.build(test_expr, **opts);

ACTIONS = {
    "test": test,
    "nix":  output_nix,
    "json": output_json
}

EXPR = """
let
  jbx = import {filename} {{}};
  inherit (jbx.pkgs) fetchurl fetchgit;
  src = {fetch_expr};
in
  jbx.pkgs.stdenv.mkDerivation
    (jbx.utils.flattenRepository {{
       src = src;
       subfolder = "{subfolder}";
     }} jbx.java.java{java})
"""


NIX_EXPR = """{{ fetchurl, fetchgit, utils }}:
let
  src = {fetchexpr};
  repository = {{
    src = src;
    subfolder = "{subfolder}";
  }};
in rec {{

{bms}

  all = [
    {bmsnames}
  ];
}}"""

BM_FORMAT = """  {name} =
    utils.toBenchmark repository {{
      name = "{name}";
      mainclass = "{mainclass}";
      inputs = [
{inputs_}
      ];
    }};"""

INPUT_FORMAT = """        {{
          name = "{name}";
          args = [{args_}];
          stdin = "{stdin}";
        }}"""

def nixexpr(info):
    return NIX_EXPR.format(
        fetchexpr = fetch.fetchexpr(info["repo"]),
        bms = "\n".join(
            BM_FORMAT.format(
                inputs_ = "\n".join(
                    INPUT_FORMAT.format(
                        args_ = " ".join(map(repr, input_["args"])),
                        **input_
                    )
                    for input_ in benchmark["inputs"]
                ),
                **benchmark
                )
            for benchmark in info["benchmarks"]
        ),
        bmsnames = "\n".join(
            benchmark["name"]
            for benchmark in info["benchmarks"]
        ),
        **info
    );

def benchmark (
        repo : fetch.REPO_ARG,
        cachefile : fetch.CACHEFILE_ARG = "",

        subfolder :
          Arg(None,
              help = "use a subfolder of the repository"
          ) = "",

        action:
          Enum(ACTIONS.keys(),
               help = "the action to perform with downloaded benchmark",
               action = lambda x: ACTIONS[x]
          ) = "json",

        **opts):
    """ Add or test a new benchmark"""
    prefetch = fetch.prefetch(repo, cachefile);

    fetch_expr = repo.fetchexpr(prefetch)
    dir_ = nixutils.build(
        EXPR.format(
            fetch_expr = fetch_expr,
            subfolder = subfolder,
            **opts
        ),
        **opts
    );

    info = handle_results(dir_);
    info["repo"] = prefetch;

    action(info, opts)
