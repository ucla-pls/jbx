{ fetchurl, stdenv, unzip, jdk7}:
{
  graphgen = stdenv.mkDerivation {
    name = "graphgen";
    src = fetchurl {
      url = "http://www.csl.sri.com/~schaef/graphgen.zip";
      md5 = "152449151012b96420caf695f44103ef";
    };
    phases = "buildPhase installPhase";
    buildInputs = [ unzip jdk7 ];
    buildPhase = ''
      unzip $src -d file
    ''; 
    installPhase = ''
      mkdir -p $out/share/java
      find file -name '*.jar' -exec cp -r {} $out/share/java \;
    '';
  };
}
