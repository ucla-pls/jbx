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

TYPES = {
    "git": GitRepo,
    "url": UrlRepo
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


REPO_ARG = OneOf(
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
)

CACHEFILE_ARG = Arg(
    "-c",
    help = "use a cache file"
)

def fetch (
        repo : REPO_ARG,
        cachefile : CACHEFILE_ARG = "",
        **opts):

    print(json.dumps(
        prefetch(repo, cachefile),
        indent=2,
        separators=(",", ": "),
        sort_keys=True
    ));
