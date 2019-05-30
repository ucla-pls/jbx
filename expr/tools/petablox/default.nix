{ stdenv, fetchurl, fetchgit, jdk8, ant}:
let 
  petabloxBldr = { 
    version
    , sha256 ? "0000000000000000000000000000000000000000000000000000000000000000"
  }: 
  stdenv.mkDerivation { 
    name = "petablox";
    version = version;
    src = fetchurl {
      url = "https://github.com/petablox-project/petablox/archive/${version}.tar.gz"; 
      inherit sha256;
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant jdk8 ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      mv petablox.jar $_
      cp -r lib $_
    '';
  };
  testPetablox = options@{
    rev,
    branchName ? "gt-develop",
    sha256 ? "0000000000000000000000000000000000000000000000000000000000000000",
    owner ? "petablox-project",
    patches ? []
  }:
  stdenv.mkDerivation {
    name = "petablox";
    version = "${branchName}-${rev}";
    src = fetchgit {
      url = "https://github.com/${owner}/petablox.git";
      inherit branchName sha256 rev;
      # deepClone = true;
    };
    phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant jdk8 ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      mv petablox.jar $_
      cp -r lib $_
    '';
    inherit patches;
  };
in {
  # petablox-0_1 = petabloxBldr {
  #   version = "v0.1";
  # };
  # petablox-1_0 = petabloxBldr {
  #   version = "v1.0";
  #   # md5 = "dc7164fac9051bbbac14c8c891c4b8b6";
  # };
  # petablox-old = testPetablox {
  #   # md5 = "d04713260148c7e7f05e95b039f28d38";
  #   rev = "0753f868485d032403e29393382895aeafb440a6";
  # };
  petablox-HEAD = testPetablox {
    # md5 = "1e73270e39af7ef2c79165ce2fe6fb3d";
    rev = "b95fd275fd30651b446dec9aff8fe5836614b6dc";
    sha256 = "1jdpkz77jybi6zaw162vhwl9f71xfghpxl7w15d0q1vgdcc8ayi6";
    branchName = "master";
    # patches = [ ./deadlock-fix.patch ];
  };
  # petablox-test = testPetablox {
  #   # md5 = "49304df10ef89179c1117cf9b5da4faa";
  #   sha256 = "1jdpkz77jybi6zaw162vhwl9f71xfghpxl7w15d0q1vgdcc8ayi6";
  #   rev = "058ffa2ebc9874e8a1664de640bbbac916bf9841";
  #   branchName = "develop";
  # };
}
