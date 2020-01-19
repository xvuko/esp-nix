{ pkgs ? import <nixpkgs> {} }:

let
  crosstool_ng = import ./crosstool-ng.nix {};
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
    # export ENABLE_SSL=1
    make
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
  buildInputs = with pkgs; [
    which gnumake autoconf automake libtool gperf flex bison texinfo gawk
    ncurses.dev expat python gnused git unzip bash help2man bzip2 binutils
  ];

  # https://unix.stackexchange.com/questions/356232/disabling-the-security-hardening-options-for-a-nix-shell-environment#367990
  hardeningDisable = [ "format" ];
}
