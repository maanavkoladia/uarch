import re
import sys
from pathlib import Path

# Regex to match localparam lines
# Handles optional type (int, logic, etc.)
LOCALPARAM_REGEX = re.compile(
    r'localparam\s+(?:\w+\s+)?(\w+)\s*=\s*(.*?);'
)

def extract_localparams(text):
    matches = LOCALPARAM_REGEX.findall(text)
    results = []

    for name, value in matches:
        value = value.strip()
        results.append((name, value))

    return results


def convert_to_defines(localparams):
    lines = []
    for name, value in localparams:
        lines.append(f'`define {name} ({value})')
    return "\n".join(lines)


def process_file(input_path, output_path=None):
    text = Path(input_path).read_text()

    localparams = extract_localparams(text)

    if not localparams:
        print("No localparams found.")
        return

    defines_text = convert_to_defines(localparams)

    if output_path:
        Path(output_path).write_text(defines_text)
        print(f"Defines written to {output_path}")
    else:
        print(defines_text)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python sv_to_defines.py <input_file> [output_file]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    process_file(input_file, output_file)
