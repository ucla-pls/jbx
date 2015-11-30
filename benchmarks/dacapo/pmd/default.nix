{ stdenv, fetchzip, ant, daCapoSrc}:
{ 
  name = "pmd";
  mainclass = "net.sourceforge.pmd.PMD";
  jarfile = "pmd-4.2.5.jar";
  build = java: rec {
    version = "4.2.5";
    src = fetchzip {
      # Same file different mirror
      url = ''http://skylineservers.dl.sourceforge.net/project/pmd/pmd/4.2.5/pmd-src-4.2.5.zip'';
      md5 = "de56d016ee0e901a743a7d57cc4df991";
    };
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildInputs = [ ant java.jdk ];
    buildPhase = ''
      ant jar
    '';
    inherit daCapoSrc;
    installPhase = ''
      mkdir -p $out/share/java
      mv lib/pmd-4.2.5.jar $_ 

      # Datafiles
      mv rulesets $out
      cp -r $daCapoSrc/benchmarks/bms/pmd/data/pmd $out
    '';
  };
  libraries = java: with java.libs; [ jaxen ];
  inputs = let 
    setup = "";
    in [
    { name = "xsmall";
      inherit setup;
      args = [ "$data/pmd/small.lst" 
               "xml" 
               "$data/rulesets/basic.xml" 
               "-debug"
             ];
      }
  ];
}
