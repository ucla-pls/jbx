{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "IntBfs01";
  mainclass = "IntBfs01";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/00_bfs/IntBfs01
      ant
      cd classes
      jar vcf IntBfs01.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv IntBfs01.jar $_
    '';
  };
}
