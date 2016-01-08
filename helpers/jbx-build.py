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

    nixutils.build("""
            let i = import {} {{}};
            in i.benchmarks.byName.{}.withJava i.java.java{}
        """.format(args.filename, args.benchmark, args.java)
    );


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
