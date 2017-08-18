{ stdenv, fetchgit, unzip, ant}:
let DEBUG = false; in
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "c71293a3606e17789424aee59d5f48486fc8ff1b";
      sha256 = "1c45038g7f4rm9v4sb0i7lhpnrqshmbcln3manlr59znw2lx7x28";
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
