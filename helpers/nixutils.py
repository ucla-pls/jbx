
import subprocess

def build(string, dry_run=True):
    return call(["nix-build", "--expr", string], dry_run)

def shell(string, dry_run=True):
    return call(["nix-shell", "--expr", string], dry_run)

def evaluate(string, dry_run=True):
    return call(["nix-instantiate", "--eval", "--expr", string], dry_run)

def call(args, dry_run=False):
    if dry_run:
        print subprocess.list2cmdline(args) 
    else:
        subprocess.call(args)
