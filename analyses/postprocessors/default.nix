{ python, lib, batch, eject}:
let inherit (lib.lists) concatMap filter;
in rec {

  # product :: (a -> b -> c) -> [a] -> [b] -> [c]
  product = f: as: bs: concatMap (a: map (b: f a b) bs) as;

  # produces a list of benchmarks
  versionize = javas: benchmarks: filter (b: b.isWorking) (
    product (b: j: b.withJava j) benchmarks javas
  );

  # The compatablitiy table computes a table with a benchmarks in rows and java
  # versions as coloums. 
  compatablity-table = analysis: versions:
    batch analysis { 
      name = "compat-table";
      foreach = ''
        cat $result/result.csv >> data.csv
      '';
      buildInputs = [ python eject];
      after = ''
source $stdenv/setup
python -c " 
import csv
import sys
import re

f = csv.reader(sys.stdin)
table = {}
javas = set()
for l in f:
  (name, java, type) = re.match('(.+)J([0-9]+)-(.+)', l[0]).groups();  
  table.setdefault(name, {})[java] = '{} ({}s)'.format(l[2], l[1]);
  javas.add(java)

javaorder = sorted(javas)

writer = csv.writer(sys.stdout)

writer.writerow(['Benchmark'] + ['Java ' + java for java in javaorder]);
for name, col in sorted(table.items()):
  writer.writerow([name] + [col.get(java, 'N/A') for java in javaorder]);

" <data.csv >table.csv
  column -s',' -t table.csv
'';} versions;

}


