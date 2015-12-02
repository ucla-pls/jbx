{ fetchmvn }: java:
fetchmvn {
  name = "jaxen";
  version = "1.1.1";
  md5 = "261d1aa59865842ecc32b3848b0c6538";
}
# stdenv.mkDerivation {
#   name = "jaxen";
#   version = "2.8.0";
#   src = fetchurl {
#     url = "http://pkgs.fedoraproject.org/repo/pkgs/jaxen/jaxen-1.1.1-src.tar.gz/b598ae6b7e765a92e13667b0a80392f4/jaxen-1.1.1-src.tar.gz";
#     md5 = "b598ae6b7e765a92e13667b0a80392f4";
#   };
#   buildInputs = [ ant java.jdk ] ++ (with java.libs; [ xerces ]);
#   phases = [ "unpackPhase" "buildPhase" "installPhase" ];
#   buildPhase = ''
#     ant jar
#   '';
#   installPhase = ''
#     ls -l && false
#     mkdir -p $out/share/java/
#     mv *.jar $_ 
#   '';
# }
