{ stdenv, fetchgit, unzip, ant, pkgs, makeWrapper, haskellPackages }:
let DEBUG = false; in
rec {
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "16df2a4ff8ab367bd58ea9d66fe4673c945e818a";
      sha256 = "1ybx0arn7rsjx7c98cfzb3wkxi867h67w5gj9hhk2xracvldjlsk";
      branchName = "develop";
    };
    buildInputs = [ unzip ant java.jdk makeWrapper];
    phases = "unpackPhase patchPhase buildPhase installPhase";
    patches = if DEBUG then [ ./wiretap.diff ] else [];
    buildPhase = ''
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp build/wiretap.jar $out/share/java
      makeWrapper ${java.jdk}/bin/java $out/bin/wiretap \
        --add-flags -noverify \
        --add-flags -javaagent:$out/share/java/wiretap.jar
    '';
  };

  wiretap-pointsto-src = fetchgit {
    url = "https://github.com/ucla-pls/wiretap-pointsto.git";
    rev = "2905815e3a2e7c7bbbd7809c73726db7d4dc3250";
    sha256 = "1161ynk88al01cwww7swsy1kvj0gc50z839mzkzah7pc5xq44282";
    branchName = "master";
  };

  wiretap-pointsto = haskellPackages.callPackage ./wiretap-pointsto.nix 
    { src = wiretap-pointsto-src; };
}
