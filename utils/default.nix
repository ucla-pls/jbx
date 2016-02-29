# module: JBX utils.
# author: Christian Kalhauge <kalhauge@cs.ucla.edu>
# description: |
#   This module contains all the utilities needed to build jbx.
{lib, stdenv, callPackage}:
rec {
  # Type: Benchmark 
  #   A benchmark is a description of a java program, which is buildable 
  #   and runnable. Benchmarks are parammeterized by the java version used.
  
  # Type: BenchmarkTemplate
  mkBenchmarkTemplate = meta @ {
      name
    , mainclass
    , build # Java -> Drv
    # inputs, describes inputs which can run the program
    , inputs ? []
    # runtime libraries 
    , libraries ? java: [] # Java -> [Drv]
    # tags, can be added to help search
    , tags ? []
    # filter enables us to filter on java versions
    , filter ? jv: true
    , data ? build # a data repository, for tests
    , ...
    }: 
    let self = meta // { 
      inherit inputs libraries tags filter data; 
      withJava = withJava self;
    }; in self;

  # Type: Java -> BenchmarkTemplate -> Benchmark
  # Takes a benchmark template and java version to produce a benchmark
  withJava = 
    template: 
    java:
    assert template.filter java;
    template // rec {
      inherit java;
      name = template.name + java.id;
      inherit (template) filter tags inputs data;
      build = stdenv.mkDerivation ({inherit name;} // template.build java);
      libraries = template.libraries java;
    };

  # Type: File<BenchmarkTemplate.meta> -> args -> BenchmarkTemplate
  callBenchmark = 
    path: 
    config: 
    mkBenchmarkTemplate (callPackage path config);
 
  # Type: Analysis : Benchmark -> Env -> Result

  # >> Utilities 
  # This section contains small functions that might be nice to have
  
  # Groups a list of benchmarks by name
  byName = bms:  builtins.listToAttrs (map (b: { name = b.name; value = b; }) bms);
  
  # Groups a list of benchmarks by tags
  byTag = bms:
    let byTagList = map (b: map (t: {name = t; value = b; }) b.tags) bms;
    in builtins.foldl' 
      (attrset: e: updateDefault attrset e.name [] (l: l ++ [e.value]))
      {} (builtins.concatLists byTagList);

  # Get a value if exists. Else return default value
  getDefault = attrset: name: default: 
    if attrset ? ${name} then attrset.${name} else default;
 
  # Update the a value with default, if it exists if not use default value.
  updateDefault = attrset: name: default: fun: 
    attrset // {${name} = fun (getDefault attrset name default); };
}

