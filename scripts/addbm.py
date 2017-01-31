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
from funcparse import *

JBX_HOME = path.dirname(path.dirname(__file__))
AUTOGEN = path.join(JBX_HOME, "expr", "benchmarks", "auto-generated")
DLJC = path.join(path.dirname(__file__), 'dljc', 'dljc')

REPO_TEMPLATE = """{{ fetchgit, utils, ant, cpio }}:
let
  bm = {{ name, main, builddir, srcdir, destdir }}: utils.mkBenchmarkTemplate {{
    tags = [ "{repo}" ];
    name = name;
    mainclass = main;
    build = java: {{
      src = fetchgit {{
        url = "{url}";
        branchName = "master";
        rev = "{rev}";
        md5 = "{md5}";
      }};
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      buildInputs = [ ant java.jdk cpio ];
      buildPhase = ''
        cd ${{builddir}}
        {build_cmd}
        cd ${{destdir}}
        jar vcf ${{name}}.jar .
      '';
      installPhase = ''
        mkdir -p $out/share/java/
        mv ${{name}}.jar $_
        cd ../${{srcdir}}
        mkdir -p $out/src/
        find . -name '*.java' | cpio -pdm $out/src
      '';
    }};
  }};
in rec {{
  {bms}

  all = [
    {bmnames}
  ];
}}
"""

BM_TEMPLATE = """{name} = bm {{
    name = "{name}";
    main = "{main}";
    builddir = "{builddir}";
    destdir = "{destdir}";
    srcdir = "{srcdir}";
  }};
"""

AUTOGEN_TEMPLATE = """{{ callPackage, utils }}:
rec {{
  {callpkgs}

  all = builtins.foldl' (all: bm: all ++ bm.all) [] [
    {names}
  ];
}}
"""

CALLPKG_TEMPLATE = "{name} = callPackage ./{name} {{}};"

def add(
    repo : Arg(None, help = "the url of the repo to add"),
    **opts
    ):
    addbm(repo, **opts)

def addbm(url, build_cmd="ant", **kwargs):
    dtemp, md5, rev = get_repo(url)

    repo_name = re.search('.*github.com/.*/(.*)\.git', url).group(1)

    dirs = find_bms(dtemp)

    bms = []
    bmnames = []
    for bm in dirs:
        cp, src = watch_build(bm, build_cmd)
        rel_cp = [rel_path(p, dtemp) for p in cp][0]
        rel_src = [rel_path(p, dtemp) for p in src][0]
        rel_build = rel_path(bm, dtemp)

        main = get_mainclass(bm)
        name = path.basename(bm)
        bmnames.append(name)

        bms.append(BM_TEMPLATE.format(
            name=name,
            main=main,
            builddir=rel_build,
            destdir=rel_path(rel_cp, rel_build),
            srcdir=rel_path(rel_src, rel_build)
        ))

    expr = REPO_TEMPLATE.format(
        repo=repo_name,
        url=url,
        rev=rev,
        md5=md5,
        build_cmd=build_cmd,
        bms="\n  ".join(bms),
        bmnames="\n    ".join(bmnames)
    )

    store_expr(repo_name, expr)
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
    for dir, _, files in os.walk(dtemp):
        for f in glob.glob(path.join(dir, ".git*")):
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
    cp = out['javac_switches']['classpath'].split(':')
    src = out['javac_switches']['sourcepath'].split(':')
    return cp, src

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
    bms = "\n  ".join([CALLPKG_TEMPLATE.format(name=name) for name in names])
    expr = AUTOGEN_TEMPLATE.format(
        callpkgs=bms,
        names="\n    ".join(names)
    )
    write_path = path.join(AUTOGEN, "default.nix")
    f = open(write_path, 'w')
    f.write(expr)
    f.close()
    
def rel_path(full, pre):
    parts = full.split("/")
    d = path.basename(pre)
    return "/".join(parts[parts.index(d)+1:])
