{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "52ab27c90eb0853fa4bdc057473115557e863909";
      md5 = "8bd945b3fb35852bee246b295415c0cf";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
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
  all = [
    transfer
    infinite
    reflection
    reflection_reachability
    object_arrays
  ];
}
