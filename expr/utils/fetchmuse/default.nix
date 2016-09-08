# Copy of the fecthurl code, but with a twist
{ system ? builtins.currentSystem
, url
, name
, outputHash ? ""
, outputHashAlgo ? ""
, md5 ? "", sha1 ? "", sha256 ? ""
}:

assert (outputHash != "" && outputHashAlgo != "")
    || md5 != "" || sha1 != "" || sha256 != "";

mkDerivation {
  builder = ''cp "$MUSE_MOUNT/$url" "$out"'';

  # New-style output content requirements.
  outputHashAlgo = if outputHashAlgo != "" then outputHashAlgo else
      if sha256 != "" then "sha256" else if sha1 != "" then "sha1" else "md5";
  outputHash = if outputHash != "" then outputHash else
      if sha256 != "" then sha256 else if sha1 != "" then sha1 else md5;
  outputHashMode = if unpack || executable then "recursive" else "flat";

  inherit name system url executable unpack;

  # No need to double the amount of network traffic
  preferLocalBuild = true;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "MUSE_MOUNT"
  ];
