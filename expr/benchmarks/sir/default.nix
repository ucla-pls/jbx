{ utils, unzip, cpio }:
let
  base = utils.fetchprop {
    url = "sir.tar.gz";
    sha256 = "11lgsy6lbw1vh4kxbrkj22q1fx3h6x59i32cx43max9664k7rbsr";
  };

  sirBenchmark =
    { name
    , mainclass ? "Main"
    , inputs ? [
      { name = "default"; args = []; }
    ]
    , folder ? null
    , srcfolder ? "versions.alt/"
    , tags ? []
    }:
    utils.mkBenchmarkTemplate {
      name = "sir-${name}";
      inherit mainclass inputs;
      build = java: {
        src = base;
        phases = "unpackPhase buildPhase installPhase";
        buildInputs = [ java.jdk unzip cpio];
        srcfolder = srcfolder;
        unpackPhase = ''
          tar -xzf $src
          cd "sir/${if builtins.isNull folder then name else folder}"
        '';
        buildPhase = ''
          mkdir -p "$out/info" "$out/src" "$out/classes" "$out/lib"

          if [ -e ./lib ]; then
            for path in $(find ./lib -name "*.jar"); do
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
          fi

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
        '';
      };
    };
in rec {
  account = sirBenchmark {
    name = "account";
    mainclass = "Main";
    tags = ["deadlock"];
  };

  accountsubtype = sirBenchmark {
    name = "accountsubtype";
    mainclass = "Main";
    tags = ["deadlock"];
  };

  airline = sirBenchmark {
    name = "airline";
    mainclass = "Main";
    inputs = [
      { name = "default"; args = ["10" "3"]; }
    ];
  };

  alarmclock = sirBenchmark {
    name = "alarmclock";
    mainclass = "AlarmClock";
  };

  boundedBuffer = sirBenchmark {
    name = "boundedBuffer";
    mainclass = "BoundedBuffer";
    inputs = [
      { name = "default";
        args = ["1" "4" "4" "2"];
      }
    ];
    tags = ["deadlock"];
  };

  clean = sirBenchmark {
    name = "clean";
    mainclass = "Main";
    inputs = [
      { name = "default";
        args = ["1" "1" "12"];
      }
    ];
    tags = ["deadlock"];
  };

  deadlock = sirBenchmark {
    name = "deadlock";
    mainclass = "Deadlock";
    tags = ["deadlock"];
  };

  diningPhilosophers = sirBenchmark {
    name = "diningPhilosophers";
    mainclass = "DiningPhilosophers";
    tags = ["deadlock"];
  };

  groovy = sirBenchmark {
    name = "groovy";
    srcfolder = "versions.alt/fixed";
    tags = ["deadlock"];
  };

  log4j1-fixed = sirBenchmark {
    name = "log4j1-fixed";
    folder = "log4j1";
    srcfolder = "versions.alt/fixed";
    mainclass = "org.apache.log4j.test.UnitTestAppender";
    tags = ["deadlock"];
  };

  log4j1-orig = sirBenchmark {
    name = "log4j1-orig";
    folder = "log4j1";
    srcfolder = "versions.alt/orig";
    mainclass = "org.apache.log4j.test.UnitTestAppender";
    tags = ["deadlock"];
  };

  loseNotify = sirBenchmark {
    name = "loseNotify";
    tags = ["deadlock"];
    inputs = [
      { name = "default";
        args = ["1" "1" "12"];
      }
    ];
  };

  nestedmonitor = sirBenchmark {
    name = "nestedmonitor";
    tags = ["deadlock"];
    srcfolder = "versions.alt/orig";
    mainclass = "NestedMonitor";
  };

  piper = sirBenchmark {
    name = "piper";
    tags = ["deadlock"];
    mainclass = "IBM_Airlines";
    inputs = [
      { name = "default";
        args = ["1" "32" "2"];
      }
    ];
  };

  pool4 = sirBenchmark {
    name = "pool4";
    mainclass = "org.apache.commons.pool.impl.TestGenericObjectPool";
    tags = ["deadlock"];
  };

  pool5 = sirBenchmark {
    name = "pool5";
    mainclass = "org.apache.commons.pool.impl.TestGenericObjectPool";
    tags = ["deadlock"];
  };

  pool6 = sirBenchmark {
    name = "pool6";
    mainclass = "org.apache.commons.pool.impl.TestGenericObjectPool";
    tags = ["deadlock"];
  };

  readerswriters = sirBenchmark {
    name = "readerswriters";
    mainclass = "RWVSNDriver";
    tags = ["deadlock"];
    inputs = [
      { name = "default";
        args = ["2" "2" "100"];
      }
    ];
  };

  replicatedworkers = sirBenchmark {
    name = "replicatedworkers";
    tags = ["deadlock"];
    mainclass = "apps.AdaptiveQuadrature.Main";
    inputs = [
      { name = "default";
        args = ["5" "2" "0" "10" "0.05"];
      }
    ];
  };

  sleepingBarber = sirBenchmark {
    name = "sleepingBarber";
    tags = ["deadlock"];
    mainclass = "SleepingBarber";
  };

  all = [
    account
    accountsubtype
    airline
    alarmclock
    boundedBuffer
    clean
    deadlock
    diningPhilosophers
    groovy
    log4j1-orig
    log4j1-fixed
    loseNotify
    nestedmonitor
    piper
    pool4
    pool5
    pool6
    readerswriters
    replicatedworkers
    sleepingBarber
  ];
}
