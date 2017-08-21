{shared, jchord-2_0, petablox, utils, python, python3, eject}:
let
  jchord_ = jchord-2_0;
  petablox_ = petablox;
  loggingSettings = {
      depth = 0;
      timelimit = 122;
      ignoredprefixes = "org/mockito,org/powermock,edu/ucla/pls/wiretap,java,sun";
  };
in rec {
  jchord = utils.after (shared.jchord {
    name = "deadlock";
    jchord = jchord_;
    subanalyses = ["deadlock-java"];
    reflection = "dynamic";
  }) {
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/chord_output > $out/upper
    '';
  };

  petablox = utils.after (shared.petablox {
    name = "deadlock";
    petablox = petablox_;
    subanalyses = ["cipa-0cfa-dlog" "queryE" "deadlock-java"];
    reflection = "external";
    settings = [
      { name = "deadlock.exclude.nongrded"; value = "true"; }
      { name = "print.results"; value = "true"; }
    ];
  }) {
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/petablox_output > $out/upper
    '';
  };

  surveilOptions = {
      name = "deadlock";
      logging = loggingSettings;
      cmd = "deadlocks";
      filter = "unique,lockset";
      provers = ["none" "kalhauge"];
      timelimit = 36000;
      chunkSize = 10000;
      chunkOffset = 5000;
    };

  surveil = shared.surveil surveilOptions;
  surveilFlat = shared.surveilFlat surveilOptions;

  surveilWiretap =
    shared.wiretapSurveil loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  surveilRepeated =
     utils.repeated {
        times = 100;
        tools = [python3 eject];
        foreach = ''
          tail -n +2 "$result/times.csv" | sed 's/^.*\$//' >> times-tmp.csv
        '';
        collect = ''
          python3 > times.csv <<EOF
import sys
import csv

with open("times-tmp.csv", "r") as f:
  arr = list(csv.reader(f))

count = {}
values = {}

for line in arr:
  name, *rest = line
  count[name] = count.get(name, 0) + 1
  values[name] = [ a + float(b) for a, b in zip(values.get(name, [0] * 5), rest) ]

wrt = csv.writer(sys.stdout)
wrt.writerow(["name", "real", "user", "kernel", "maxm", "exitcode"]) 
for name in values:
  wrt.writerow(["$name\$" + name] + [ "{0:.4g}".format(value / count[name]) for value in values[name]])
EOF
          python3 ${./cyclestats.py} $name $results | tee cycles.txt | column -ts,
          cat times.csv
        '';
     } surveilFlat ;

  surveilRepeatedAll =
    benchmark:
      utils.lift (joinCycles (benchmark.name))
        (utils.onAllInputsS surveilRepeated)
        benchmark;

  joinCycles =
    name:
    utils.mkStatistics {
      name = name;
      foreach = ''
        cat $result/cycles.txt >> cycles.txt
        tail -n +2 $result/times.csv >> times-tmp.csv
      '';
      collect = ''
	echo "name,real,user,kernel,maxm,exitcode" > times.csv
	cat times-tmp.csv >> times.csv
      '';
    };

  overview =
    utils.overview "deadlock" [
      jchord
      petablox
      surveilAll
    ];
}
