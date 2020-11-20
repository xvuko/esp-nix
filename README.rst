ESP-NIX
=======
Complete toolchain needed to build ESP8266 `Sming`_ applications on nix.

crosstool-ng.nix is based on `xtensa-esp32-elf.nix`_ github gist.

.. _xtensa-esp32-elf.nix: https://gist.github.com/thpham/0cccfab10936979a78de776c87ba906a
.. _Sming: https://github.com/SmingHub/Sming

Design
------
To keep this build system simple and flexible whole Sming directory must be
copied for each build. This could be optimized by linking source code and
copying only build directories.

Usage
-----
Example nix build file::

    { pkgs ? import <nixpkgs> {} }:
    let
      esp-nix = import (pkgs.fetchFromGitHub {
        owner = "xvuko";
        repo = "esp-nix";
        rev = [...];
        sha256 = [...];
      }) { inherit pkgs; };
    in
    pkgs.stdenvNoCC.mkDerivation {
    
      name = [...];
      phases = ["unpackPhase" "buildPhase" "installPhase"];
      src = ./.;
    
      ESP_HOME = esp.esp-open-sdk;
      SMING_RELEASE = "1";
    
      buildPhase = ''
        cp -r ${esp.sming} $NIX_BUILD_TOP/Sming
        chmod +w -R $NIX_BUILD_TOP/Sming
        export SMING_HOME=$(readlink -f $NIX_BUILD_TOP/Sming/Sming)
    
        make 
      '';
    
      buildInputs = [ pkgs.python3 ];
    
      installPhase = ''
        mkdir -p $out
        cp -r out/Esp8266/release/firmware $out/firmware
        mkdir -p $out/bin/
        ln -s ${esp.flash}/bin/flash $out/bin/flash
      '';
    }

Library caching
---------------
Current sming build system creates hash names for compiled libraries. This
allows having cache with multiple versions of same library and speeds up
recompilation. In sming.nix_ two samples are build in
both release and debug modes to force library cache generation. When using
this file with other libraries / compilation options you might want to add
additional build instructions.

.. _sming.nix: sming.nix
