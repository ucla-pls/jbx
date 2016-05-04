{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "ssl05";
  mainclass = "Ssl05";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/01_ssl/ssl05
      ant
      cd classes
      jar vcf ssl05.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv ssl05.jar $_
    '';
  };
}
