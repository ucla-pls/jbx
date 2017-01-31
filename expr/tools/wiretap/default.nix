{ stdenv, fetchgit, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "30cb2cf9a2268d4b48cc23cd3e493b5f51ff4ad9";
      sha256 = "1ir1ng5d0wx2i6iz7v4vrlk73b7ghlxys4z3yqc01bfzxwvf7raw";
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
