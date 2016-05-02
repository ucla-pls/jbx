{ fetchurl, stdenv, unzip}:
{
  graphgen = stdenv.mkDerivation {
    name = "graphgen";
    src = fetchurl {
      url = "http://www.csl.sri.com/~schaef/graphgen.zip";
      md5 = "152449151012b96420caf695f44103ef";
    };
    phases = "buildPhase installPhase";
    buildInputs = [ unzip ];
    buildPhase = ''
      unzip $src -d file
    ''; 
    installPhase = ''
      cp -r file $out
    '';
  };
}
