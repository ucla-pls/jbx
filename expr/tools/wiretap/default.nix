{ stdenv, fetchgit, unzip, ant}:
let DEBUG = false; in
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "401ca16c37861d06a7a23629057b8d3fefa15691";
      sha256 = "0w120k5dcd6ihisr9q4zddbgvrq3llk3gp33x8nvnfdkn59c3njz";
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
