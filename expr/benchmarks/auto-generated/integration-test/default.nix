{ fetchgit, utils, ant, cpio }:
let
  bm = { name, main, builddir, srcdir, destdir }: utils.mkBenchmarkTemplate {
    tags = [ "integration-test" ];
    name = name;
    mainclass = main;
    build = java: {
      src = fetchgit {
        url = "https://github.com/aas-integration/integration-test.git";
        branchName = "master";
        rev = "416dbb44128130ab1f3ac83e0eb80f57e70ef53b";
        md5 = "6d5c661385ab9cab6eeda7c1ebedd1ab";
      };
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      buildInputs = [ ant java.jdk cpio ];
      buildPhase = ''
        cd ${builddir}
        ant
        cd ${destdir}
        jar vcf ${name}.jar .
      '';
      installPhase = ''
        mkdir -p $out/share/java/
        mv ${name}.jar $_
        cd ../${srcdir}
        mkdir -p $out/src/
        find . -name '*.java' | cpio -pdm $out/src
      '';
    };
  };
in rec {
  Sort02 = bm {
    name = "Sort02";
    main = "Sort02";
    builddir = "corpus/Sort02";
    destdir = "classes";
    srcdir = "src";
  };

  Sort05 = bm {
    name = "Sort05";
    main = "Sort05";
    builddir = "corpus/Sort05";
    destdir = "classes";
    srcdir = "src";
  };

  Sort11 = bm {
    name = "Sort11";
    main = "Sort11";
    builddir = "corpus/Sort11";
    destdir = "classes";
    srcdir = "src";
  };

  Sort16 = bm {
    name = "Sort16";
    main = "Sort16";
    builddir = "corpus/Sort16";
    destdir = "classes";
    srcdir = "src";
  };

  Sort06 = bm {
    name = "Sort06";
    main = "Sort06";
    builddir = "corpus/Sort06";
    destdir = "classes";
    srcdir = "src";
  };

  Sort01 = bm {
    name = "Sort01";
    main = "Sort01";
    builddir = "corpus/Sort01";
    destdir = "classes";
    srcdir = "src";
  };

  Sort04 = bm {
    name = "Sort04";
    main = "Sort04";
    builddir = "corpus/Sort04";
    destdir = "classes";
    srcdir = "src";
  };

  Sort13 = bm {
    name = "Sort13";
    main = "Sort13";
    builddir = "corpus/Sort13";
    destdir = "classes";
    srcdir = "src";
  };

  Sort14 = bm {
    name = "Sort14";
    main = "Sort14";
    builddir = "corpus/Sort14";
    destdir = "classes";
    srcdir = "src";
  };

  Sort15 = bm {
    name = "Sort15";
    main = "Sort15";
    builddir = "corpus/Sort15";
    destdir = "classes";
    srcdir = "src";
  };

  Sort12 = bm {
    name = "Sort12";
    main = "Sort12";
    builddir = "corpus/Sort12";
    destdir = "classes";
    srcdir = "src";
  };

  Sort07 = bm {
    name = "Sort07";
    main = "Sort07";
    builddir = "corpus/Sort07";
    destdir = "classes";
    srcdir = "src";
  };

  Sort08 = bm {
    name = "Sort08";
    main = "Sort08";
    builddir = "corpus/Sort08";
    destdir = "classes";
    srcdir = "src";
  };

  Sort10 = bm {
    name = "Sort10";
    main = "Sort10";
    builddir = "corpus/Sort10";
    destdir = "classes";
    srcdir = "src";
  };

  Sort09 = bm {
    name = "Sort09";
    main = "Sort09";
    builddir = "corpus/Sort09";
    destdir = "classes";
    srcdir = "src";
  };

  Sort03 = bm {
    name = "Sort03";
    main = "Sort03";
    builddir = "corpus/Sort03";
    destdir = "classes";
    srcdir = "src";
  };


  all = [
    Sort02
    Sort05
    Sort11
    Sort16
    Sort06
    Sort01
    Sort04
    Sort13
    Sort14
    Sort15
    Sort12
    Sort07
    Sort08
    Sort10
    Sort09
    Sort03
  ];
}
