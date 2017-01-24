import json
import subprocess
import sys
import tempfile
import os
import re

from collections import namedtuple

import logging

logger = logging.getLogger("jbx.nixutils")

def build(string,
          dry_run=True,
          keep_failed=False,
          keep_going=True,
          debug=False,
          timeout=None,
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
    logger.debug(string);
    print(timeout)
    return call(cmd, dry_run=dry_run, timeout=timeout)

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
        logger.debug(string);
    result = run(cmd, timeout=timeout);

    if result.returncode != 0:
        return hashfetchre.search(result.stderr).group(1);

def shell(string, dry_run=True, **kwargs):
    return call(["nix-shell", "--expr", string], dry_run)


def call(args, dry_run=False, timeout=None):
    if dry_run:
        logger.info(subprocess.list2cmdline(args))
        return None
    else:
        return check_output(args, timeout=timeout).strip();

def check_output(args, env=None, timeout=None):
    try:
        return subprocess.check_output(args, universal_newlines=True, env=env, timeout=timeout)
    except:
        logger.error("Failed while running %s", subprocess.list2cmdline(args))
        sys.exit("Failed while running program");

def run(args, env=None, timeout=None):
    result = subprocess.run(args,
                    universal_newlines=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    env=env,
                    timeout=timeout);
    return result;

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

def prefetch_git(url, rev, sha256 = None):
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    if sha256:
        obj = check_json(["nix-prefetch-git", url, rev, sha256 ], env=env)
        # Assume that the user knows the revision and the date.
        del obj["rev"]
        del obj["date"]
    else:
        obj = check_json(["nix-prefetch-git", url, rev], env=env)
    return obj

def prefetch_url(url, sha256 = None):
    return {
        "url" : url,
        "sha256" : check_output(
            ["nix-prefetch-url", url]
            + ([sha256] if sha256 else [])
        )
    }

def raw_build(
        expr,
        debug=False,
        keep_failed=False,
        keep_going=False,
        cores="",
        env=None,
        timeout=None,
        **kwargs):
    """ Raw build builds an expression and returns a subprocess.CompletedProcess
    """

    cmd = ["nix-build"]

    if debug: cmd += ["--show-trace"]
    if keep_failed: cmd += ["--keep-failed"]
    if keep_going: cmd += ["--keep-going"]
    if cores: cmd += ["--cores", cores]

    if len(expr) < 512:
        cmd += [ "--expr", expr ]
    else:
        (f, t) = tempfile.mkstemp()
        with open(t, "w") as f:
            f.write(expr)

        cmd.append(t)

    for line in expr.split("\n"):
        logger.debug(line)

    logger.debug(cmd);

    return subprocess.run(
        cmd,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        timeout=timeout
    )

HASH_REGEXS = [
    re.compile(
        r"output path ‘[^’]+’ should have r:sha256 hash ‘[^‘]+’, instead has ‘([^‘]+)’"
    ),
    re.compile(
        r"output path ‘[^’]+’ has r:sha256 hash ‘([^‘]+)’ when ‘[^‘]+’ was expected"
    ),
    re.compile(
        r"output path ‘[^’]+’ has sha256 hash ‘([^‘]+)’ when ‘[^‘]+’ was expected"
    )
]


def verify(method, obj, **kwargs):
    """ verify runs the method with the object and checks if builds completes.
    If the command succeeds a copy of the object is returned. If the command
    fails, then we search the output for a sha256 hash line, add it to the
    object and rerun the program. If that does not succeed the program will throw
    an exception.
    """
    arg = dict(obj);

    if not arg.get("sha256"):
        arg["sha256"] = "0000000000000000000000000000000000000000000000000000"

    cmd = method.format(dumps(arg), **kwargs);
    result = raw_build(cmd, **kwargs);

    if result.returncode == 0:
        arg["path"] = result.stdout.strip();
        return arg;
    else:
        try:
            for regex in HASH_REGEXS:
                match = regex.search(result.stderr);
                if match:
                    break
            arg["sha256"] = match.group(1);
        except:
            logger.error("Build failed:")
            for line in result.stderr.split('\n'):
                logger.error(line);
            logger.error(cmd);
            raise ValueError("Un-buildable Build");
        else:
            cmd = method.format(dumps(arg), **kwargs);
            result = raw_build(cmd, **kwargs);
            if result.returncode == 0:
                arg["path"] = result.stdout.strip();
                return arg;
            else:
                logger.error("Build not reproducable:")
                for line in result.stderr.split('\n'):
                    logger.error(line);
                raise ValueError("Unverifiable Build");


App = namedtuple("App", "function arg")

def dump(obj, fp, **kwargs):
    """dump is equivalent to json.dump, but with nix, and less options.
    """
    import numbers;

    seperators = kwargs.setdefault("seperators", ("=", ";"))

    if isinstance(obj, dict):
        fp.write("{");
        for key in obj:
            fp.write(key)
            fp.write(seperators[0])
            dump(obj[key], fp, **kwargs)
            fp.write(seperators[1])
        fp.write("}");
    elif isinstance(obj, list):
        fp.write("[");
        fst, *rest = obj;
        dump(fst, fp, **kwargs);
        for val in rest:
            fp.write(" ")
            dump(val, fp, **kwargs);
        fp.write("]");
    elif isinstance(obj, str):
        fp.write('"')
        fp.write(obj)
        fp.write('"')
    elif isinstance(obj, bool):
        fp.write("true" if obj else "false");
    elif isinstance(obj, numbers.Number):
        fp.write(str(obj));
    elif isinstance(obj, App):
        fp.write(obj.function)
        fp.write(" ")
        dump(obj.arg, fp, **kwargs)
    else:
        raise TypeError("Bad argument type " + str(type(obj)) + ": " + str(obj))


def dumps(obj, **kwargs):
    from io import StringIO
    fp = StringIO()
    dump(obj, fp, **kwargs)
    return fp.getvalue()
