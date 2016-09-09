#!/usr/bin/evn python3

"""
This this module enables us to download repositories.
"""

import collections
import json

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
            info["name"] = self.url.strip("/").rsplit("/",1)[1].lower()
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


FETCHMUSE_EXPR = """
    fetchmuse {{
      url = "{path}";
      sha256 = "{sha256}";
    }}"""


class MuseRepo (collections.namedtuple("MuseRepo", "path")):

    def prefetch (repo, cache = {}):
        try:
            info = cache[str(self)];
        except:
            info["sha256"] = nixutils.fetchhash(repo.fetchexpr({
                "path": repo.path,
                "sha256": "0000000000000000000000000000000000000000000000000000"
            }));
            info["type"] = "muse"
        return info

    @staticmethod
    def fetchexpr (options):
        return FETCHMUSE_EXPR.format(**options);



TYPES = {
    "git": GitRepo,
    "url": UrlRepo,
    "muse": MuseRepo
}

def fromtype(type_):
    return TYPES[type_]


def fetchexpr(info):
    return fromtype(info["type"]).fetchexpr(info);


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


def prefetch(repo, cachefile):
    cache = get_cache(cachefile);
    prefetch = repo.prefetch(cache);
    save_cache(cachefile, cache)
    return prefetch

def only(dict_, *keys):
    return { key: dict_[key] for key in keys if key in dict_ }

def fetchobj(obj, **opts):
    type_ = obj["type"];

    obj = dict(obj);

    if type_ == "git":
        obj.update(
            ixutils.verify(
                "(import {filename} {{}}).pkgs.fetchgit {}",
                only(obj, "name", "url", "rev", "sha256"),
                **opts
            )
        )
    elif type_ == "url":
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

def parse_muse(string):
    return {
        "url": string,
        "type": "muse"
    }

def parse_json(string):
    return json.load(string)

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

def fetch(
        repo : REPO_ARG,
        name :
           Arg(None,
               help = "The name of the build",
               ) = "",
        cachefile : CACHEFILE_ARG = "",
        **opts):

    if name:
        repo["name"] = name
    print(json.dumps(fetchobj(repo, **opts)))
