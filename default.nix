{ pkgs ? import <nixpkgs> {}, toolchain ? "quick" }:

rec {
  quick-sdk = pkgs.callPackage ./esp-quick-toolchain.nix {};
  open-sdk = import ./esp-open-sdk.nix { inherit pkgs; };
  sdk = (
    if toolchain == "quick" then
      quick-sdk
    else if toolchain == "open" then
      open-sdk
    else throw "Unsuported toolchain"
  );
  sming = import ./sming.nix { inherit pkgs; esp-sdk = sdk; };
  esptool2 = import ./esptool2.nix { inherit pkgs; };
  crosstool-ng = import ./crosstool-ng.nix { inherit pkgs; };
  flash = import ./flash.nix { inherit sming pkgs; };
  init = import ./initialize.nix { inherit sming pkgs; sdk = sdk; };
  spiffs = import ./spiffs.nix { inherit sming pkgs; };
  buildSmingApplication = pkgs.lib.makeOverridable pkgs.callPackage ./buildSmingApplication.nix { inherit sming; esp-sdk = sdk; };
  buildSmingComponent = pkgs.lib.makeOverridable pkgs.callPackage ./buildSmingComponent.nix { inherit sming; esp-sdk = sdk; };
  firmwareWithTools = pkgs.callPackage ./firmwareWithTools.nix { inherit flash init spiffs; };
}
