#!/usr/bin/evn python3

"""
This module handles new benchmarks.
"""

import collections
import functools
import json
import os.path
import sys

from funcparse import *
import nixutils


FETCHGIT_EXPR = """
    fetchgit {{
      name = "{name}";
      url = "{url}";
      rev = "{rev}";
      sha256 = "{sha256}";
    }}"""

GIT_REGEX = re.compile("(?P<url>https:[^:]*):(?P<rev>.*)")

class GitRepo (collections.namedtuple("GitRepo", "url rev")):

    def prefetch (self, cache = {}):
        try:
            info = cache[str(self)];
        except:
            info = nixutils.prefetch_git(self.url, self.rev)
            info["rev"] = info["rev"] or self.rev
            info["type"] = "git"
            info["name"] = self.url.strip("/").rsplit("/",1)[1]
            del info["date"]
            cache[str(self)] = info;
        return info

    @staticmethod
    def parse (string):
        match = GIT_REGEX.match(string);
        if match:
            return GitRepo(**match.groupdict());
        else:
            return GitRepo(url=string, rev="refs/heads/master");

    @staticmethod
    def fetchexpr (options):
        return FETCHGIT_EXPR.format(**options);

    def __str__(self):
        return self.url + ":" + self.rev;



FETCHURL_EXPR = """
    fetchurl {{
      url = "{url}";
      rev = "{rev}";
      sha256 = "{sha256}";
    }}"""

class UrlRepo (collections.namedtuple("UrlRepo", "url")):

    def prefetch (repo, cache = {}):
        try:
            info = cache[str(self)];
        except:
            info = nixutils.prefetch_url(repo.url, cache);
            info["type"] = "url"
        return info

    @staticmethod
    def fetchexpr (options):
        return FETCHURL_EXPR.format(**options);

TYPES = {
    "git": GitRepo,
    "url": UrlRepo
}

def fromtype(type_):
    return TYPES[type_]


def fetchexpr(info):
    return fromtype(info["type"]).fetchexpr(info);


def getfile(path, filename):
    with open(os.path.join(path, filename)) as f:
        return f.read().splitlines();


def handle_results(path):
    classes = getfile(path, "classes.txt")
    name = path.rsplit("-", 1)[1];
    benchmarks = [
        { "name":  name + "_" + class_.rsplit(".",1)[1].lower(),
          "mainclass":  class_,
          "inputs": [
              { "name": "empty",
                "args": [],
                "stdin": ""
              }
          ]
        }
        for class_ in getfile(path, "mainclasses.txt")
    ]

    return {
        # "classes": classes,
        "name": name,
        "path": path,
        "benchmarks": benchmarks
    };

def output_json(info, opts):
    print(json.dumps(info, indent=2, separators=(",", ": "), sort_keys=True));

NIX_EXPR = """{{ fetchurl, fetchgit, utils }}:
let
  src = {fetchexpr};
  repository = {{
    src = src;
    subfolder = "{{subfolder}}";
  }}
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
        fetchexpr = fetchexpr(info["repo"]),
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

def get_cache(cachefile):
    try:
        with open(cachefile) as f:
            cache = json.load(f);
    except FileNotFoundError:
        cache = dict()
    except:
        sys.stderr.write("Mall-formed cache: Delete or fix '{}'.\n".format(cachefile));
        sys.exit(-1);
    return cache

def save_cache(cachefile, cache):
    with open(cachefile, "w") as f:
        f.write(json.dumps(cache, indent=2, separators=(',', ': '), sort_keys=True));

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

def benchmark (
        repo :
          OneOf(
            git =
              Arg(None,
                  help = "name and optionally rev of benchmark. "
                       + "https://github.com/s/repo:refs/heads/master",
                  action = GitRepo.parse
              ),
            url =
              Arg(None,
                  help = "the url of the benchmark",
                  action = UrlRepo
              )
          ),

        cachefile :
          Arg("-c",
              help = "use a cache file"
          ) = "",

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
    cache = get_cache(cachefile);

    prefetch = repo.prefetch(cache);

    save_cache(cachefile, cache)

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
