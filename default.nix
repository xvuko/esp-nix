{ pkgs ? import <nixpkgs> {} }:

rec {
  sming = import ./sming.nix { inherit pkgs; };
  esp-open-sdk = import ./esp-open-sdk.nix { inherit pkgs; };
  esptool2 = import ./esptool2.nix { inherit pkgs; };
  crosstool-ng = import ./crosstool-ng.nix { inherit pkgs; };
  flash = import ./flash.nix { inherit sming pkgs; };
  init = import ./initialize.nix { inherit sming pkgs; sdk = esp-open-sdk; };
  spiffs = import ./spiffs.nix { inherit sming pkgs; };
  buildSmingApplication = pkgs.lib.makeOverridable pkgs.callPackage ./buildSmingApplication.nix { inherit esp-open-sdk sming; };
  buildSmingComponent = pkgs.lib.makeOverridable pkgs.callPackage ./buildSmingComponent.nix { inherit esp-open-sdk sming; };
}
