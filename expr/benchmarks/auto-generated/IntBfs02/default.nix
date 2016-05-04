{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "IntBfs02";
  mainclass = "IntBfs02";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/00_bfs/IntBfs02
      ant
      cd classes
      jar vcf IntBfs02.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv IntBfs02.jar $_
    '';
  };
}
