{fetchurl, ant, daCapoSrc}:
rec {
  name = "fop";
  version = "0.95";
  mainclass = "org.apache.fop.cli.Main";
  build = java: {
    src = fetchurl {
      url = ''http://archive.apache.org/dist/xmlgraphics/fop/source/fop-${version}-src.tar.gz'';
      md5 = "58593e6c86be17d7dc03c829630fd152";
      #packed = "fb1f6a7e996d44e417398e2f5067658b";
    };
    buildInputs = [ ant java.jdk ];
    buildPhase = "ant";
    installPhase = ''
      mkdir -p $out/share/java
      mv build/*.jar $_
    '';
  };
  tags = [ "reflection-free" ];
  data = daCapoSrc;
  libraries = java: with java.libs; [ xmlgraphics-commons batik-util ];
  inputs = let SCRATCH = "$data/benchmarks/bms/fop/data"; in [
    { name = "small";
      args = [ "-q" "${SCRATCH}/fop/readme.fo" "-pdf" "readme.pdf" ];
    }

    { name = "default";
      args = [ "-q" "${SCRATCH}/fop/test.fo" "-ps" "test.ps" ];
    }
    ];
}
