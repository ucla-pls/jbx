{ jversion }:
pkgs @ { stdenv, fetchcvs, ant, cvs, ...}: 
let
  jdk = builtins.getAttr "jdk${jversion}" pkgs;
  jversion_ = jversion;
  # Reference implementation
  # build = stdenv.mkDerivation {
  #   name = "dacapo-avrora";
  #   src = daCapoSrc;
  #   builder = ./builder.sh;
  #   buildInputs = [ ant jdk7 cvs];
  # };
  # Like the build but without using the daCapoSrc, the pure build is
  # preferable because it is without harness and cache the downloads of
  # 'avrora', and hash checks it.
  pureBuild = stdenv.mkDerivation {
    name = "avrora";
    version = "beta-1.7.110";
    src = fetchcvs {
      cvsRoot = ":pserver:anonymous@avrora.cvs.sourceforge.net:/cvsroot/avrora";
      date = "20091224";
      module = "avrora";
      sha256 = "0kki6ab9gibyrfbx3dk0liwdp5dz8pzigwf164jfxhwq3w8smfxn";
    };
    buildInputs = [ ant jdk ];
    builder = ./pure-builder.sh;
  };
# Only allow acces to the pure build, as the other is broken
in rec {
  name = "avrora";
  build = pureBuild;
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
