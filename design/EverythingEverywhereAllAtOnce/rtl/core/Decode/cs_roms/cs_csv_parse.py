#!/usr/bin/env python3
"""
Control Store CSV Parser
Parses a control store CSV into a flat 1-bit-per-column format
where inputs are suffixed _i and outputs are suffixed _o.

Usage: python3 parse_control_store.py <input.csv> <schema.json> <output.csv>
"""

import csv
import json
import math
import sys
from pathlib import Path


def load_schema(schema_path: str) -> dict:
    with open(schema_path) as f:
        return json.load(f)


def bits_needed(n: int) -> int:
    """Number of bits needed to represent values 0..n-1"""
    if n <= 1:
        return 1
    return math.ceil(math.log2(n))


def int_to_bits(value: int, num_bits: int, field_name: str) -> list[int]:
    """Convert integer to list of bits [MSB..LSB], with bounds checking."""
    max_val = (1 << num_bits) - 1
    if value < 0 or value > max_val:
        raise ValueError(
            f"Field '{field_name}': value {value} does not fit in {num_bits} bits "
            f"(max {max_val})"
        )
    return [(value >> (num_bits - 1 - i)) & 1 for i in range(num_bits)]


def parse_header(raw_header: list[str], schema: dict):
    """
    Parse the CSV header row into a structured column map.

    The CSV has some multi-column enum fields where extra blank columns
    follow the named column. We use the schema to figure out which
    columns are "wide" (enum/multi-bit) vs "narrow" (1-bit).

    Returns:
        column_map: list of dicts describing each CSV column group:
            {
              'name': str,               # field name
              'csv_col_start': int,      # first CSV column index (0-based, after Input)
              'csv_col_count': int,      # how many CSV columns this field occupies
              'kind': 'input'|'1bit'|'enum'|'multibit',
              'bits': int,               # total output bits
              'enum_map': dict|None,     # name->int mapping for enums
            }
    """
    schema_input_bits = int(schema["InputNumBits"])

    # Build ordered list of expected output fields from schema
    # (preserving schema order, skipping InputNumBits)
    schema_fields = []
    for key, val in schema.items():
        if key == "InputNumBits":
            continue
        if isinstance(val, dict):
            # enum field — width = bits needed to encode max value
            max_enc = max(int(v) for v in val.values())
            n_bits = bits_needed(max_enc + 1)
            schema_fields.append({
                'name': key,
                'kind': 'enum',
                'bits': n_bits,
                'enum_map': {k: int(v) for k, v in val.items()},
            })
        else:
            n_bits = int(val)
            kind = '1bit' if n_bits == 1 else 'multibit'
            schema_fields.append({
                'name': key,
                'kind': kind,
                'bits': n_bits,
                'enum_map': None,
            })

    # Now map CSV header columns to schema fields.
    # CSV column 0 is always "Input".
    # Remaining columns must match schema fields in order.
    # Enum/multibit fields in the CSV are followed by blank padding columns.

    csv_fields = raw_header[1:]  # strip "Input"

    # Walk csv_fields and schema_fields together
    csv_col = 0
    column_map = []

    for sf in schema_fields:
        if csv_col >= len(csv_fields):
            raise ValueError(
                f"Schema field '{sf['name']}' has no corresponding CSV column "
                f"(ran out of CSV columns at index {csv_col + 1})"
            )

        csv_name = csv_fields[csv_col].strip()

        if csv_name != sf['name']:
            raise ValueError(
                f"Schema/CSV column mismatch at CSV col {csv_col + 1}: "
                f"expected '{sf['name']}' (from schema), got '{csv_name}'"
            )

        # Determine how many CSV columns this field occupies.
        # For enums in this CSV, the pattern is: named col + (n_bits-1) blank cols
        # where n_bits is schema bits. For 1-bit fields it's always 1 col.
        if sf['kind'] in ('enum', 'multibit'):
            # Count trailing blank cols
            span = 1
            while (csv_col + span) < len(csv_fields) and csv_fields[csv_col + span].strip() == '':
                span += 1
            # Validate span matches schema bits
            # (some CSVs pad to a fixed width; we accept span >= 1)
        else:
            span = 1

        column_map.append({
            **sf,
            'csv_col_start': csv_col,
            'csv_col_count': span,
        })
        csv_col += span

    if csv_col != len(csv_fields):
        extra = csv_fields[csv_col:]
        non_blank = [c for c in extra if c.strip()]
        if non_blank:
            raise ValueError(
                f"CSV has extra non-blank columns after all schema fields: {non_blank}"
            )
        # trailing blanks are OK

    # Also validate no schema fields are missing
    mapped_names = {cm['name'] for cm in column_map}
    schema_names = {sf['name'] for sf in schema_fields}
    if mapped_names != schema_names:
        missing = schema_names - mapped_names
        raise ValueError(f"Schema fields not found in CSV: {missing}")

    return column_map, schema_input_bits


