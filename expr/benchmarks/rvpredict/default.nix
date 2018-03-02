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
        buildPhase = ''
          mkdir -p "$out/info" "$out/classes" "$out/lib"
          cp -r "." "$out/src"
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
          jar cf $_/rvpredict-benchmark.jar -C classes .
          jar uf $out/share/java/rvpredict-benchmark.jar -C lib .
        '';
      };
    };
in rec {
  bufwriter = rvp { name = "bufwriter"; mainclass = "bufwriter.BufWriter";};
  account = rvp { name = "account"; mainclass = "account.Account";};
  airlinetickets = rvp { name = "airlinetickets"; mainclass = "airlinetickets.Airlinetickets ";};
  array = rvp { name = "array"; mainclass = "array.Test ";};
  boundedbuffer = rvp { name = "boundedbuffer"; mainclass = "boundedbuffer.BoundedBuffer";};
  mergesort = rvp { name = "mergesort"; mainclass = "mergesort.MergeSort";};
  pingpong = rvp { name = "pingpong"; mainclass = "pingpong.PingPong";};
  critical = rvp { name = "critical"; mainclass = "critical.Critical";};

  JGFMolDynBenchSizeA = rvp { name = "JGFMolDynBenchSizeA"; mainclass = "benchmarks.JGFMolDynBenchSizeA";};
  JGFMonteCarloBenchSizeA = rvp { name = "JGFMonteCarloBenchSizeA"; mainclass = "benchmarks.JGFMonteCarloBenchSizeA";};
  JGFRayTracerBenchSizeA = rvp { name = "JGFRayTracerBenchSizeA"; mainclass = "benchmarks.JGFRayTracerBenchSizeA";};

  all = [
    bufwriter 
    account 
    airlinetickets 
    array 
    boundedbuffer 
    mergesort 
    pingpong 
    critical 

    JGFMolDynBenchSizeA 
    JGFMonteCarloBenchSizeA 
    JGFRayTracerBenchSizeA 
  ];
}


