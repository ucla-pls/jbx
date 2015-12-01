{ stdenv, time, coreutils }:
stdenv.mkDerivation {
  inherit time coreutils;
  name = "utils";
  tools = ./tools.sh;
  builder = ./builder.sh;
}


