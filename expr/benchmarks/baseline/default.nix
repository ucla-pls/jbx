{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "f67a777cd5e7363f6e30433bb1d2d99bb88267a8";
      md5 = "9cd643999fd854626ce0b6b1b0a609ae";
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
  all = [
    transfer
    infinite
    reflection
    reflection_reachability
  ];
}
