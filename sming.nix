{ pkgs ? import <nixpkgs> {}, build_samples ? true }:

let
  esp-open-sdk = import ./esp-open-sdk.nix {};
in pkgs.stdenv.mkDerivation {
  name = "Sming-4.3.0-prebuild";

  src = pkgs.fetchFromGitHub {
    owner = "SmingHub";
    repo = "Sming";
    rev = "4.3.0";
    sha256 = "174w20vi135xmv7szz5m6y33ialz7z5izvnrjkg6qmfsrnn8grwj";
    fetchSubmodules = true;
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  BUILD_SAMPLES=build_samples;
  ESP_HOME="${esp-open-sdk}";
  buildPhase = ''
    cd $NIX_BUILD_TOP
    mv source Sming
    cd Sming

    # disable submodule update in makefile - it is done in fetchFromGithub
    sed -i '/submodule update --init --force --recursive/d' Sming/build.mk
    
    export SMING_HOME=$(readlink -f Sming)

    if [ -n "$BUILD_SAMPLES" ]
    then

    # build samples 
    pushd samples/Basic_Blink
    make 
    make SMING_RELEASE=1
    rm -r out
    popd

    pushd samples/Echo_Ssl
    make 
    make SMING_RELEASE=1
    rm -r out
    popd

    fi
  '';
  nativeBuildInputs = with pkgs; [
    coreutils which gnumake gnused bash binutils git python3
  ];

  installPhase = ''
    cp -r /build/Sming/ $out
  '';
}
