{ stdenv, fetchurl, jdk7, ant}:
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
in {
  petablox_0_1 = petabloxBldr {
    version = "v0.1";
  };
}
