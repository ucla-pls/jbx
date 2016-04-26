{ python, lib, batch, eject, compose}:
let inherit (lib.lists) concatMap filter;
in rec {

  # The compatablitiy table computes a table with a benchmarks in rows and java
  # versions as coloums. 
  compatablity-table = analysis: versions:
    batch analysis { 
      name = "compat-table";
      foreach = ''
        cat $result/result.csv >> data.csv
      '';
      buildInputs = [ python eject ];
      after = ''
      source $stdenv/setup
      python2.7 ${./transpose.py} <data.csv >table.csv
      column -s',' -t table.csv
      '';
    } versions;

  # Overview runs a set of analyses against each other to check if they perform 
  # as expected. Also produces an difference report. 
  overview = {
    resultfile,
    name, 
    analyses ? [],
    }: 
    env:
    benchmark:
    let 
      results = map (analysis: analysis env benchmark) analyses; 
    in compose results {
      inherit name; 
      buildInputs = [ python eject ];
      combine = ''
        python2.7 ${./overview.py} "${resultfile}" errors ${
          builtins.concatStringsSep " " 
            (map (r: "${r.sign}${r.name}=${r}") results)
        } > table.csv
        column -s',' -t table.csv
      '';
    };

  # joincsv takse a csv files for all involved benchmarks and joins them 
  # into one.
  total = 
    name:
    overviews: 
    compose overviews {
      inherit name;
      buildInputs = [ python eject ];
      combine = ''
        python2.7 ${./total.py} $results > table.csv
        column -s',' -t table.csv
      '';
    };
}


