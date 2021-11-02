{ pkgs ? import <nixpkgs> {}, esp-sdk ? import ./esp-open-sdk.nix {},  build_samples ? true }:

pkgs.stdenv.mkDerivation {
  name = "Sming-4.3.0-prebuild";

  src = pkgs.fetchFromGitHub {
    owner = "SmingHub";
    repo = "Sming";
    rev = "4.4.1";
    sha256 = "1y51k3mwjxds4vna3wara4p672ngrf40hjy71sr1rk6jmbqb3hhv";
    fetchSubmodules = true;
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  BUILD_SAMPLES=build_samples;
  ESP_HOME="${esp-sdk}";
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
