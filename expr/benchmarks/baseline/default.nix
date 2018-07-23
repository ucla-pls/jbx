{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "7948c458411570ad4eb44a082d418c7dfa3f5afa";
      sha256 = "1xycbrn02v7kymr430jhdqr1l5qp17car8hjda04x297j82105s6";
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
  ];
}
