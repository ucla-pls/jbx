{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://github.com/ucla-pls/baseline.git";
      branchName = "master";
      rev = "2ef679e9eb6e551b53c0c4b184b86444e01024c9";
      md5 = "bb18e512f7db5bad8d5dad8dd843d1e1";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''ant jar'';
    installPhase = ''
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
      { name = "one";
        args = [];
      }
    ];
  };
  all = [
    transfer
  ];
}
