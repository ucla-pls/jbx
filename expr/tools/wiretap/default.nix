{ stdenv, fetchgit, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "7ba81031b92fc7c9835b0116c1164da8cb3e81c2";
      sha256 = "1cvcjchfdh6gdgdv969f1lvpgy85157j5bvgnx5p7dhgd30dxgmw";
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
