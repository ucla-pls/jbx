#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Run is a utility tool for running benchmarks fast without having to add editing
the results.
"""

import sys
import nixutils

def argparser():
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__, 
        formatter_class=argparse.RawDescriptionHelpFormatter
        )
    
    parser.add_argument("benchmark",
            help="the benchmark that should be run",
            )
    parser.add_argument("-a", "--analysis",
            default="run.run",
            help="the dynamic analysis to run"
            )
    parser.add_argument("-f", "--filename",
            default="./default.nix",
            help="the nixfile to build from (default: './default.nix')"
            )
    parser.add_argument("-E", "--environment",
            default="./environment.nix",
            help="the nixfile to build from (default: './default.nix')"
            )
    parser.add_argument("-j", "--java", 
            type=int, 
            default=7,
            metavar="version",
            help="the java version to build with (default: 7)"
            )
    parser.add_argument("-n", "--dry-run", 
            action="store_true",
            help="do not exeucte, but print cmd instead"
            )
    parser.add_argument("-i", "--input", 
            default=None,
            help="name of the imput to run"
            )
    parser.add_argument("arg", 
            nargs="*",
            help="a list of arguments parsed directly to the benchmark"
            )
    
    return parser

def main(arguments):
    args = argparser().parse_args(arguments)

    args.fargs = "[{}]".format(' '.join(map('"{}"'.format, args.arg)))
    
    if not args.input:
        args.input_obj = '{{ name="cli"; args={0.args}; }}'.format(args)
    else:
        args.input_obj = '(builtins.elemAt (builtins.filter (i: i.name == "{0.input}") bm.inputs) 0)'.format(args)
    cmd = """
      with (import {0.filename} {{}});
      let bm = benchmarks.byName.{0.benchmark}.withJava java.java{0.java};
      in analyses.{0.analysis} (import {0.environment}) bm {0.input_obj}
    """.format(args)
    nixutils.build(cmd, dry_run=args.dry_run);

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
