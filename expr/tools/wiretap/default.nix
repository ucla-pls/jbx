{ stdenv, fetchgit, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "1c72381ce55f3ef3a62c666c902f43e427494e86";
      sha256 = "10xwk1s94pb43dab6zhimr4l1plf7y3y66pfvbdgk3crzqya6ms0";
      branchName = "develop";
    };
    buildInputs = [ unzip ant java.jdk ];
    phases = "unpackPhase patchPhase buildPhase installPhase";
    buildPhase = ''
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp build/wiretap.jar $out/share/java
    '';
    patches = [ ./fix.patch ];
  };
}
