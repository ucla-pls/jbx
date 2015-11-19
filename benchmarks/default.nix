{ pkgs }:
rec {
  dacapo = import ./dacapo { inherit pkgs; };

  all = [
   dacapo.avrora
  ];
}
