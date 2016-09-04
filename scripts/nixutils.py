import json
import subprocess
import sys
import tempfile
import os

import logging

logger = logging.getLogger("jbx.nixutils")

def build(string, dry_run=True,
          keep_failed=False, keep_going=True, debug=False,
          **kwargs):

    (f, t) = tempfile.mkstemp()
    with open(t, "w") as f:
        f.write(string);

    cmd = ( ["nix-build"] +
        (["--show-trace"] if debug else []) +
        (["--keep-failed"] if keep_failed else []) +
        (["--keep-going"] if keep_going else []) +
        [t]
    )
    if debug:
        call(cmd, True)
    return call(cmd, dry_run).strip();

def shell(string, dry_run=True, **kwargs):
    return call(["nix-shell", "--expr", string], dry_run)

def check_output(args, env=None):
    try:
        return subprocess.check_output(args, universal_newlines=True, env=env)
    except:
        logger.error("Failed while running %s", subprocess.list2cmdline(args))
        sys.exit("Failed while running program");

def check_json(args, env=None):
    output = check_output(args, env=env);
    try:
        return json.loads(output)
    except:
        logger.error("Couldn't parse output from command")
        call(args, True)
        logger.info(output)
        sys.exit("Could not parse output")

def evaluate(string):
    args = ["nix-instantiate", "--eval", "--json", "--expr", string]
    return check_json(args)

def hash(path):
    proc = subprocess.Popen(["nix-hash", path], stdout=subprocess.PIPE)
    return proc.communicate()[0]

def call(args, dry_run=False):
    if dry_run:
        logger.info(subprocess.list2cmdline(args))
    else:
        return check_output(args)

def prefetch_git(url, rev, cache = None):
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    return check_json(
    	["nix-prefetch-git", url, rev]
	+ ([cache] if cache else []),
        env=env 
    )

def prefetch_url(url, cache = None):
    sha256 = check_output(["nix-prefetch-url", url]
                          + ([cache] if cache else []))
    return { "url" : url, "sha256" : sha256 }
