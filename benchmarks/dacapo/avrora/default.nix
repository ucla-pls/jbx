{fetchcvs, ant, cvs, mkBenchmark}:
mkBenchmark {
  name = "avrora";
  jarfile = "avrora-beta-1.7.110.jar";
  mainclass = "avrora.Main";
  build = java: {
    version = "beta-1.7.110";
    src = fetchcvs {
      cvsRoot = ":pserver:anonymous@avrora.cvs.sourceforge.net:/cvsroot/avrora";
      date = "20091224";
      module = "avrora";
      sha256 = "0kki6ab9gibyrfbx3dk0liwdp5dz8pzigwf164jfxhwq3w8smfxn";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    builder = ./pure-builder.sh;
  };
  inputs = [
    # test taken directly from dacapo
    {
      name = "small";
      args = [
          "-seconds=30"
          "-platform=mica2"
          "-simulation=sensor-network"
          "-nodecount=2,1"
          "-stagger-start=1000000"
          "$data/test/tinyos/CntToRfm.elf"
          "$data/test/tinyos/RfmToLeds.elf"
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
        "$data/test/tinyos/CntToRfm.elf"
        "$data/test/tinyos/RfmToLeds.elf"  
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
        "$data/test/tinyos/CntToRfm.elf"
        "$data/test/tinyos/RfmToLeds.elf"
        "$data/test/tinyos/Surge.elf"
        "$data/test/tinyos/Blink_mica2.elf"
        "$data/test/tinyos/XnpOscopeRF.elf"
        "$data/test/tinyos/OscilloscopeRF.elf"
        "$data/test/tinyos/HighFrequencySampling.elf"
        "$data/test/tinyos/SenseToLeds.elf"
        "$data/test/tinyos/XnpRfmToLeds.elf"
        "$data/test/tinyos/RadioSenseToLeds_mica2.elf"
        "$data/test/tinyos/SecureTOSBase.elf"
      ];
    }
  ];
}
