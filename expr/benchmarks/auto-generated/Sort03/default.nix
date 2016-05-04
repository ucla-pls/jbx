{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "Sort03";
  mainclass = "Sort02";
  build = java: {
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      rev = "14ec94d8d9808905a21fd839e5bdd2cb8248a11c";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd sorting/00_sort/Sort03
      ant
      cd classes
      jar vcf Sort03.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv Sort03.jar $_
    '';
  };
}
