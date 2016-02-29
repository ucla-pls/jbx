
import subprocess

def add_benchmark_selection(parser):
    parser.add_argument("benchmark", help="the benchmark that should be build");

def build(string, dry_run=True, keep_failed=False):
    return call(
            ["nix-build"] +
                (["--keep-failed"] if keep_failed else []) +
                ["--expr", string], 
            dry_run
    )

def shell(string, dry_run=True, keep_failed=False):
    return call(["nix-shell", "--expr", string], dry_run)

def evaluate(string, dry_run=True):
    return call(["nix-instantiate", "--eval", "--expr", string], dry_run)

def call(args, dry_run=False):
    if dry_run:
        print subprocess.list2cmdline(args) 
    else:
        subprocess.call(args)
