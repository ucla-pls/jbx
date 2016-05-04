{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "NodeBfs01";
  mainclass = "NodeBfs01";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/00_bfs/NodeBfs01
      ant
      cd classes
      jar vcf NodeBfs01.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv NodeBfs01.jar $_
    '';
  };
}
