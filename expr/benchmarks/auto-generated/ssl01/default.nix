{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "ssl01";
  mainclass = "Ssl01";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/01_ssl/ssl01
      ant
      cd classes
      jar vcf ssl01.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv ssl01.jar $_
    '';
  };
}
