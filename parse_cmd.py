from pathlib import Path
import shlex
import re
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('cmd_input', type=Path, help='input file containg flash command')
parser.add_argument('json_output', type=Path, help='output file with parsed flash arguments')
script_args = parser.parse_args()

raw_cmd = script_args.cmd_input.read_text().strip()

args = iter(shlex.split(raw_cmd))

arg = next(args)
if re.fullmatch('python3?', arg):
    arg = next(args)

assert arg == '/build/Sming/Sming/Components/esptool/esptool/esptool.py'

arg = next(args)
assert arg == '-p'

arg = next(args)
assert arg == '/dev/ttyUSB0'

important_args = []

while True:
    arg = next(args)
    if re.fullmatch('0x[a-f0-9]*', arg):
        break
    important_args.append(arg)

segments = []

sming_path = Path('/', 'build', 'Sming')
out_path = Path('out')

while True:
    assert re.fullmatch('0x[a-f0-9]*', arg)
    addr = arg
    file = Path(next(args))
    if file.is_relative_to(sming_path):
        file = file.relative_to(sming_path)
        segments.append((addr, 'SMING_HOME', str(file)))
    elif file.is_relative_to(out_path):
        assert file.parts[0] == 'out'
        assert file.parts[1] == 'Esp8266'
        assert file.parts[2] in {'debug', 'release'}
        assert file.parts[3] == 'firmware'
        file = Path(*file.parts[4:])
        segments.append((addr, 'FIRMWARE', str(file)))
    else:
        raise ValueError(f'Unexpected file path: {file}')

    try:
        arg = next(args)
    except StopIteration:
        break

print(important_args)
print(segments)

script_args.json_output.write_text(json.dumps({
    'esptool': str(Path('/build/Sming/Sming/Components/esptool/esptool/esptool.py').relative_to(sming_path)),
    'arguments': important_args,
    'segments': [list(x) for x in segments]}
))
