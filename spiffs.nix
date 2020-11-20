{ pkgs, sming }:

let
  python = pkgs.python3.withPackages (pp: with pp; [ pyserial ]);

in pkgs.writeScriptBin "download-spiffs" ''
    #!${pkgs.python3}/bin/python

    import argparse
    import subprocess
    import json
    from tempfile import TemporaryDirectory
    from pathlib import Path
    
    parser = argparse.ArgumentParser()
    parser.add_argument("serial", help="serial port")
    parser.add_argument("config", type=Path, default=Path("./files"), help="json config file")
    
    args = parser.parse_args()
    
    spiffy = Path("${sming}/Sming/out/Esp8266/release/tools/spiffy")

    def run(*args, **kwargs):
      print(args, kwargs)
      subprocess.run(*args, **kwargs)

    with TemporaryDirectory() as tmp:
        tmp = Path(tmp)

        files = tmp.joinpath("files")
        files.mkdir()

        files.joinpath("config.json").write_bytes(args.config.read_bytes())
        
        size = 524288
        address = 0x100000
        fs = tmp.joinpath('spiff_rom.bin')
        run([spiffy, str(size), files, fs])
        
        python = '${python}/bin/python'
        esptool = '${sming}/Sming/Arch/Esp8266/Components/esptool/esptool/esptool.py'
        fargs = [
            '-p', args.serial, '-b', '115200', 'write_flash'
        ]
        
        run([python, esptool, *fargs, f'0x{address:x}', fs])
''
