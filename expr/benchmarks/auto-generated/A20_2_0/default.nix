{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "A20_2_0";
  mainclass = "CodeJam";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/10_your_rank_is_pure/A20_2_0
      ant
      cd classes
      jar vcf A20_2_0.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv A20_2_0.jar $_
    '';
  };
}
