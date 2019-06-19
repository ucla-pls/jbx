{ stdenv, fetchgit, unzip, ant, pkgs, makeWrapper, haskellPackages }:
let DEBUG = false; in
rec {
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchgit {
      url = "https://github.com/ucla-pls/wiretap.git";
      rev = "ae63db40b8ad2dec7d18bc2da99ee646e5133a54";
      sha256 = "1wxn61p74gzwxj9gjmxanh62sk84jzbpfyrfnsbfhhzh82v4z1kr";
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
    rev = "11d0045b3416e8be093f1bc35fc1e6f36657d2eb";
    sha256 = "0smshvrx32bpf412lf2x5l8kvadcvymjqn8zg6qr4ficz76173y7";
    branchName = "master";
  };

  wiretap-pointsto = haskellPackages.callPackage ./wiretap-pointsto.nix 
    { src = wiretap-pointsto-src; };
}
