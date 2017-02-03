{ utils, unzip, cpio }:
let
  base = utils.fetchprop {
    url = "JaConTeBe_1.0.tar.gz";
    sha256 = "09xfm3j8jj6q55h0arlfd7girbykbk1ff576zzkfvjm3739qbd7i";
  };

  jaConTeBenchmark =
    { name
    , mainclass ? "Main"
    , inputs ? [
      { name = "default"; args = ["--monitoroff"]; }
    ]
    , tags ? []
    , libs ? null
    }:
    utils.mkBenchmarkTemplate {
      name = "JaConTeBe-${name}";
      tags = tags ++ ["JaConTeBe"];
      inherit mainclass inputs;
      build = java: {
        src = base;
        phases = "unpackPhase buildPhase installPhase";
        buildInputs = [ java.jdk unzip cpio];
        patches = [ ./derby4.patch ];
        unpackPhase = ''
          tar -xzf $src
          cd "JaConTeBe/"
        '';
        libnames = libs;
        buildPhase = ''
          mkdir -p "$out/info" "$out/src" "$out/classes" "$out/lib"

          for lib in $libnames; do
            path="./versions.alt/lib/realLib/$lib.jar"
            echo "Copying over classpath $path..."
            if [[ $path == *.jar ]]; then
                mkdir _out
                unzip -qq -o "$path" -d _out
                path=_out
            fi
            (cd "$path";
            find . -name "*.class" | sort | cpio --quiet -updm $out/lib)
            if [[ -e _out ]]; then rm -r _out; fi
          done

          # for path in $(find ./versions.alt/lib/realLib -name "*.jar"); do
          #     echo "Copying over classpath $path..."
          #     if [[ $path == *.jar ]]; then
          #         mkdir _out
          #         unzip -qq -o "$path" -d _out
          #         path=_out
          #     fi
          #     (cd "$path";
          #     find . -name "*.class" | sort | cpio --quiet -updm $out/lib)
          #     if [[ -e _out ]]; then rm -r _out; fi
          # done

          path=versions.alt/lib/${name}.jar
          if [ -e $path ]; then
            echo "Copying over classpath $path..."
            if [[ $path == *.jar ]]; then
                mkdir _out
                unzip -qq -o "$path" -d _out
                path=_out
            fi
            (cd "$path";
            find . -name "*.class" | sort | cpio --quiet -updm $out/lib)
            if [[ -e _out ]]; then rm -r _out; fi
          fi

          srcfolder=versions.alt/${name}/orig/
          for file in $(find $srcfolder -name '*.java'); do
              path=$(sed -n '
                /^[[:space:]]*package [[:space:][:alnum:].].*;/{
                  s/.*package//g
                  s/[[:space:]]//g
                  s/;.*//
                  s/\./\//g
                  p
                  q
                }' $file)
              mkdir -p "$out/src/$path"
              cp "$file" "$out/src/$path"
          done
          cd $out

          find src -name '*.java' | sort > info/sources

          cat info/sources

          javac -encoding UTF-8 -cp classes:lib -d classes @info/sources

          classes=$(find classes -name "*.class" | sed 's/.class//;s/\//./g;s/classes.//' | sort );
          echo "$classes" | sed "s/ /\n/g" > info/classes
          javap -classpath classes $classes > info/declarations

          # Finding mainclasses
          sed -e '/.*public static .*void main(java.lang.String\[\])/{g;p;}' \
              -e 's/.*class \([[:alnum:].]*\).*/\1/;T;h' \
              -n info/declarations > info/mainclasses

        '';
        installPhase = ''
          mkdir -p $out/share/java
          jar cf $_/$name.jar -C classes .
          jar uf $out/share/java/$name.jar -C lib .
        '';
      };
    };
in rec {

  dbcp1 = jaConTeBenchmark {
    name = "dbcp1";
    mainclass = "Dbcp65";
    tags = ["deadlock" "singlelock"];
    libs = ["commons-dbcp-1.2" "commons-pool-1.2"  "mockito-all-1.9.5" "coring-1.4" "jacontebe-1.0" "commons-collections-2.1"];
  };

  dbcp2 = jaConTeBenchmark {
    name = "dbcp2";
    mainclass = "Dbcp270";
    tags = ["deadlock" "singlelock"];
    libs = ["commons-dbcp-1.2" "commons-pool-1.2"  "mockito-all-1.9.5" "coring-1.4" "jacontebe-1.0" "commons-collections-2.1"];
  };

  derby1 = jaConTeBenchmark {
    name = "derby1";
    mainclass = "Derby4129";
    tags = ["deadlock" "singlelock"];
    libs = ["asm-all-5.0.3" "coring-1.4" "jacontebe-1.0" "derby"];
  };

  derby2 = jaConTeBenchmark {
    name = "derby2";
    mainclass = "Derby5560";
    tags = ["deadlock" "singlelock"];
    libs = ["asm-all-5.0.3" "coring-1.4" "jacontebe-1.0" "derby" "derbyclient" "mockito-all-1.9.5"];
  };

  derby4 = jaConTeBenchmark {
    name = "derby4";
    mainclass = "org.junit.runner.JUnitCore";
    inputs = [
      { name = "default";
        args = ["org.apache.derby.impl.services.reflect.Derby764"];
      }
    ];
    tags = ["deadlock" "singlelock"];
    libs = ["coring-1.4" "jacontebe-1.0" "derby" "mockito-all-1.9.5" "asm-all-5.0.3" "javassist-3.18.1-GA" "junit4.11" "powermock-mockito-1.5.3-full"];
  };

  derby5 = jaConTeBenchmark {
    name = "derby5";
    mainclass = "org.apache.derby.impl.store.raw.data.Derby5447";
    tags = ["deadlock" "singlelock"];
    libs = ["coring-1.4" "jacontebe-1.0" "derby" "mockito-all-1.9.5" "asm-all-5.0.3"];
  };

  groovy2 = jaConTeBenchmark {
    name = "groovy2";
    mainclass = "Groovy4736";
    tags = ["deadlock" "singlelock"];
    libs = ["coring-1.4" "jacontebe-1.0" "groovy-all-1.7.9"];
  };

  log4j2 = jaConTeBenchmark {
    name = "log4j2";
    mainclass = "com.main.Test41214";
    tags = ["deadlock" "singlelock"];
    libs = ["coring-1.4" "jacontebe-1.0" "log4j-1.2.13"];
  };

  all = [
    dbcp1
    dbcp2
    derby1
    derby2
    derby4
    derby5
    groovy2
    log4j2
  ];

}
