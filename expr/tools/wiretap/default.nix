{ stdenv, fetchgit, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "63ce06f9e0b65b0f425d5723e3301d3c8aed759b";
      sha256 = "14xzfv03xddrfgjvpk7fqrissr6q9aa8ljmvc1azrz3wvvwf40dq";
      branchName = "develop";
    };
    buildInputs = [ unzip ant java.jdk ];
    phases = "unpackPhase buildPhase installPhase";
    buildPhase = ''
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp build/wiretap.jar $out/share/java
    '';
  };
}