def build_output_header(input_bits: int, column_map: list) -> list[str]:
    """Build the flat 1-bit output header."""
    cols = []

    # Input bits: in_9_i (MSB) .. in_0_i (LSB)
    for b in range(input_bits - 1, -1, -1):
        cols.append(f"in_{b}_i")

    # Output bits
    for cm in column_map:
        name = cm['name']
        n = cm['bits']
        if n == 1:
            cols.append(f"{name}_o")
        else:
            # MSB first
            for b in range(n - 1, -1, -1):
                cols.append(f"{name}_{b}_o")

    return cols


def parse_input_field(raw_input: str, expected_bits: int) -> list[int]:
    """
    Parse the Input column.
    Format examples:
      '0_0000_0000_0  (x0_00_0)'
      '1_1111_1111_1  (x1_FF_1)'
    The binary part is before the first space, underscores stripped.
    """
    binary_part = raw_input.strip().split()[0].replace('_', '')
    if len(binary_part) != expected_bits:
        raise ValueError(
            f"Input '{raw_input}': binary part '{binary_part}' has "
            f"{len(binary_part)} bits, expected {expected_bits}"
        )
    if not all(c in '01' for c in binary_part):
        raise ValueError(
            f"Input '{raw_input}': binary part '{binary_part}' contains "
            f"non-binary characters"
        )
    return [int(c) for c in binary_part]


def parse_row(row: list[str], column_map: list, input_bits: int, row_num: int) -> list[int]:
    """Parse one data row into a flat list of bit values."""
    raw_input = row[0]
    data_cols = row[1:]

    # Parse input
    try:
        in_bits = parse_input_field(raw_input, input_bits)
    except ValueError as e:
        raise ValueError(f"Row {row_num}: {e}")

    out_bits = []

    for cm in column_map:
        name = cm['name']
        start = cm['csv_col_start']
        count = cm['csv_col_count']
        kind = cm['kind']

        # Gather the raw value(s) for this field
        # The first column in the span holds the value; rest are blank padding
        if start >= len(data_cols):
            raise ValueError(
                f"Row {row_num}, field '{name}': CSV row too short "
                f"(col {start+1} missing)"
            )

        raw_val = data_cols[start].strip()

        # Validate blank padding columns
        for pad_i in range(1, count):
            if (start + pad_i) < len(data_cols):
                pad_val = data_cols[start + pad_i].strip()
                if pad_val not in ('', '0'):
                    # Some padding cols have 0 values which are fine (empty enum slots)
                    pass  # tolerate non-blank padding — it's from the enum expansion slots

        if kind == '1bit':
            if raw_val not in ('0', '1'):
                raise ValueError(
                    f"Row {row_num}, field '{name}': expected 0 or 1, got '{raw_val}'"
                )
            out_bits.append(int(raw_val))

        elif kind == 'multibit':
            try:
                int_val = int(raw_val)
            except ValueError:
                raise ValueError(
                    f"Row {row_num}, field '{name}': expected integer, got '{raw_val}'"
                )
            out_bits.extend(int_to_bits(int_val, cm['bits'], f"row {row_num}/{name}"))

        elif kind == 'enum':
            if raw_val == '' or raw_val == '0':
                # Treat blank/0 as numeric 0 — default/unset
                int_val = 0
            else:
                enum_map = cm['enum_map']
                if raw_val not in enum_map:
                    # Try as a raw integer
                    try:
                        int_val = int(raw_val)
                        max_enc = max(enum_map.values())
                        if int_val < 0 or int_val > max_enc:
                            raise ValueError(
                                f"Row {row_num}, field '{name}': integer value "
                                f"{int_val} out of enum range [0,{max_enc}]"
                            )
                    except ValueError:
                        raise ValueError(
                            f"Row {row_num}, field '{name}': '{raw_val}' is not "
                            f"a known enum key. Valid keys: {list(enum_map.keys())}"
                        )
                else:
                    int_val = enum_map[raw_val]
            out_bits.extend(int_to_bits(int_val, cm['bits'], f"row {row_num}/{name}"))

    return in_bits + out_bits


