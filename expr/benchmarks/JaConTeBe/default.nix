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
    }:
    utils.mkBenchmarkTemplate {
      name = "JaConTeBe-${name}";
      inherit mainclass inputs tags;
      build = java: {
        src = base;
        phases = "unpackPhase buildPhase installPhase";
        buildInputs = [ java.jdk unzip cpio];
        unpackPhase = ''
          tar -xzf $src
          cd "JaConTeBe/"
        '';
        buildPhase = ''
          mkdir -p "$out/info" "$out/src" "$out/classes" "$out/lib"

          for path in $(find ./versions.alt/lib/realLib -name "*.jar"); do
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
    tags = ["deadlock"];
  };

  dbcp2 = jaConTeBenchmark {
    name = "dbcp2";
    mainclass = "Dbcp270";
    tags = ["deadlock"];
  };

  derby1 = jaConTeBenchmark {
    name = "derby1";
    mainclass = "Derby4129";
    tags = ["deadlock"];
  };

  derby2 = jaConTeBenchmark {
    name = "derby2";
    mainclass = "Derby5560";
    tags = ["deadlock"];
  };

  derby4 = jaConTeBenchmark {
    name = "derby4";
    mainclass = "org.junit.runner.JUnitCore";
    inputs = [
      { name = "default";
        args = ["org.apache.derby.impl.services.reflect.Derby764"];
      }
    ];
    tags = ["deadlock"];
  };

  derby5 = jaConTeBenchmark {
    name = "derby5";
    mainclass = "org.apache.derby.impl.store.raw.data.Derby5447";
    tags = ["deadlock"];
  };

  groovy2 = jaConTeBenchmark {
    name = "groovy2";
    mainclass = "Groovy4736";
    tags = ["deadlock"];
  };

  log4j2 = jaConTeBenchmark {
    name = "log4j2";
    mainclass = "com.main.Test41214";
    tags = ["deadlock"];
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
