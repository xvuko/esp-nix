{ stdenvNoCC, flash, init, spiffs }:

{ name, firmware }: stdenvNoCC.mkDerivation {
  inherit name;
  phases = [ "installPhase" ];

  installPhase = "
    mkdir -p $out/bin
    ln -s ${firmware}/firmware $out/firmware
    ln -s ${flash}/bin/flash $out/bin/flash
    ln -s ${init}/bin/initialize $out/bin/initialize
    ln -s ${spiffs}/bin/download-spiffs $out/bin/download-spiffs
  ";
}
