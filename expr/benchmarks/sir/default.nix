{ utils }:
let
  base = utils.fetchprop {
    url = "sir.tar.gz";
    sha256 = "11yl8zv7wpkgl7khfj50djyx8829flwdk35g87y2l7xa6xy78zh5";
  };

  sirBenchmark =
    { name
    , mainclass
    , inputs ? [
      { name = "default"; args = []; }
    ]
    , folder ? null
    , tags ? []
    }:
    utils.mkBenchmarkTemplate {
      name = "sir-${name}";
      inherit mainclass inputs;
      build = java: {
        src = base;
        phases = "unpackPhase buildPhase installPhase";
        buildInputs = [ java.jdk ];
        unpackPhase = ''
          tar -xzf $src
          cd "sir/${if builtins.isNull folder then name else folder}"
        '';
        buildPhase = ''
          mkdir -p "$out/info" "$out/src" "$out/classes"
          for file in $(find versions.alt/ -name '*.java'); do
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
        '';
      };
    };
in rec {
  account = sirBenchmark {
    name = "account";
    mainclass = "Main";
  };

  airline = sirBenchmark {
    name = "airline";
    mainclass = "Main";
    inputs = [
      { name = "default"; args = ["10" "3"]; }
    ];
  };


  all = [
    account
    airline
  ];
}
