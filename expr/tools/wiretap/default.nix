{ stdenv, fetchgit, unzip, ant}:
let DEBUG = false; in
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "a018fa06735d20edd1963b7d2f55edb24ec5a752";
      sha256 = "1xra0na7jgflzyzdpafi9y6a2fc3dkdaz73ixsiw1n0lgd8dds1y";
      branchName = "develop";
    };
    buildInputs = [ unzip ant java.jdk ];
    phases = "unpackPhase patchPhase buildPhase installPhase";
    patches = if DEBUG then [ ./wiretap.diff ] else [];
    buildPhase = ''
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp build/wiretap.jar $out/share/java
    '';
  };
}
