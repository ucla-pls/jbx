{ stdenv, daCapoSrc, fetchurl, unzip}:
rec {
  name = "luindex";
  mainclass = "org.dacapo.luindex.Index";
  build = java: {
    version = ".";
    phases = [ "buildPhase" "installPhase" ];
    buildInputs = [ java.jdk ] ++ libraries java;
    harness = ./Index.java;
    buildPhase = ''
      mkdir out
      cp $harness ./Index.java
      javac ./Index.java -d out
      cd out; jar vcf luindex.jar .
    '';
    installPhase = ''
      mkdir -p $out/share/java/
      cp luindex.jar $_
    '';
  };
  data = stdenv.mkDerivation {
    name = "luindex-data";
    phases = [ "installPhase" ];
    kjv = fetchurl {
      url = "http://dacapobench.sourceforge.net/source-data/kjv.zip";
      md5 = "a8f11555f138a3764447c89227350af7";
    };
    william = fetchurl {
      url = "http://dacapobench.sourceforge.net/source-data/shakespeare.tgz";
      md5 = "d9e012cb9c7f1509a1c5c59cf6e3a7e6";
    };
    buildInputs = [ unzip ];
    installPhase = ''
      mkdir -p $out/kjv $out/william
      cd $out/kjv; unzip $kjv
      cd $out/william; tar zxf $william
    '';
  };
  libraries = java: with java.libs; [ lucene-core lucene-demos ];
  inputs = [
    {
      name = "small";
      args = [ "$data/william/poetry" ];
    }
    {
      name = "default";
      args = [ "$data/william" "$data/kjv" ];
    }
  ];
}
