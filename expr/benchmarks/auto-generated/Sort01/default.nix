{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "Sort01";
  mainclass = "Sort01";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd sorting/00_sort/Sort01
      ant
      cd classes
      jar vcf Sort01.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv Sort01.jar $_
    '';
  };
}
