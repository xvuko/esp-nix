# simple flash script that can be linked in $out/bin
{ pkgs, sming }:

let 
  python = pkgs.python3.withPackages (pp: with pp; [ pyserial ]);
in pkgs.writeScriptBin "flash" 
  # @begin=python@
  ''
    #!${pkgs.python3}/bin/python
    
    import argparse
    import subprocess
    from pathlib import Path
    
    parser = argparse.ArgumentParser()
    parser.add_argument("serial", help="serial port")
    args = parser.parse_args()
    
    python = '${python}/bin/python'
    esptool = '${sming}/Sming/Components/esptool/esptool/esptool.py'
    fw = Path(__file__).parent.parent.joinpath('firmware').absolute()
    
    address = "0x100000"
    
    fargs = [
        '-p', args.serial,
        '-b', '115200',
        '--chip', 'esp8266',
        '--before', 'default_reset',
        '--after', 'hard_reset' 
    ]
    
    iargs = [
      '-z', '-fs', '1MB', '-ff', '40m', '-fm', 'dio',
      '0x000000', fw.joinpath("rboot.bin"),
      '0x002000', fw.joinpath("rom0.bin"),
      '0x000fa000', fw.joinpath('partitions.bin'),
      '0x000fc000', '${sming}/Sming/Arch/Esp8266/Components/esp8266/ESP8266_NONOS_SDK/bin/esp_init_data_default.bin'
    ]
    
    
    subprocess.run([python, esptool, *fargs, 'write_flash', *iargs ])
''
  # @end=python@
