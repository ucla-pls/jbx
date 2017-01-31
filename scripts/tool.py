#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module enables us to download/test tools.
"""

from functools import partial
from funcparse import *
import nixutils

TOOL_CMD = """
let jbx = import {filename} {{}};
in jbx.pkgs.{tool}
"""
def tool(
        tool : Arg(None, help="the tool to install"),
        **opts
    ):
    """ test a tool."""
    cmd = TOOL_CMD.format(tool=tool, **opts)
    nixutils.build(cmd, **opts)
