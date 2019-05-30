# module: JBX utils.
# author: Christian Kalhauge <kalhauge@cs.ucla.edu>
# description: |
#   This module contains all the utilities needed to build jbx.
{ lib
, stdenv
, callPackage
, procps
, time
, coreutils
, python
, fetchurl
, env
, eject
}:
let inherit (lib.lists) concatMap filter;
in with lib.debug; rec {
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
      data = if template.data != null then template.data else build;
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
  #   upper    -- contains all the upper bound of results.
  #   lower    -- contains all the lower bound of results.
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

  # Type: DynamicAnalysis : Benchmark -> Env -> Input -> Result

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
      inputname = input_.name;
      name = name + "+" + benchmark.name + "." + input.name;
      utils = ./utils.sh;
      builder = ./analysis.sh;
      buildInputs = [procps] ++ tools ++ [ benchmark.java.jre ];
    });

  # onAllInputsS : Dyn a -> Analysis [a]
  onAllInputsS =
    dyn:
    benchmark:
    env:
    map (dyn benchmark env) benchmark.inputs;

  # onAllInputs : Dyn Result -> Options -> Analysis Result
  # This function changes a DynamicAnalysis to an Analysis, by running
  # the analysis on all inputs.
  onAllInputs =
    analysis:
    options:
    benchmark:
    env:
    let
      results = map (analysis benchmark env) benchmark.inputs;
      basename = (builtins.elemAt results 0).name;
    in compose (options // {
      name = builtins.elemAt (lib.strings.splitString "." basename) 0;
    }) results;


  # analyseInput : DynamicAnalysis -> Benchmark -> Env -> Key -> Result
  analyseInput =
    analysis:
    benchmark:
    env:
    key:
    analysis benchmark env (getInput benchmark key);

  # getInput : Benchmark -> Key -> Input
  getInput =
    benchmark:
    key:
    (builtins.elemAt (builtins.filter (i: i.name == key) benchmark.inputs) 0);


  # analyse: Env -> Benchmark -> Analysis -> Result
  # Analyse calls the analysis with reverse arguments
  analyse =
    env:
    benchmark:
    analysis:
    analysis benchmark env;

  # mkTransformer : Options -> BenchmarkTemplate -> BenchmarkTemplate
  # A transformer moves a benchmark from one scope to another.
  mkTransformer =
    options @ {
      name
      , transform # is a function from java.
    }:
    benchTemplate:
    let self = benchTemplate // (transform benchTemplate) // {
      name = benchTemplate.name + "_" + options.name;
      withJava = java: withJava java self;
      };
    in self;

  # compose: Options -> [Result] -> Result
  # Takes a list of results, run them and perform post actions to combine
  # everything:
  compose =
    options @ { name, ... }: # Needs atleast a name
    results:
    mkResult (options // {
      results = results;
      builder = ./compose.sh;
      utils   = ./utils.sh;
      inherit time coreutils;
    });

  # postprocess: Options -> Result -> Result
  # postprocess is a transparrent overlay that enables the analysis
  # to do extra processing after the first run.
  postprocess =
    options @ {
      postprocess,  # The extendsion
      name ? "pp",
      tools ? [],
      ignoreSandbox ? false,
      timelimit ? 3600,
      ...
    }:
    result:
    let
      nameList = lib.strings.splitString "+" result.name;
      benchmarkName = (builtins.elemAt nameList 1);
      analysisName = (builtins.elemAt nameList 0);
    in mkResult (options // {
      inherit result;
      inherit timelimit;
      name = analysisName + "-" + name + "+" + benchmarkName;
      utils = ./utils.sh;
      inherit time coreutils ignoreSandbox;
      buildInputs = [procps] ++ tools;
      builder = ./postprocess.sh;
    });

  # after : Analysis -> Options -> Analysis
  # perform postprocessing after an analysis has run
  after =
    analysis:
    options:
      lift (postprocess ({ name = "after"; } // options)) analysis;

  # afterD : DynamicAnalysis -> Options -> DynamicAnalysis
  # perform postprocessing after an dynamic analysis has run
  afterD =
    danalysis:
    options:
      liftD (postprocess ({ name = "after"; } // options))
           danalysis;

  # liftpp : (Result -> Result) -> Analysis -> Analysis
  # liftpp =
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

  # mkStatistics: Options -> [Result] -> Statistics
  mkStatistics =
    options @ {
        name
      , before ? ""
      , collect ? ""
      , foreach ? ""
      , tools ? []
      , ...
    }:
    assert collect != "" || foreach != "";
    results:
    stdenv.mkDerivation (options // {
      inherit results;
      buildInputs = [procps] ++ tools;
      builder = ./statistics.sh;
    });

  # overview: Name -> [Analysis] -> Benchmark -> Env -> Statistics
  # Overview creates a single table containing data about the success of the
  # execution.
  # TODO this might not fit in here.
  overview =
    name:
    analyses:
    benchmark:
    liftL (mkStatistics {
      name = name + "+" + benchmark.name;
      tools = [ python eject];
      collect = ''
        cd $out
        python ${./overview.py} $results
      '';
    }) analyses benchmark;

  # cappedOverview: Name -> Analysis -> [Analysis] -> Benchmark -> Env -> Statistics
  cappedOverview =
    name:
    world:
    analyses:
    post: 
    benchmark:
    env:
    liftL (mkStatistics {
      name = name + "+" + benchmark.name;
      tools = [ python eject ] ++ post.tools;
      after = post.after;
      collect = ''
        cd $out
        python ${./overview.py} -w "${world benchmark env}/upper" $results
        runHook after
      '';
    }) analyses benchmark env;

  # usage: Name -> [Result] -> Statistics
  usage =
    name:
    mkStatistics {
      inherit name;
      tools = [ python eject];
      collect = "python ${./usage.py} $results | tee usage.csv | column -ts','";
    };

  # versionize: [Java] -> [BenchmarkTemplate] -> [Benchmark]
  versionize =
    javas:
    benchmarks:
    #filter (b: b == null ) (
        product (b: j: b.withJava j)
          benchmarks javas
          ;#  );


  # flattenRepository: Derivation -> Repository
  flattenRepository = callPackage ./flatten-repository;

  buildJar =
    repository:
    java:
    {
       src = repository java;
       buildInputs = [ java.jdk ];
       phases = [ "unpackPhase" "buildPhase" "installPhase"];
       buildPhase = ''
         mkdir -p $out/share/java

         jar cf $out/share/java/$name.jar -C classes .
         jar uf $out/share/java/$name.jar -C lib .
       '';
       installPhase = ''
         cp -r . $out
       '';
    };

  repeatR =
    f: # Nat -> Result
    times:
    builtins.genList f times;

  rename =
    f:
    result:
    lib.overrideDerivation result ( options: { name = f options.name; });

  repeatedF = r: n: rename (name: name + "-repeat" + toString n) r;

  # repeated :: Options -> Dyn Statistics
  repeated =
    options @ {
      times
      , ...
    }:
    mapDyn (r:
      mkStatistics
      ({ name = r.name + "-repeated"; } // options)
      (repeatR (repeatedF r) times));

  # repeated :: Options -> Dyn Statistics
    repeated' =
      options @ {
          name
        , times
        , ...
      }:
      mapDyn (f: mkStatistics (options) (repeatR f times));

  mapDyn = # Dyn b
    f: # a -> b
    dyn: # Dyn a
    benchmark:
    env:
    input:
    f (dyn benchmark env input);

  # toBenchmark: Repository -> Options -> Benchmark
  toBenchmark =
    repository:
    options @ {
      name
    , mainclass
    , ...
    }:
    mkBenchmarkTemplate ({
      build = buildJar (flattenRepository repository);
    } // options);

  # This project contains some proprietary file not
  # distributed with this pkg.
  fetchprop =
    options:
    fetchurl (options // {
      url = env.ppath + options.url;
    });

  # Fetching from the leidos muse corpus
  fetchmuse = callPackage ./fetchmuse;

  # >> Utilities
  # This section contains small functions that might be nice to have

  # fcomp :: (b -> c) -> (a -> b) -> a -> c
  fcomp = f: g: a: f (g a);

  # product :: (a -> b -> c) -> [a] -> [b] -> [c]
  product = f: as: bs: concatMap (a: map (b: f a b) bs) as;

  # onAll: Analysis -> [Benchmark] -> Env -> [Result]
  onAll =
    analysis:
    benchmarks:
    env:
      builtins.map (b: analysis b env) benchmarks;

  # withAll: [StaAnalysis] -> Sta [Result]
  withAll =
    analyses:
    benchmark:
    env:
      builtins.map (analyse env benchmark) analyses;
  
  # withAllD: [DynAnalysis] -> Dyn [Result]
  withAllD =
    analyses:
    benchmark:
    env:
    input:
      builtins.map (a: a benchmark env input) analyses;

  # lift: (a -> b) -> Sta a -> Sta b
  lift =
    f:
    analysis:
    benchmark:
    env:
      f (analysis benchmark env);

  # liftD: (a -> b) -> Dyn a -> Dyn b
  liftD =
    f:
    analysis:
    benchmark:
    env:
    input:
    f (analysis benchmark env input);

  # liftL: ([Result] -> a) -> [Analysis] -> Benchmark -> Env -> a
  liftL =
    f:
    analyses:
    benchmark:
    env:
      f (withAll analyses benchmark env);

  # Groups a list of benchmarks by name
  byName =
    bms: builtins.listToAttrs (map (b: { name = b.name; value = b; }) bms);

  # Groups a list of benchmarks by tags
  byTag =
    bms:
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
