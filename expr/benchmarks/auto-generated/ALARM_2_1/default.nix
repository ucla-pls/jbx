{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "ALARM_2_1";
  mainclass = "Main";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/10_your_rank_is_pure/ALARM_2_1
      ant
      cd classes
      jar vcf ALARM_2_1.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv ALARM_2_1.jar $_
    '';
  };
}
