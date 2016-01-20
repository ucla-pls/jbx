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
  petablox-test = testPetablox {
    md5 = "d04713260148c7e7f05e95b039f28d38";
    rev = "0753f868485d032403e29393382895aeafb440a6";
  };
}
