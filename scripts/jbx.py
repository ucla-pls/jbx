#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This is the main file of the scripting related to JBX.
"""

import inspect
import os.path as path
from functools import partial
import logging

CURRENTFILE = path.realpath(__file__)
CURRENTFOLDER = path.dirname(CURRENTFILE)
JBXFOLDER = path.dirname(CURRENTFOLDER)
JBXPATH = path.join(JBXFOLDER, "expr", "default.nix")

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

from funcparse import *
import nixutils
import benchmark
import addbm
import tool
import listcmd
import analyse
import runcmd
import fetch

def main(
    command :
        SubCommands(
            analyse.analyse, runcmd.run, listcmd.list,
            tool.tool, addbm.add, benchmark.benchmark, fetch.fetch,
            help = "available sub-commands"
        ),

    filename:
        Arg("-f",
            help = "the path to the jbx default.nix file."
        ) = JBXPATH,

    debug:
        Arg("-d",
            help = "add debug settings to the run"
        ) = False,

    dry_run:
        Arg("-n",
            help = "do not execute, print nix command instead."
        ) = False,

    java:
        Arg("-j",
            help = "Java version"
        ) = 6,

    environment:
        Arg("-E",
            help = "the user environment to run things in"
        ) = path.join(JBXFOLDER, "environment.nix"),

    keep_failed:
        Arg("-K",
            help = "keeps the output even if the output fails."
        ) = False,

    short_curcuit:
        Arg("-e",
            help = "if one of the test failes stop computing."
        ) = False,

    timeout:
        Arg("-t",
            help = "if one of the test failes stop computing.",
            action=int
        ) = -1,

    ):
    """Jbx is a collection of tools that helps you writing nix scripts
    for working with jbx.
    """

    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    timeout = None if timeout < 0 else timeout
    return command(**locals())

if __name__ == "__main__":
    parse_args(main)()