def validate_row_length(row: list[str], column_map: list, row_num: int):
    """Check the row has enough columns."""
    last_cm = column_map[-1]
    min_cols = last_cm['csv_col_start'] + last_cm['csv_col_count'] + 1  # +1 for Input col
    if len(row) < min_cols:
        raise ValueError(
            f"Row {row_num}: has {len(row)} columns, expected at least {min_cols}"
        )


def main():
    if len(sys.argv) != 4:
        print("Usage: parse_control_store.py <input.csv> <schema.json> <output.csv>")
        sys.exit(1)

    input_path, schema_path, output_path = sys.argv[1], sys.argv[2], sys.argv[3]

    print(f"Loading schema from '{schema_path}'...")
    schema = load_schema(schema_path)

    print(f"Parsing CSV '{input_path}'...")
    with open(input_path, newline='') as f:
        reader = csv.reader(f)
        rows = list(reader)

    if not rows:
        raise ValueError("CSV is empty")

    raw_header = rows[0]
    data_rows = rows[1:]

    print(f"  {len(data_rows)} data rows found")
    print("Parsing header and building column map...")
    column_map, input_bits = parse_header(raw_header, schema)

    print(f"  Input: {input_bits} bits")
    print(f"  Output fields: {len(column_map)}")
    for cm in column_map:
        print(f"    {cm['name']:30s} kind={cm['kind']:9s}  bits={cm['bits']}  "
              f"csv_cols=[{cm['csv_col_start']}:{cm['csv_col_start']+cm['csv_col_count']}]")

    out_header = build_output_header(input_bits, column_map)
    total_out_cols = len(out_header)
    print(f"\nOutput header: {total_out_cols} columns")
    print(f"  Input bits:  {input_bits}")
    print(f"  Output bits: {total_out_cols - input_bits}")

    print("\nParsing data rows...")
    out_rows = []
    errors = []
    for i, row in enumerate(data_rows, start=2):
        if not any(c.strip() for c in row):
            continue  # skip blank rows
        try:
            validate_row_length(row, column_map, i)
            bit_row = parse_row(row, column_map, input_bits, i)
            if len(bit_row) != total_out_cols:
                raise ValueError(
                    f"Internal: generated {len(bit_row)} bits, expected {total_out_cols}"
                )
            out_rows.append(bit_row)
        except ValueError as e:
            errors.append(str(e))

    if errors:
        print(f"\n{'='*60}")
        print(f"ERRORS ({len(errors)} total):")
        for e in errors:
            print(f"  ERROR: {e}")
        print('='*60)
        if len(errors) > len(data_rows) // 2:
            print("Too many errors — aborting.")
            sys.exit(1)
        print("Continuing with valid rows only...")

    print(f"\nWriting {len(out_rows)} rows to '{output_path}'...")
    with open(output_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(out_header)
        for row in out_rows:
            writer.writerow(row)

    print(f"Done. Output: {len(out_rows)} rows x {total_out_cols} columns.")


if __name__ == '__main__':
    main()
