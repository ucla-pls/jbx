{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "aditsu_0_1";
  mainclass = "Decision";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/09_decision_tree/aditsu_0_1
      ant
      cd classes
      jar vcf aditsu_0_1.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv aditsu_0_1.jar $_
    '';
  };
}
