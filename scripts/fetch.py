#!/usr/bin/evn python3

"""
This this module enables us to download repositories.
"""

import collections
import json
import sys
import os.path

from funcparse import *
import nixutils

def only(dict_, *keys, **kwargs):
    obj= { key: dict_[key] for key in keys if key in dict_ }
    obj.update(kwargs);
    return obj;

def fetchobj(obj, **opts):
    type_ = obj["type"];

    obj = dict(obj);

    if type_ == "git":
        obj.update(nixutils.prefetch_git(**only(obj, "url", "rev", "sha256")))
        obj.update(
            nixutils.verify(
                "(import {filename} {{}}).pkgs.fetchgit {}",
                only(obj, "name", "url", "rev", "sha256"),
                **opts
            )
        )
    elif type_ == "url":
        obj.update(nixutils.prefetch_url(**only(obj, "url", "sha256")))
        obj.update(
            nixutils.verify(
                "(import {filename} {{}}).pkgs.fetchurl {}",
                only(obj, "name", "url", "sha256"),
                **opts
            )
        )
    elif type_ == "muse":
        obj.update(
            nixutils.verify(
                "(import {filename} {{}}).utils.fetchmuse {}",
                only(obj, "name", "url", "sha256"),
                **opts
            )
        )

    return obj

def nixexpr(obj):
    type_ = obj["type"];
    if type_ == 'git':
        expr = nixutils.App("fetchgit", only(obj, "name", "url", "rev", "sha256"))
    if type_ == 'url':
        expr = nixutils.App("fetchurl", only(obj, "name", "url", "sha256"))
    if type_ == 'muse':
        expr = nixutils.App("fetchmuse", only(obj, "name", "url", "sha256"))
    return expr


GIT_REGEX = re.compile("(?P<url>https:[^:]*):(?P<rev>.*)")
def parse_git(string):
    macth = GIT_REGEX.match(string);
    if match is None:
        info = { "url": string }
    else:
        info = match.groupdict()
    info["name"] = info['url'].strip("/").rsplit("/",1)[1];
    info["type"] = "git"

    return info;

def parse_url(string):
    return {
        "name": string.strip("/").rsplit("/",1)[1],
        "url": string,
        "type": "url"
    }

UUID_REGEX = re.compile(r"[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}")
def parse_muse(string):
    match = UUID_REGEX.match(string)
    if not match:
        url = string
        uuid = UUID_REGEX.search(string).group(0)
    else:
        uuid = match.group(0)
        url = "/".join(list(uuid.split('-',1)[0])) + "/" + uuid + "/" + uuid + "_code.tgz"
    return {
        "url": url,
        "uuid": uuid,
        "name": uuid + "_code.tgz",
        "type": "muse"
    }

def parse_json(string):
    if string == '-':
        return json.load(sys.stdin)
    elif os.path.isfile(string):
        with open(string, "r") as fp:
            return json.load(fp)
    else:
        return json.loads(string)

REPO_ARG = OneOf(
    git =
        Arg(None,
            help = "name and optionally rev of benchmark. "
            + "https://github.com/s/repo:refs/heads/master",
            action = parse_git
        ),
    url =
        Arg(None,
            help = "the url of the benchmark",
            action = parse_url
        ),
    muse =
        Arg(None,
            help = "the muse url of the benchmark",
            action = parse_muse
        ),
    json =
        Arg(None,
            help = "a json object describing the benchmark",
            action = parse_json
        )
)

CACHEFILE_ARG = Arg(
    "-c",
    help = "use a cache file"
)

def pool_helper(a):
    return fetchobj(a[0], **a[1]);

def fetch(
        repo : REPO_ARG,
        name :
           Arg(None,
               help = "The name of the build",
               ) = "",
        sha256 :
           Arg(None,
               help = "The hash of the build",
           ) = "",
        jobs:
           Arg(None,
               help = "The number of cores to use.",
           ) = 0,
        append:
           Arg(None,
               help = "Appends the results to the this file"
           ) = "",
        **opts):

    if isinstance(repo, list):
        from multiprocessing import Pool
        if jobs == 0:
            jobs = None
        with Pool(jobs) as p:
            result = p.map(pool_helper, [ (r, opts) for r in repo ]);
    else:
        if name:
            repo["name"] = name

        if sha256:
            repo["sha256"] = sha256

        result = fetchobj(repo, **opts);

    if append:
        try:
            with open(append, "r") as fp:
                lists = json.load(fp)
        except:
            lists = [];

        if isinstance(result, list):
            lists.extend(result)
        else:
            lists.append(result)

        with open(append, "w") as fp:
            json.dump(
                result,
                fp,
                indent=2,
                sort_keys=True,
                separators=(",", ": ")
            )
    else:
        json.dump(
            result,
            sys.stdout,
            indent=2,
            sort_keys=True,
            separators=(",", ": ")
        )
