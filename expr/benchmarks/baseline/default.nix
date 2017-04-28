{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "64e490bc454806b3466f4bdad29d84f5a7fe3276";
      md5 = "39894f1170b5384f6681b3caa83268cd";
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
  all = [
    transfer
    infinite
    reflection
  ];
}
