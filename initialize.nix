{ pkgs, sming, sdk }:

let
  python = pkgs.python3.withPackages (pp: with pp; [ pyserial ]);

in pkgs.writeScriptBin "initialize" ''
    #!${pkgs.python3}/bin/python

    import argparse
    import subprocess
    from pathlib import Path
    
    parser = argparse.ArgumentParser()
    parser.add_argument("serial", help="serial port")
    
    args = parser.parse_args()
    
    def run(*args, **kwargs):
      print(args, kwargs)
      subprocess.run(*args, **kwargs)

        
    python = '${python}/bin/python'
    esptool = '${sming}/Sming/Arch/Esp8266/Components/esptool/esptool/esptool.py'

    sdk = Path('${sdk}').joinpath('sdk')
    blank = sdk.joinpath('bin', 'blank.bin')
    init = sdk.joinpath('bin', 'esp_init_data_default.bin')

    fargs = [ '-p', args.serial, '-b', '115200']

    iargs = [
      '0x001000', blank,
      '0x1fe000', blank,
      '0x1fc000', init
    ]

    run([python, esptool, *fargs, write_flash, *iargs])
''

