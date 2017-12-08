{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "52ab27c90eb0853fa4bdc057473115557e863909";
      sha256 = "1rhrrk462cjn6jmz3923h78a0pvlrp4mqm063dv7vlzb9d673d0p";
    };
    phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''ant jar'';
    patches = [ ./baseline.diff ];
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
  all = [
    transfer
<<<<<<< HEAD
    infinite
    reflection
    reflection_reachability
    object_arrays
    test
=======
    objectarrays
>>>>>>> Almost working doop
  ];
}
