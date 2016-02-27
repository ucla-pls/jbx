{ stdenv, fetchurl, fetchgit, jdk7, ant}:
let 
  petabloxBldr = { 
    version
    , md5 ? "fc4f059eb3c804d7995457ebe2e90467"
  }: 
  stdenv.mkDerivation { 
    name = "petablox";
    version = version;
    src = fetchurl {
      url = "https://github.com/petablox-project/petablox/archive/${version}.tar.gz"; 
      inherit md5;
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant jdk7 ];
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
    md5 ? "ba3d91bd803350a3879d229549042fcd",
    owner ? "petablox-project"
  }:
  stdenv.mkDerivation { 
    name = "petablox";
    version = "${branchName}-${rev}";
    src = fetchgit {
      url = "https://github.com/${owner}/petablox.git";
      inherit branchName md5 rev;
      # deepClone = true;
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant jdk7 ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      mv petablox.jar $_
      cp -r lib $_
    '';
  };
in {
  petablox-0_1 = petabloxBldr {
    version = "v0.1";
  };
  petablox-1_0 = petabloxBldr {
    version = "v1.0";
    md5 = "dc7164fac9051bbbac14c8c891c4b8b6";
  };
  petablox-old = testPetablox {
    md5 = "d04713260148c7e7f05e95b039f28d38";
    rev = "0753f868485d032403e29393382895aeafb440a6";
  };
  petablox-test2 = testPetablox {
    md5 = "12c8d0e37d6f763d901f72f59b2b5954";
    rev = "95b357a57cba3f4976a0e6e3350fe052e7db15b0";
    branchName = "ucla-develop";
  };
  petablox-test = testPetablox {
    md5 = "b48dd84a7e9c50a8ecf4065b7d9e35aa";
    rev = "3d40f23f286acdb32dc65aaee593023fab85664d";
    branchName = "gt-develop";
  };
}
