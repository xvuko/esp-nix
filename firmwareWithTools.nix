{ stdenvNoCC, flash, init, spiffs, python3 }:

{ name, firmware }: stdenvNoCC.mkDerivation {
  inherit name;
  phases = [ "installPhase" ];

  installPhase = "
    mkdir -p $out/bin
    ${python3}/bin/python3 ${./parse_cmd.py} ${firmware}/flash_cmd.sh $out/flash.json
    ln -s ${firmware}/firmware $out/firmware
    ln -s ${flash}/bin/flash $out/bin/flash
    ln -s ${init}/bin/initialize $out/bin/initialize
    ln -s ${spiffs}/bin/download-spiffs $out/bin/download-spiffs
  ";
}
