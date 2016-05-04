# -*- coding: utf-8 -*-

"""
This script enables adding of benchmarks from online repositories.
"""

import ast
import glob
import os
import os.path as path
import re
import shutil
from subprocess import call, Popen, PIPE
import tempfile

import nixutils

JBX_HOME = path.dirname(path.dirname(__file__))
AUTOGEN = path.join(JBX_HOME, "expr", "benchmarks", "auto-generated")
DLJC = path.join(path.dirname(__file__), 'dljc', 'dljc')

BM_TEMPLATE = """{{ fetchgit, utils, ant }}:
{{
  tags = [ "{tag}" ];
  name = "{name}";
  mainclass = "{main}";
  build = java: {{
    src = fetchgit {{
      url = "{url}";
      rev = "{rev}";
      md5 = "{md5}";
    }};
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd {build_path}
      {build_cmd}
      cd {rel_dest}
      jar vcf {name}.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv {name}.jar $_
    '';
  }};
}}
"""

MV_CP_TEMPLATE = "mv {cp}/*.class $out/share/java/"

AUTOGEN_TEMPLATE = """{{ utils }}:
let
  inherit (utils) callBenchmark;
in rec {{
  {bms}

  all = [ {names} ];
}}
"""

CALLBM_TEMPLATE = "{name} = callBenchmark ./{name} {{}};"

def add(url, build_cmd="ant", **kwargs):
    dtemp, md5, revision = get_repo(url)

    m = re.search('.*github.com/.*/(.*)\.git', url)
    repo_name = m.group(1)

    dirs = find_bms(dtemp)

    for bm in dirs:
        cp = watch_build(bm, build_cmd)
        rel_cp = [rel_path(p, dtemp) for p in cp][0]
        name = path.basename(bm)
        main = get_mainclass(bm)
        build_path = rel_path(bm, dtemp)
        expr = BM_TEMPLATE.format(
            tag=repo_name,
            name=name,
            main=main,
            rev=revision,
            url=url,
            md5=md5,
            build_path=build_path,
            build_cmd=build_cmd,
            rel_dest=rel_path(rel_cp, build_path)
        )
        store_expr(name, expr)
        
    refresh_autogen()

    # Remove tmp folder
    shutil.rmtree(dtemp)
    
def get_repo(url):
    dtemp = tempfile.mkdtemp()
    call(["git", "clone", url, dtemp])

    # Get the revision
    os.chdir(dtemp)
    proc = Popen(["git", "log", "-n", "1", "--format=%H"], stdout=PIPE)
    log, _ = proc.communicate()
    revision = log.strip()

    # Remove .git*
    shutil.rmtree(path.join(dtemp, ".git"))
    for f in glob.glob(dtemp + "/.git*"):
        os.remove(f)

    md5 = nixutils.hash(dtemp).strip()
    return dtemp, md5.decode("utf-8"), revision.decode("utf-8")

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
    
def rel_path(full, pre):
    parts = full.split("/")
    d = path.basename(pre)
    return "/".join(parts[parts.index(d)+1:])
