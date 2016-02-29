{ fetchgit, utils, ant}:
let 
  baseline = java: {
    name = "baseline";
    src = fetchgit {
      url = "https://bitbucket.org/ucla-pls/baseline.git";
      branchName = "master";
      rev = "1ec19179278f2763560c47ff44cf6654172bb193";
      md5 = "dd70e3be87c9a057b01a2e932576465d";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''ant jar'';
    installPhase = ''
      utils -p $out/share/java/
      mv build/baseline.jar $_
    '';
  };
in rec {
  transfer = utils.mkBenchmarkTemplate {
    name = "transfer";
    build = baseline;
    mainclass = "edu.ucla.pls.baseline.Transfer";
    inputs = [ ];
  };
  all = [
    transfer
  ];
}
