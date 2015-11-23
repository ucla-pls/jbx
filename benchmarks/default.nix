{ pkgs }:
rec {
  dacapo = import ./dacapo { inherit pkgs; };

  all = all8 ++ all7 ++ all6 ++ all5;
 
  generic = [
    dacapo.avrora 
  ];

  all8 = map (f: f 8) generic;
  all7 = map (f: f 7) generic;
  all6 = map (f: f 6) generic;
  all5 = map (f: f 5) generic;
}
