pkgs @ { stdenv, fetchcvs, ant, cvs, ...}: 
jversion:
let
  jdk = builtins.getAttr "jdk${toString jversion}" pkgs;
  jversion_ = jversion;
in rec {
  name = "avrora_${toString jversion}"; # Remember uniqnes
  build = stdenv.mkDerivation {
    name = "avrora";
    version = "beta-1.7.110";
    src = fetchcvs {
      cvsRoot = ":pserver:anonymous@avrora.cvs.sourceforge.net:/cvsroot/avrora";
      date = "20091224";
      module = "avrora";
      sha256 = "0kki6ab9gibyrfbx3dk0liwdp5dz8pzigwf164jfxhwq3w8smfxn";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant jdk ];
    builder = ./pure-builder.sh;
  };
  jarfile = "avrora-beta-1.7.110.jar";
  mainclass = "avrora.Main";
  jversion = jversion_;
  inputs = [
    # test taken directly from 
    {
      name = "small";
      args = [
          "-seconds=30"
          "-platform=mica2"
          "-simulation=sensor-network"
          "-nodecount=2,1"
          "-stagger-start=1000000"
          "${build}/test/tinyos/CntToRfm.elf"
          "${build}/test/tinyos/RfmToLeds.elf"
      ];
    }
    {
      name = "default";
      args = [
        "-seconds=30"
	"-platform=mica2"
	"-simulation=sensor-network"
	"-nodecount=4,2"
	"-stagger-start=1000000"
	"${build}/test/tinyos/CntToRfm.elf"
	"${build}/test/tinyos/RfmToLeds.elf"  
      ];
    }
    {
      name = "large";
      args = [
        "-seconds=30"
	"-platform=mica2"
	"-simulation=sensor-network"
	"-nodecount=7,3,7,2"
	"-stagger-start=1000000"
	"${build}/test/tinyos/CntToRfm.elf"
	"${build}/test/tinyos/RfmToLeds.elf"
	"${build}/test/tinyos/Surge.elf"
	"${build}/test/tinyos/Blink_mica2.elf"
	"${build}/test/tinyos/XnpOscopeRF.elf"
	"${build}/test/tinyos/OscilloscopeRF.elf"
	"${build}/test/tinyos/HighFrequencySampling.elf"
	"${build}/test/tinyos/SenseToLeds.elf"
	"${build}/test/tinyos/XnpRfmToLeds.elf"
	"${build}/test/tinyos/RadioSenseToLeds_mica2.elf"
	"${build}/test/tinyos/SecureTOSBase.elf"
      ];
    }
  ];
}
