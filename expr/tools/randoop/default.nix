# Randoop.
{ stdenv, fetchurl, unzip}:
let
  randoopBldr = 
  { version
  , md5 ? "00000000000000000000000000000000" 
  }:
  stdenv.mkDerivation {
    name = "randoop";
    inherit version;
    src = fetchurl {
      url = "https://github.com/randoop/randoop/releases/download/v${version}/randoop-${version}.zip";
      inherit md5;
    };
    phases = "installPhase";
    buildInputs = [ unzip ];
    installPhase = ''
      unzip $src
      cd randoop
      mkdir -p $out/share/java
      cp randoop.jar exercised_agent.jar mapcall_agent.jar $_
    '';
  };
in 
{
  randoop-2_1_4 = randoopBldr {
    version = "2.1.4";
    md5 = "9445dceb07b1c52d033c426cb266ad5e";
  };
}
