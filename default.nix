{ pkgs ? import <nixpkgs> {} }:

rec {
  sming = import ./sming.nix { inherit pkgs; };
  esp-open-sdk = import ./esp-open-sdk.nix { inherit pkgs; };
  esptool2 = import ./esptool2.nix { inherit pkgs; };
  crosstool-ng = import ./crosstool-ng.nix { inherit pkgs; };
  flash = import ./flash.nix { inherit sming pkgs; };
}
