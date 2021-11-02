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
    import itertools
    import json
    from pathlib import Path
    
    parser = argparse.ArgumentParser()
    parser.add_argument("serial", help="serial port")
    args = parser.parse_args()
    
    sming = Path('${sming}')
    python = '${python}/bin/python'
    esptool = sming / 'Sming/Components/esptool/esptool/esptool.py'
    fw = Path(__file__).parent.parent.joinpath('firmware').absolute()
    flash_cmd = json.loads(Path(__file__).parent.parent.joinpath('flash.json').read_text())
    
    
    fargs = [
        '-p', args.serial, *flash_cmd['arguments']
    ]


    iargs = itertools.chain.from_iterable(((addr, sming.joinpath(path) if base == 'SMING_HOME' else fw.joinpath(path)) for addr, base, path in flash_cmd['segments']))

    subprocess.run([python, esptool, *fargs, *iargs ])
''
  # @end=python@
