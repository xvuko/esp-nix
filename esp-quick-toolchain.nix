{ stdenv, ncurses5, lib, fetchurl }:

# based-on <nixpkgs>/development/compilers/gcc-arm-embedded/10/default.nix

stdenv.mkDerivation {
  name = "esp8266-quick-toolchain";
  src = fetchurl {
    url = https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.0.4-gcc10.3/x86_64-linux-gnu.xtensa-lx106-elf-1757bed.210717.tar.gz;
    sha256 = "19jz66w9ihxl4n23w1qk1pz4aaa4z9zh9rfljp1pffvmwpbik20a";
  };
  installPhase = ''
    mkdir -p $out/xtensa-lx106-elf
    cp -r * $out/xtensa-lx106-elf
  '';

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  preFixup = ''
    find $out -type f | while read f; do
      patchelf "$f" > /dev/null 2>&1 || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f" || true
      patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ncurses5 ]} "$f" || true
    done
  '';
}
