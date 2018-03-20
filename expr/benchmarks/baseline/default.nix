{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "c3f56a5cd3ad4e5fc0602eefef51cdb6912b8f6b";
      sha256 = "1icr0p0gkb4zcv3m4bnpic7ss9ga24pfm21slc0k42h18c9v9lbq";
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
       inherit name mainclass;
       build = baseline;
       inputs = [
         { name = "default";
           args = [];
         }
       ];
     };
in rec {
  transfer = utils.mkBenchmarkTemplate {
    name = "transfer";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.Transfer";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  infinite = utils.mkBenchmarkTemplate {
    name = "infinite";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.Infinite";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  reflection = utils.mkBenchmarkTemplate {
    name = "reflection";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.Reflection";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  reflection_reachability = utils.mkBenchmarkTemplate {
    name = "reflection_reachability";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.ReflectionReachability";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  object_arrays = utils.mkBenchmarkTemplate {
    name = "object_arrays";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.ObjectArrays";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  test = utils.mkBenchmarkTemplate {
    name = "test";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.Test";
    inputs = [
      { name = "default";
        args = [];
      }
    ];
  };
  bensalem = mkBaseline {
    name = "bensalem";
    mainclass = "edu.ucla.pls.baseline.Bensalem";
  };
  dependent_datarace = mkBaseline {
    name = "dependent_datarace";
    mainclass = "edu.ucla.pls.baseline.DependentDatarace";
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
  ];
}
