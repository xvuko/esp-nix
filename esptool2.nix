{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "esptool2";
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "raburton";
    repo = "esptool2";
    rev = "91759a7c4faec1b7bc8410166d22ed92eb90556c";
    sha256 = "09vkd3hldqgaiil67y104v01ad7pgg2k976brq6h9wfv17qjhnlf";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp esptool2 $out/bin/
  '';
}
