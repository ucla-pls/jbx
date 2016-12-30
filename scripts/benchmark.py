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
    try:
        with open(os.path.join(path, filename)) as f:
            return [ v for v in map(str.strip,f.read().splitlines()) if v];
    except:
        return []

def output_json(info, opts):
    print(json.dumps(info, indent=2, separators=(",", ": "), sort_keys=True));


def output_overview(info, opts):
    minimal = {
        "sha256": info["sha256"],
        "name": info["name"],
        "benchmarks": len(info["benchmarks"]),
        "classes": len(info["classes"]),
        "repo": info["repo"],
        "path": info["path"],
        "buildwith": info["buildwith"],
        "subfolder": info["subfolder"]
    }
    print(json.dumps(minimal, indent=2, separators=(",", ": "), sort_keys=True));


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
    "output_json": output_json,
    "overview": output_overview
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
       sha256 = "{sha256}";
     }} jbx.java.java{java})
"""


NIX_EXPR = """{{ fetchurl, fetchgit, utils }}:
let
  src = {fetchexpr};
  repository = {{
    src = src;
    subfolder = "{subfolder}";
    sha256 = "{sha256}";
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

def populate(benchmark, **opts):
    """given a minimal dict of benchmarks, calculate hash if missing."""

    fetch_expr = fetch.nixexpr(benchmark["repo"]);

    pop = dict(benchmark);

    pop.update(
        nixutils.verify(
            """
            let jbx = import {filename} {{}};
                inherit (jbx.pkgs) fetchurl fetchgit;
                inherit (jbx.utils) fetchmuse;
                java = jbx.java.java{java};
            in jbx.utils.flattenRepository {} java
            """,
            fetch.only(pop, "name", "subfolder", "sha256", src=fetch_expr),
            **opts
        )
    )

    path = pop["path"];

    pop["classes"] = getfile(path, "info/classes")
    name = pop["name"] = pop.get("name") or path.split("-", 1)[1].replace("-", "_");
    pop["buildwith"] = getfile(path, "info/buildwith")[0]
    pop["mainclasses"] = sorted(set(getfile(path, "info/mainclasses")));

    pop["benchmarks"] = [
        { "name":  name + "_" + class_.replace(".","_").lower(),
          "mainclass":  class_,
          "inputs": [
              { "name": "empty",
                "args": [],
                "stdin": ""
              }
          ]
        }
        for class_ in pop["mainclasses"]
    ];

    return pop;


def benchmark (
        repo : fetch.REPO_ARG,
        cachefile : fetch.CACHEFILE_ARG = "",

        subfolder :
          Arg(None,
              help = "use a subfolder of the repository"
          ) = "",

        sha256 :
          Arg(None,
              help = "use a known hash"
          ) = "",

        action:
          Enum(ACTIONS.keys(),
               help = "the action to perform with downloaded benchmark",
               action = lambda x: ACTIONS[x]
          ) = "overview",

        **opts):
    """ Add or test a new benchmark"""

    # Ensure the repo is working
    repo = fetch.fetchobj(repo, **opts);

    info = populate({
        "repo": repo,
        "subfolder": subfolder,
        "sha256": sha256
    }, **opts)

    action(info, opts)
