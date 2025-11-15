import argparse
import zlib
from pathlib import Path
import sys

VERSION = "1.0.0"

VERSION_STR = f"""
Part of the
  ____              _   ____  ___
 / __ \\___  ___ ___| | / /  |/  /
/ /_/ / _ \\/ -_) _ \\ |/ / /|_/ /
\\____/ .__/\\__/_//_/___/_/  /_/
    /_/
Project

OpenVM Bytecode Packager (OVMBP)
VERSION: {VERSION}
"""

parser = argparse.ArgumentParser(
    description="OVMBP — Compress or decompress a single OpenVM bytecode file for distibution"
)

# Make version independent of file by using mutually exclusive group
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("-v", "--version", action="store_true", help="Show version information")
group.add_argument("file", nargs="?", help="Input file (.ovmb or .ovmpkg)")

parser.add_argument("-o", "--output", "-O", help="Output file")
parser.add_argument("-l", "--level", type=int, default=9, help="Compression level (0–9)")
parser.add_argument("-d", "--decompress", action="store_true", help="Decompress the input file")

args = parser.parse_args()

if args.version:
    print(VERSION_STR)
    sys.exit(0)

if not args.file:
    sys.exit("Error: input file required.")

input_path = Path(args.file)
if not input_path.exists():
    sys.exit(f"Error: '{input_path}' not found.")

output_path = Path(args.output) if args.output else (
    input_path.with_suffix(".ovmb") if args.decompress else input_path.with_suffix(".ovmpkg")
)

try:
    data = input_path.read_bytes()

    if args.decompress:
        # Decompress
        decompressed = zlib.decompress(data)
        output_path.write_bytes(decompressed)
        print(f"Decompressed '{input_path.name}' → '{output_path.name}' ({len(decompressed)} bytes).")
    else:
        # Compress
        compressed = zlib.compress(data, level=args.level)
        output_path.write_bytes(compressed)
        ratio = (1 - len(compressed) / len(data)) * 100
        print(f"Compressed '{input_path.name}' → '{output_path.name}' ({len(compressed)} bytes, {ratio:.2f}% smaller).")
except Exception as e:
    sys.exit(f"Error: {e}")
