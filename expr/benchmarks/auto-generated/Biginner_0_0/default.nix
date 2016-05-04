{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "Biginner_0_0";
  mainclass = "try1";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/08_text_messaging_outrage/Biginner_0_0
      ant
      cd classes
      jar vcf Biginner_0_0.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv Biginner_0_0.jar $_
    '';
  };
}
