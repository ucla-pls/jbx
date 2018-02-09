{ stdenv, fetchgit, unzip, ant}:
let DEBUG = false; in
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "226dfd443e0adcafb195af23da1fbc2ed84fa133";
      sha256 = "1vq1ill3jywm5rxiryavrv7ia5257pjmnny9cgg7spc74qzbrcvc";
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
