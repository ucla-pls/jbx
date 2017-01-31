{ dljc
, maven
, jq
, ant
, cpio
, gradle
, stdenv
, unzip
# Inputs:
, src
, sha256
, subfolder ? ""
}:
java:
stdenv.mkDerivation {
  inherit src subfolder;
  name = src.name + (if subfolder != "" then "_" + (builtins.replaceStrings ["/"] ["_"] subfolder) else "");
  phases = [ "unpackPhase" "buildPhase" ];
  buildInputs = [ dljc maven jq ant java.jdk unzip cpio gradle ];
  buildPhase = ./builder.sh;
  outputHash = sha256;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  impureEnvVars = [
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
  ];
}
