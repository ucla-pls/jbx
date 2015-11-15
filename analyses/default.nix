{ pkgs, tools}:
let
  inherit (pkgs) stdenv time;
  inherit (pkgs.lib.strings) concatStringsSep;
in rec {
# Run
run = {
  # A descriptive name
    name ? ""
  # The command to execute
  , cmd ? ""
  # The list of arguments
  , args ? []
}: stdenv.mkDerivation {
   inherit name cmd;
   cmdargs = args;
   builder = ./run.sh;
   inherit time;
};

java = {
  # A name
  name
  , mainclass
  , classpath ? []
  , deps ? []
  , args ? []
  , jre ? pkgs.jre7
}: 
let
  classpath_ = concatStringsSep ":" classpath;
in run {
  inherit name;
  cmd = "${jre}/bin/java";
  args = [ "-cp" classpath_ ] ++ [ mainclass ] ++ args;
}; 

test = run {
  name = "SimpleTest";
  cmd = "echo";
  args = [ "Hello" "World!" ];
};

}
