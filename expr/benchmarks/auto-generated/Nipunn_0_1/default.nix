{ fetchgit, utils, ant }:
{
  tags = [ "mini_corpus" ];
  name = "Nipunn_0_1";
  mainclass = "RPI";
  build = java: {
    version = "a983d6";
    src = fetchgit {
      url = "https://github.com/aas-integration/mini_corpus.git";
      md5 = "3b09245a1e28e430798fe4335ec5c5ba";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      cd benchmarks/11_rpi/Nipunn_0_1
      ant
      cd classes
      jar vcf Nipunn_0_1.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      mv Nipunn_0_1.jar $_
    '';
  };
}
