
import subprocess

def add_benchmark_selection(parser):
    def get_benchmarks_expr(args):
        if (args.only): 
            return "[{}]".format(" ".join(map ("jbx.benchmarks.byName.{0}".format, args.only)))
        elif (args.tag):
            return "jbx.benchmarks.byTag.{0}".format(args.tag)
        else:
            return "jbx.benchmarks.all"

    group = parser.add_mutually_exclusive_group(required=True);
    group.add_argument("--only", metavar="Benchmark", nargs="*", help="a select number of benchmarks");
    group.add_argument("--all", action="store_true", help="all benchmarks");
    group.add_argument("--tag", help="all benchmarks with tag");
    parser.set_defaults(get_benchmarks_expr=get_benchmarks_expr); 

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
