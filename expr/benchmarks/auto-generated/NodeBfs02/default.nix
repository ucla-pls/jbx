{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "NodeBfs02";
  mainclass = "NodeBfs02";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/00_bfs/NodeBfs02
      ant
      cd classes
      jar vcf NodeBfs02.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv NodeBfs02.jar $_
    '';
  };
}
