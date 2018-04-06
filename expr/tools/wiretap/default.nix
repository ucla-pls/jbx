{ stdenv, fetchgit, unzip, ant}:
let DEBUG = false; in
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "7add1d6d518c2f68e66cc71c6dbf72231ef8ae5e";
      sha256 = "02idfcr92vjfxvps2vjyn3az381rrcsql84a416qnpgzh092wxzi";
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
