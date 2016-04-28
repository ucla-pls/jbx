import subprocess

import json

def build(string, dry_run=True, keep_failed=False, **kwargs):
    return call(
            ["nix-build"] +
                (["--keep-failed"] if keep_failed else []) +
                ["--expr", string], 
            dry_run
    )

def shell(string, dry_run=True, **kwargs):
    return call(["nix-shell", "--expr", string], dry_run)

def evaluate(string):
    args = ["nix-instantiate", "--eval", "--json", "--expr", string]
    try:
        return json.loads(subprocess.check_output(
            args 
            , universal_newlines=True
        ))
    except subprocess.CalledProcessError:
        print("Failed while running")
        call(args, True)
        call(args) 


def call(args, dry_run=False):
    if dry_run:
        print(subprocess.list2cmdline(args))
    else:
        subprocess.call(args)
