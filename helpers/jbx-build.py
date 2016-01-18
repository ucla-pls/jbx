#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Build facilitates the build process of benchmarks. Making it easier to check if
a benchmark works.
"""

import sys
import nixutils

def argparser():
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__, 
        formatter_class=argparse.RawDescriptionHelpFormatter
        )

    parser.add_argument("benchmark", help="the benchmark that should be build");
    parser.add_argument("-f", "--filename",
            default="./default.nix",
            help="the nixfile to build from (default: './default.nix')"
            )
    parser.add_argument("--src-only",
            action="store_true",
            help="only evaluate the source src variable",
            )
    parser.add_argument("--keep-failed", "-K",
            action="store_true",
            help="keeps the output even if the build fails.",
            )
    parser.add_argument("--shell", 
            action="store_const",
            help="start a shell with all the dependencies (see nix-shell)",
            default=nixutils.build,
            const=nixutils.shell,
            dest="method"
            )
    parser.add_argument("-j", "--java", 
            type=int, 
            default=7,
            metavar="version",
            help="the java version to build with (default: 7)"
        );
    parser.add_argument("-n", "--dry-run", 
            action="store_true",
            help="do not exeucte, but print cmd instead"
        );
    
    return parser

def main(arguments):
    args = argparser().parse_args(arguments)

    path = "i.benchmarks.byName.{0.benchmark}.withJava i.java.java{0.java}".format(args)
    if args.src_only: 
        path = "({}).build.src".format(path)

    cmd = "let i = import {0.filename} {{}}; in {1}".format(args, path)
    args.method(cmd, dry_run=args.dry_run, keep_failed=args.keep_failed);


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
