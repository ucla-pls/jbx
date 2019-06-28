{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "9bebeb7fed14dcd6ea384e0d45fd3a5d26485e91";
      sha256 = "005pqxg7rlxhlngdd0msm6q2ahqfi57wm90zd5l6nmvyc4bdsf05";
    };
    phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''ant jar'';
    installPhase = ''
      mkdir -p $out
      cp -r src $out/src
      cp -r build/classes $out/classes
      mkdir -p $out/share/java/
      mv build/baseline.jar $_
    '';
  };
  mkBaseline = 
    { name 
    , mainclass
    }: 
    utils.mkBenchmarkTemplate {
       inherit mainclass;
       name = "baseline-${name}";
       build = baseline;
       inputs = [
         { name = "default";
           args = [];
         }
       ];
     };
in rec {
  transfer = mkBaseline {
    name = "transfer";
    mainclass = "edu.ucla.pls.baseline.Transfer";
  };
  infinite = mkBaseline {
    name = "infinite";
    mainclass = "edu.ucla.pls.baseline.Infinite";
  };
  reflection = mkBaseline {
    name = "reflection";
    mainclass = "edu.ucla.pls.baseline.Reflection";
  };
  reflection_reachability = mkBaseline {
    name = "reflection_reachability";
    mainclass = "edu.ucla.pls.baseline.ReflectionReachability";
  };
  object_arrays = mkBaseline {
    name = "object_arrays";
    mainclass = "edu.ucla.pls.baseline.ObjectArrays";
  };
  test = mkBaseline {
    name = "test";
    mainclass = "edu.ucla.pls.baseline.Test";
  };
  bensalem = mkBaseline {
    name = "bensalem";
    mainclass = "edu.ucla.pls.baseline.Bensalem";
  };
  dependent_datarace = mkBaseline {
    name = "dependent_datarace";
    mainclass = "edu.ucla.pls.baseline.DependentDatarace";
  };
  picklock = mkBaseline {
    name = "picklock";
    mainclass = "edu.ucla.pls.baseline.PickLock";
  };
  notadeadlock = mkBaseline {
    name = "notadeadlock";
    mainclass = "edu.ucla.pls.baseline.NotADeadlock";
  };
  objectarrays = utils.mkBenchmarkTemplate {
    name = "objectarrays";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.ObjectArrays";
    inputs = [
      { name = "one";
        args = [];
      }
    ];
  };
  simplelambda = mkBaseline {
    name = "simplelambda";
    mainclass = "edu.ucla.pls.baseline.SimpleLambda";
  };
  all = [
    transfer
    infinite
    reflection
    reflection_reachability
    object_arrays
    test
    bensalem
    dependent_datarace
    picklock
    notadeadlock
    simplelambda
  ];
}
