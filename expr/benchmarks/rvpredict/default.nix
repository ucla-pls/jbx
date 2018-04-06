{ utils, cpio }:
let 
  base = utils.fetchprop {
    url = "rvpredict-benchmarks.tar.gz";
    sha256 = "0hnclhgwl64i24g3n8xcp8i2x9msmriqdapq8fcpmi64nh5dyjnw";
  };

  rvp = 
    { name
    , mainclass ? "Main"
    , inputs ? [ { name = "default"; args = [];} ]
    , tags ? []
    }: 
    utils.mkBenchmarkTemplate {
      name = "rvpredict-${name}";
      tags = tags ++ ["rvpredict"];
      inherit mainclass inputs;
      build = java: {
        src = base;
        phases = "unpackPhase patchPhase buildPhase installPhase";
        buildInputs = [ java.jdk cpio ];
        # patches = [ ./JGFTimer.patch ];	
        buildPhase = ''
          mkdir -p "$out/info" "$out/classes" "$out/lib"
          cp -r "." "$out/src"
	  cd $out

	  substituteInPlace src/benchmarks/montecarlo/CallAppDemo.java \
            --replace "hitData" "${./hitData}"
          
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
          jar cf $_/rvpredict-benchmark.jar -C classes .
          jar uf $out/share/java/rvpredict-benchmark.jar -C lib .
        '';
      };
    };
in rec {
  bufwriter = rvp { name = "bufwriter"; mainclass = "bufwriter.BufWriter";};
  account = rvp { name = "account"; mainclass = "account.Account";};
  airlinetickets = rvp { name = "airline"; mainclass = "airlinetickets.Airlinetickets ";};
  array = rvp { name = "array"; mainclass = "array.Test ";};
  bubblesort = rvp { name = "bubblesort"; mainclass = "bubblesort.BubbleSort";};
  boundedbuffer = rvp { name = "bbuffer"; mainclass = "boundedbuffer.BoundedBuffer";};
  mergesort = rvp { name = "mergesort"; mainclass = "mergesort.MergeSort";};
  pingpong = rvp { name = "pingpong"; mainclass = "pingpong.PingPong";};
  critical = rvp { name = "critical"; mainclass = "critical.Critical";};

  JGFMolDynBenchSizeA = rvp { name = "moldyn"; mainclass = "benchmarks.JGFMolDynBenchSizeA";};
  JGFMonteCarloBenchSizeA = rvp { name = "montecarlo"; mainclass = "benchmarks.JGFMonteCarloBenchSizeA";};
  JGFRayTracerBenchSizeA = rvp { name = "raytracer"; mainclass = "benchmarks.JGFRayTracerBenchSizeA";};

  small = [
    array 
    critical 
    airlinetickets 
    account
    pingpong 
    boundedbuffer 
    bubblesort 
    bufwriter 
    mergesort 
  ];

  smaller = [
    #bufwriter 
    account 
    airlinetickets 
    array 
    #boundedbuffer 
    #mergesort 
    #pingpong 
    critical 
  ];

  large = [
    JGFMolDynBenchSizeA 
    JGFMonteCarloBenchSizeA 
    JGFRayTracerBenchSizeA 
  ];

  all = small ++ large;
}


