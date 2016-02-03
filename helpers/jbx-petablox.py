#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
This script enables quick access to the petablox shared analyses.
"""

import sys
import nixutils

def argparser():
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__, 
        formatter_class=argparse.RawDescriptionHelpFormatter
        )

    parser.add_argument("benchmark", help="the benchmark that should be analysed");
    parser.add_argument("--analysis", "-a",
            action="append",
            help="the analyses to run example: 'cipa-0cfa'")
    parser.add_argument("-f", "--filename",
            default="./default.nix",
            help="the nixfile to build from (default: './default.nix')"
            )
    parser.add_argument("-r", "--reflect",
            default="external",
            help="the reflection kind [none|dynamic|external]"
            )
    parser.add_argument("-p", "--petablox",
            default="petablox",
            help="the petablox version, example petablox-test"
            )
    parser.add_argument("--engine", "-e",
            default = "null",
            help="sets the engine to use. See the tools/ folder for more. null means bddbddb.",
            )
    parser.add_argument("--keep-failed", "-K",
            action="store_true",
            help="keeps the output even if the build fails.",
            )
    parser.add_argument("-E", "--environment",
            default="./environment.nix",
            help="the nixfile that describes the environment"
            )
    parser.add_argument("-j", "--java", 
            type=int, 
            default=6,
            metavar="version",
            help="the java version to build with (default: 6)"
        );
    parser.add_argument("-n", "--dry-run", 
            action="store_true",
            help="do not exeucte, but print cmd instead"
        );
    
    return parser

def main(arguments):
    args = argparser().parse_args(arguments)
    args.analyses = "[{}]".format(" ".join(map("\"{}\"".format,args.analysis)))
    args.correctedEngine = ( "tools.{}".format(args.engine) 
                                if args.engine != "null" 
                                else "null" );
    cmd = """
      with (import {0.filename} {{}});
      let bm = benchmarks.byName.{0.benchmark}.withJava java.java{0.java};
      in analyses.shared.petablox {{ 
        subanalyses = {0.analyses}; 
        petablox = tools.{0.petablox};
        logicblox = {0.correctedEngine};
        reflection = "{0.reflect}";
      }} (import {0.environment}) bm
    """.format(args)

    nixutils.build(cmd, dry_run=args.dry_run, keep_failed=args.keep_failed);

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
