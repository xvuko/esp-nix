{ pkgs ? import <nixpkgs> {} }:

let
  python = pkgs.python2Full.withPackages (python-packages: with python-packages; [
    pyserial
  ]); 
  crosstool_ng = import ./crostool-ng.nix {};
  sdk = pkgs.fetchFromGitHub {
    owner = "espressif";
    repo = "ESP8266_NONOS_SDK";
    rev = "61248df5f6";
    sha256 = "175y9v0lpp1f89a1sghschs131r5wmqisphvdzr3y8yrqmx2dljs";
  };
  sdk154 = pkgs.fetchurl {
    url = "http://bbs.espressif.com/download/file.php?id=1469";
    sha256 = "01pkshzm7a45v4sp8281nypsi0fmqcy07fr8ncbbg43rv55cf88h";
  };
in pkgs.stdenvNoCC.mkDerivation {
  name = "esp-open-sdk";
  src = pkgs.fetchFromGitHub {
    owner = "pfalcon";
    repo = "esp-open-sdk";
    rev = "c70543e57fb18e5be0315aa217bca27d0e26d23d";
    sha256 = "03ys2wn7fsljxc2skzxabq0yanrp6h67py8byvjfdh0gq7pz5j3r";
    fetchSubmodules = true;
  };
  preConfigure = ''
    substituteInPlace Makefile \
      --replace '/bin/bash' '${pkgs.bash}/bin/bash'
    substituteInPlace esp-open-lwip/gen_misc.sh \
      --replace '/bin/bash' '${pkgs.bash}/bin/bash'
    #sed -i '/^\(toolchain .*\) crosstool-NG\/.built$/d' Makefile
    sed -i 's%^\(toolchain .*\) crosstool-NG\/.built$%\1%' Makefile
    sed -i '/git clone.*NONOS_SDK/d' Makefile
    sed -i '/SDK_DIR.*git checkout/d' Makefile

    cp -vr ${crosstool_ng} ./xtensa-lx106-elf/
    chmod -R u+w ./xtensa-lx106-elf

    #cp -vr ${sdk} ESP8266_NONOS_SDK-2.1.0-18-g61248df
    #chmod -R u+w ESP8266_NONOS_SDK-2.1.0-18-g61248df

    cp -r ${sdk154} ESP8266_NONOS_SDK_V1.5.4_16_05_20.zip
  '';
  buildPhase = ''
    make VENDOR_SDK=1.5.4 STANDALONE=y
  '';
  installPhase = ''
    mkdir -p $out
    cp -avr $(readlink -e sdk) $out/sdk
    cp -avr xtensa-lx106-elf $out/
    cp -avr esptool $out/
  '';
  buildInputs = with pkgs; [ which gnumake autoconf automake libtool gperf flex bison texinfo gawk ncurses.dev expat python gnused git unzip bash help2man bzip2 binutils ];
  hardeningDisable = [ "format" ];
}
