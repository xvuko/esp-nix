{ pkgs ? import <nixpkgs> {} }:

let
  crosstool_ng = import ./crostool-ng.nix {};
  esp-open-sdk = import ./esp-open-sdk.nix {};
in pkgs.stdenv.mkDerivation {
  name = "sming";
  version = "3.8.1_nossl";
  src = pkgs.fetchFromGitHub {
    owner = "SmingHub";
    repo = "Sming";
    rev = "3.8.1";
    sha256 = "1c3l4pkcbwwhq1478p6xh2hqfp1ml4pwdgg62vwk9xhcgjm0rbgy";
    fetchSubmodules = true;
  };
  ESP_HOME=esp-open-sdk;
  buildPhase = ''
    pushd Sming
    export SMING_HOME=$(readlink -e ./)
    set -x
    ls -la
    which make
    make
    # ENABLE_SSL=1
    rm -r out
    popd
  '';
  installPhase = ''
    pwd
    mkdir $out
    cp -avr Sming $out
    mkdir $out/bin
    cp -avr tools/esptool2/esptool2 $out/bin/
    cp -avr tools/spiffy/spiffy $out/bin/
  '';
  buildInputs = with pkgs; [ which gnumake autoconf automake libtool gperf flex bison texinfo gawk ncurses.dev expat python gnused git unzip bash help2man bzip2 binutils ];
  hardeningDisable = [ "format" ];
}
