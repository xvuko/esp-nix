ESP-NIX
=======
Complete toolchain needed to build ESP8266 `Sming`_ applications on nix.

crosstool-ng.nix is based on `xtensa-esp32-elf.nix`_ github gist.

.. _xtensa-esp32-elf.nix: https://gist.github.com/thpham/0cccfab10936979a78de776c87ba906a
.. _Sming: https://github.com/SmingHub/Sming

usage
-----

Example nix build file::

    { pkgs ? import <nixpkgs> {} }:
    let
      esp-nix = builtins.fetchGit {
        url = "gitolite@vuko.pl:esp-nix";
        rev = "master";
      };
      sming = import "${esp-nix}/sming.nix" {};
    in
    pkgs.stdenvNoCC.mkDerivation {

      [...]

      ESP_HOME = esp-open-sdk;
      SMING_HOME = "${sming}/Sming";

      [...]

    }
