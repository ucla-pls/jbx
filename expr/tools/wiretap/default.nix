{ stdenv, fetchgit, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "eb60ed0abade59c882df879185a92336e63f32fb";
      sha256 = "0gq2bk7gxpf2psb75g2yb7hgyhkqi0cwrz8f95w910cbkav2lahz";
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
