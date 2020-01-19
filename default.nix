{ pkgs ? import <nixpkgs> {} }:
let
  sming = import ./sming.nix { inherit pkgs; };
  esp-open-sdk = import ./esp-open-sdk.nix { inherit pkgs; };
  esptool2 = import ./esptool2.nix { inherit pkgs; };
  crostool-ng = import ./crostool-ng.nix { inherit pkgs; };
in pkgs.stdenvNoCC.mkDerivation {
  name = "nix-sming-toolkit";
  phases = [ "installPhase" ];
  installPhase = "
    mkdir $out
    ln -s ${sming} $out/sming
    ln -s ${esp-open-sdk} $out/esp-open-sdk
    ln -s ${esptool2} $out/esptool2
    ln -s ${crostool-ng} $out/crosstool-ng
    ${pkgs.python3Packages.docutils}/bin/rst2html ${./README.rst} > $out/README.html
  ";
}
