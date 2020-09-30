# simple flash script that can be linked in $out/bin
{ pkgs, sming }:

let 
  python = pkgs.python3.withPackages (pp: with pp; [ pyserial ]);
in pkgs.writeShellScriptBin "flash" ''
  BASEDIR=$(dirname ''${BASH_SOURCE})
  ${python}/bin/python ${sming}/Sming/Arch/Esp8266/Components/esptool/esptool/esptool.py \
  -p "$1" -b 115200 write_flash \
  --flash_freq 40m --flash_mode qio --flash_size detect \
  0x00000 $BASEDIR/../firmware/rboot.bin \
  0x002000 $BASEDIR/../firmware/rom0.bin
''
