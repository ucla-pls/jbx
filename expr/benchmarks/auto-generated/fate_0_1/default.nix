{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "fate_0_1";
  mainclass = "problem1";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/08_text_messaging_outrage/fate_0_1
      ant
      cd classes
      jar vcf fate_0_1.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv fate_0_1.jar $_
    '';
  };
}
