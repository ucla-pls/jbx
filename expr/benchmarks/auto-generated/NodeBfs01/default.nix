{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "NodeBfs01";
  mainclass = "NodeBfs01";
  build = java: {
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      rev = "14ec94d8d9808905a21fd839e5bdd2cb8248a11c";
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
