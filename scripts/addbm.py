# -*- coding: utf-8 -*-

"""
This script enables adding of benchmarks from online repositories.
"""

import ast
import json
import os
import os.path as path
import shutil
from subprocess import call, Popen, PIPE
import tempfile

import nixutils

JBX_HOME = path.dirname(path.dirname(__file__))
AUTOGEN = path.join(JBX_HOME, "expr", "benchmarks", "auto-generated")
DLJC = path.join(path.dirname(__file__), 'dljc', 'dljc')

BM_TEMPLATE = """
{{ fetchgit, utils, ant }}:
{{
  name = "{name}";
  mainclass = "{main}";
  build = java: {{
    version = "{version}";
    src = fetchgit {{
      url = "{url}";
      md5 = "{md5}";
    }};
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java/
      {createJars}
      {mvJars}
    '';
  }};
}}
"""

AUTOGEN_TEMPLATE = """
{{ utils }}:
let
  inherit (utils) callBenchmark;
in rec {{
  {bms}

  all = [ {names} ];
}}
"""

CALLBM_TEMPLATE = "{name} = callBenchmark ./{name} {{}};"

def add(url, build_cmd="ant", **kwargs):
    dtemp, md5, version = get_repo(url)

    dirs = find_bms(dtemp)

    for bm in dirs:
        cp = watch_build(bm, build_cmd)
        name = path.basename(bm)
        main = get_mainclass(bm)
        expr = BM_TEMPLATE.format(
            name=name,
            main=main,
            version=version,
            url=url,
            md5=md5,
            createJars='',
            mvJars=''
        )
        store_expr(name, expr)

    refresh_autogen()

    # Remove tmp folder
    shutil.rmtree(dtemp)
    
def get_repo(url):
    dtemp = tempfile.mkdtemp()
    call(["git", "clone", url, dtemp])

    # Get the version
    proc = Popen(["git", "log", "-n", "1", "--format=%H"], stdout=PIPE)
    log, _ = proc.communicate()
    version = log[0:6]

    shutil.rmtree(path.join(dtemp, ".git"))
    md5 = nixutils.hash(dtemp).strip()
    return dtemp, md5.decode("utf-8"), version.decode("utf-8")

def find_bms(dir):
    dirs = []
    for root, _, files in os.walk(dir):
        for f in files:
            if f == "build.xml":
                dirs.append(path.abspath(root))
    return dirs
                
def watch_build(path, build_cmd):
    os.chdir(path)
    cmd = [DLJC, "-t", "print", "--"] + build_cmd.split(" ")
    proc = Popen(cmd, stdout=PIPE, stderr=PIPE)
    stdout, _ = proc.communicate()

    out = ast.literal_eval(stdout.decode("utf-8"))
    return out['javac_switches']['classpath'].split(':')

def get_mainclass(bm):
    prop_file = path.join(bm, "petablox.properties")
    if path.exists(prop_file):
        f = open(prop_file, 'r')
        for line in f:
            if line.startswith("petablox.main.class"):
                mainclass = line.strip().split('=')[1]
        f.close()
        return mainclass
    else:
        return None

def store_expr(name, expr):
    write_path = path.join(AUTOGEN, name, "default.nix")
    os.mkdir(path.dirname(write_path))
    f = open(write_path, 'w')
    f.write(expr)
    f.close()

def refresh_autogen():
    _, dirs, _ = next(os.walk(AUTOGEN))
    names = [path.basename(d) for d in dirs]
    bms = "\n  ".join([CALLBM_TEMPLATE.format(name=name) for name in names])
    expr = AUTOGEN_TEMPLATE.format(
        bms=bms,
        names=("\n" + (" " * 10)).join(names)
    )
    write_path = path.join(AUTOGEN, "default.nix")
    f = open(write_path, 'w')
    f.write(expr)
    f.close()
    
