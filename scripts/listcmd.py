#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module enables us to list benchmarks, tags, analyses, and transformers.
"""

from functools import partial
from funcparse import *
import nixutils

LIST_CMD = """
let
  jbx = import {filename} {{}};
  lib = jbx.pkgs.lib;
in {query}
"""
def list(
        what:
            Enum(["analyses", "benchmarks", "transformers", "tags"],
                help = "what do you want information about"
            )
        = "benchmarks",

        **opts
    ):
    """ returns a list of the things """
    if what == "benchmarks":
        query = "builtins.attrNames jbx.benchmarks.byName"
    elif what == "tags":
        query = "builtins.attrNames jbx.benchmarks.byTag"
    elif what == "analyses":
        query = "builtins.attrNames jbx.analyses"
    else:
        query = "builtins.attrNames jbx.transformer"

    cmd = LIST_CMD.format(query = query, **opts)
    for item in nixutils.evaluate(cmd):
        print(item)
