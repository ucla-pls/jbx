# module: JBX utils.
# author: Christian Kalhauge <kalhauge@cs.ucla.edu>
# description: |
#   This module contains all the utilities needed to build jbx.
{lib, stdenv, callPackage, procps, time, coreutils}:
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
    , data ? null # a data repository, for tests
    , ...
    }: 
    let self = meta // { 
      inherit inputs libraries tags filter data; 
      withJava = java: withJava java self;
    }; in self;

  # Type: Java -> BenchmarkTemplate -> Benchmark
  # Takes a benchmark template and java version to produce a benchmark
  withJava = 
    java:
    template: 
    assert template.filter java;
    template // rec {
      inherit java;
      name = template.name + java.id;
      inherit (template) filter tags inputs;
      data = if template.data != null then data else build;
      build = stdenv.mkDerivation ({inherit name;} // template.build java);
      libraries = template.libraries java;
    };

  # Type: File<BenchmarkTemplate.meta> -> args -> BenchmarkTemplate
  callBenchmark = 
    path: 
    config: 
    mkBenchmarkTemplate (callPackage path config);
    
  envToString = env: 
    "${env.name}: " +
    "${toString env.cores}x ${env.processor}, " +
    "${toString env.memorysize}mb ${env.memory}";

  # Type: Result
  # The Result is a derivation, filled with the contents of an analysis run on
  # a benchmark. A complete result will contain a number of files:
  # 
  # The results files. They should contain one result per line. The format and
  # defintion of results is left up to the analysis category. If the the file
  # does not exist, it is assumed that the analysis does not have a bound:
  #   may     -- contains all the overapproximated results. 
  #   must    -- contains all the underapproximated results.
  # 
  # The error file, if this file is present the analysis faced an error.
  #   error -- Contains a short description of the error.
  #
  # The phase files, these files contains information about the individually
  # executed phases of the algorithm.
  #   phases    -- A list of phases executed 
  #   <phasename>/
  #      stats.csv -- Equvilent to the stats.csv file, but only for this phase
  #      cmd       -- The command that was executed
  #      export    -- The environment under which it was executed 
  #      stderr    -- The stderr of the phase 
  #      stdout    -- The stdout of the phase 
  #   stderr    -- The stderr of the entire computation.
  #   stdout    -- The stdout of the entire computation.
  #
  # The performance files, these files logs performace of the analysis.
  #   stats.csv       -- Contain the name of a subphase, the computation time, kernel
  #                      time, user time, max memory used and the exit code of the
  #                      result. The fist line of the file is the header.
  #   pids            -- Maps proces ids to process names.
  #   snapshots.csv   -- This file contains snapshots of the cpu and memory ussage of
  #                      the pids. Each row contains, time since start, pid,
  #                      memory usage, and CPU ussage.
  #
  # The axiliary files,
  #   env    -- The environment under which the computation were done. A string version
  #             of the environment.nix file.
  mkResult = stdenv.mkDerivation;

  # Type: Analysis = Benchmark -> Env -> Result
  mkAnalysis = 
    options @ { 
        name
      , analysis
      , tools ? []
      , timelimit ? 3600
      , ...
    }:
    benchmark:
    env: 
    mkResult (options // { 
      inherit timelimit;
      inherit time coreutils;
      name = name + "+" + benchmark.name;
      env = envToString env;
      inherit (benchmark) mainclass build libraries data;
      utils = ./utils.sh;
      builder = ./analysis.sh;
      buildInputs = [procps] ++ tools;
    });
 
  # Type: DynamicAnalysis : Benchmark -> Env -> Result

  # mkDynamicAnalysis : Options -> Benchmark -> Env -> Input -> Result 
  # mkDynamicAnalysis is a function that creates an result using an input.
  mkDynamicAnalysis = 
    options @ { 
        name
      , tools ? []
      , timelimit ? 3600
      , ...
    }:
    benchmark:
    env: 
    input:
    let input_ = { setup = ""; args = []; stdin = ""; } // input;
    in mkResult (options // { 
      inherit time coreutils;
      env = envToString env;
      inherit timelimit;
      inherit (input_) setup stdin;
      inherit (benchmark) build libraries data mainclass;
      inputargs = input_.args;
      name = name + "+" + benchmark.name + "." + input.name;
      utils = ./utils.sh;
      builder = ./analysis.sh;
      buildInputs = [procps] ++ tools ++ [ benchmark.java.jre ];
    });

  # onAllInputs : DynamicAnalysis -> Options -> Analyis
  # This function changes a DynamicAnalysis to an Analysis, by running
  # the analsis on all inputs. 
  onAllInputs = 
    analysis:
    options:
    benchmark:
    env:
    let results = map (analysis benchmark env) benchmark.inputs;
        basename = (builtins.elemAt results 0).name;
    in compose results (options // {
      name = builtins.elemAt (lib.strings.splitString "." basename) 0;
    });

  # compose: [Result] -> Options -> Result
  # Takes a list of results, run them and perform post actions to combine
  # everything:
  compose =
    results:
    options @ { name }: # Needs atleast a name
    mkResult (options // {
      results = results;
      builder = ./compose.sh;
      utils   = ./utils.sh;
      inherit time coreutils;
    });

  # postprocess: Options -> Result -> Result
  # postprocess is a transparrent overlay that enables the analysis 
  # to do extra processing after the first run.
  # postprocess = 
  #   options @ {
  #     name, # The extendsion
  #     ...
  #   }:
  #   result: 
  #   mkResult ({
  #   } // options)

  # liftpp : Analysis -> (Result -> Result) -> Analysis 
  #liftpp = 
  #  analysis:
  #  postprocess:

  #  mkAnalysis 

  # Type Study
  # A collection of results, which is analysed.

  # The batch tool enables you to batch multible benchmarks with one
  # analysis this is especially usefull for during comparations. This
  # tool automatically 
  # batch =
  #   analysis:
  #   options:
  #   benchmarks:
  #   rec {
  #     all = compose (builtins.attrValues byName) options;
  #     byName = builtins.listToAttrs
  #       (map (benchmark: {
	#        name = benchmark.name;
	#        value = analysis benchmark;
	#      })
	#      benchmarks);
  #     };

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

