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
    
    # action = parser.add_mutually_exclusive_group()
    # action.add_argument('-i', '--interactive', 
    #         action='store_const')
    # action.add_argument('-b', '--build', 
    #         action='store_const')
    # action.add_argument('-r', '--run', 
    #         action='store_const')
    return parser

def main(arguments):
    args = argparser().parse_args(arguments)

    path = "i.benchmarks.byName.{}.withJava i.java.java{}".format(
            args.benchmark, args.java)
    if args.src_only: 
        path = "({}).build.src".format(path)

    cmd = "let i = import {} {{}}; in {}".format(args.filename, path)
    args.method(cmd)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
