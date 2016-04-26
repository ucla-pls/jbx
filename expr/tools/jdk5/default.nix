{stdenv, fetchprop, coreutils
, glib
, file
, libxml2
, libav_0_8
, ffmpeg
, libxslt
, mesa_noglu
, xorg
, alsaLib
, fontconfig
, freetype
, gnome
, cairo
, gdk_pixbuf
, atk
, setJavaClassPath
}:
stdenv.mkDerivation rec {
  name = "jdk";
  version = "5u22";
  src = fetchprop {
    url = "jdk-1_5_0_22-linux-amd64.bin";
    md5 = "b62abcaf9ea8617c50fa213bbc88824a";
  };
  buildInputs = [ coreutils ];
  phases = [ "buildPhase" "installPhase" "fixupPhase" ];
  libraries = [stdenv.cc.libc glib libxml2 libav_0_8 ffmpeg libxslt mesa_noglu xorg.libXxf86vm alsaLib fontconfig freetype gnome.pango gnome.gtk cairo gdk_pixbuf atk]; 
  architecture =
    if stdenv.system == "i686-linux" then
      "i386"
    else if stdenv.system == "x86_64-linux" then
      "amd64"
    else
      abort "jdk requires i686-linux or x86_64 linux";
  
  buildPhase = ''
    tail -n +766 "$src" > install

    echo $NIX_CC/nix-support/dynamic-linker
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      "install"
    chmod +x install
    ./install
  '';

  installPhase = ''
    mv jdk1.5.0_22 $out
  '';

  nativeBuildInputs = [ file ];

  postFixup = ''
    # From https://github.com/NixOS/nixpkgs/blob/788800e437c4a0a25d95e217540bded68804b25e/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix
    rpath=
    for i in $libraries; do
      rpath=$rpath''${rpath:+:}$i/lib:$i/lib64
    done

    jrePath=$out/jre
    
    rpath=$rpath''${rpath:+:}$jrePath/lib/${architecture}/jli
    rpath=$rpath''${rpath:+:}$jrePath/lib/${architecture}/server
    rpath=$rpath''${rpath:+:}$jrePath/lib/${architecture}/xawt
    rpath=$rpath''${rpath:+:}$jrePath/lib/${architecture}

    # set all the dynamic linkers
    find $out -type f -perm -0100 \
        -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$rpath" {} \;

    find $out -name "*.so" -exec patchelf --set-rpath "$rpath" {} \;

    mkdir $jrePath/lib/${architecture}/plugins
    ln -s $jrePath/lib/${architecture}/libnpjp2.so $jrePath/lib/${architecture}/plugins

    mkdir -p $out/nix-support
    echo -n "${setJavaClassPath}" > $out/nix-support/propagated-native-build-inputs

    # http://stackoverflow.com/questions/11808829/jre-1-7-returns-java-lang-noclassdeffounderror-java-lang-object
    packfiles=$(find $out -type f -name "*.pack")
    for p in $packfiles; do
      $out/bin/unpack200 $p ''${p%.*}.jar
    done
  '';
}
