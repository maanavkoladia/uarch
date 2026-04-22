#!/usr/bin/env python3
"""
ICache_Startup_Gen.py
---------------------
Generates a Verilog file containing a single `initial begin` block that
zeroes (or randomises) every ram8b8w$ cell in the ICache at simulation start.

Usage:
    python3 ICache_Startup_Gen.py <icache_conf.json>

Conf keys:
    readmemFilePath          – output filename  (e.g. "icache_loader.sv")
    outputPath               – directory to write the file into
    TagStoreCellPath         – path template for tag store cells; literal substrings
                               "<Layer>"    → replaced with layer index
                               "<NumCells>" → replaced with cell index
    numTagStore_Layers       – number of tag store layers   (outer genvar)
    numTagStore_Cells        – number of tag store cells    (inner genvar)
    numDataStore_CellLayers  – LAYERS_OF_CELLS  (outer genvar i)
    numDataStoreCells        – NUM_CELLS / CACHE_LINES_SIZE_B  (inner genvar j)
    dataStoreCellPath        – path template; literal substrings
                               "<cell layer>" → replaced with i
                               "<cellNum>"    → replaced with j
    startUpDelay             – single delay inserted once at top of initial begin
    loadRandomData           – (optional) "true" → fill each word with a random
                               8-bit hex value instead of 8'h00.
                               Any other value (or omitted) → zero-fill.

Cell structure (ram8b8w$):
    8 words × 8 bits  →  mem[0] .. mem[7]

Generated Verilog is fully unrolled — no for-loops, no generate blocks.
Every mem[] assignment is an explicit statement so VCS has no issues.

Total writes emitted:
    numTagStore_Layers × numTagStore_Cells × 8   (tag store)
    numDataStore_CellLayers × numDataStoreCells × 8  (data store)
"""

import json
import random
import re
import sys
from pathlib import Path

# Every ram8b8w$ has exactly 8 addressable words.
WORDS_PER_CELL = 8

REQUIRED_KEYS = [
    "readmemFilePath",
    "outputPath",
    "TagStoreCellPath",
    "numTagStore_Layers",
    "numTagStore_Cells",
    "numDataStore_CellLayers",
    "numDataStoreCells",
    "dataStoreCellPath",
    "startUpDelay",
]

# ---------------------------------------------------------------------------
# Conf loader
# ---------------------------------------------------------------------------

def load_conf(path: str) -> dict:
    p = Path(path)
    if not p.exists():
        print(f"[ERROR] ICache_Startup_Gen: conf not found: {p}")
        sys.exit(1)
    try:
        conf = json.loads(p.read_text())
    except json.JSONDecodeError as exc:
        print(f"[ERROR] ICache_Startup_Gen: bad JSON in conf: {exc}")
        sys.exit(1)
    missing = [k for k in REQUIRED_KEYS if k not in conf]
    if missing:
        print(f"[ERROR] ICache_Startup_Gen: missing conf keys: {missing}")
        sys.exit(1)
    return conf


def _is_random_mode(conf: dict) -> bool:
    """Return True when loadRandomData is explicitly set to the string 'true'."""
    return str(conf.get("loadRandomData", "false")).strip().lower() == "true"

# ---------------------------------------------------------------------------
# Generation helpers
# ---------------------------------------------------------------------------

def _cell_value(random_mode: bool) -> str:
    """Return a Verilog 8-bit literal — random hex or zero."""
    if random_mode:
        return f"8'h{random.randint(0, 0xFF):02X}"
    return "8'h00"


def _zero_cell_lines(hier_path: str, random_mode: bool) -> list[str]:
    """
    Return one fully-explicit assignment per word in a ram8b8w$ cell.
    No loops — each line is a standalone statement.
    """
    path = hier_path.strip()
    return [
        f"    {path}[{w}] = {_cell_value(random_mode)};"
        for w in range(WORDS_PER_CELL)
    ]


def _resolve_tag(template: str, layer: int, cell: int) -> str:
    """Substitute <Layer> and <NumCells> placeholders in a tag store path template."""
    result = template.replace("<Layer>", str(layer))
    result = result.replace("<NumCells>", str(cell))
    return result


def _resolve_data(template: str, layer: int, cell: int) -> str:
    """Substitute <cell layer> and <cellNum> placeholders in a data store path template.
    Handles both well-formed [<cellNum>] and the malformed [<cellNum] variant."""
    result = template.replace("<cell layer>", str(layer))
    # Accept both [<cellNum>] (correct) and [<cellNum] (missing closing >) from conf.
    result = re.sub(r'\[<cellNum>?\]', f'[{cell}]', result)
    return result

# ---------------------------------------------------------------------------
# Top-level generator
# ---------------------------------------------------------------------------

def generate(conf: dict) -> str:
    delay           = conf["startUpDelay"].strip()
    tag_tmpl        = conf["TagStoreCellPath"].strip()
    num_tag_layers  = int(conf["numTagStore_Layers"])
    num_tag_cells   = int(conf["numTagStore_Cells"])
    num_data_layers = int(conf["numDataStore_CellLayers"])
    num_data_cells  = int(conf["numDataStoreCells"])
    data_tmpl       = conf["dataStoreCellPath"].strip()
    random_mode     = _is_random_mode(conf)

    module_name = Path(conf["readmemFilePath"].strip()).stem

    lines: list[str] = []

    fill_desc = "random 8-bit values" if random_mode else "zeroes"
    lines += [
        "// Auto-generated by ICache_Startup_Gen.py — do not edit by hand.",
        f"// Fills every ram8b8w$ cell in the ICache with {fill_desc} at simulation start.",
        "// All assignments are fully unrolled (no loops) for VCS compatibility.",
        "",
        f"module {module_name};",
        "",
        "initial begin",
        "",
        f"    #{delay};",
        "",
    ]

    # ── Tag Store – fully unrolled over [layer][cell][word] ────────────────
    lines.append("    // Tag Store")
    for i in range(num_tag_layers):
        lines.append(f"    // g_tagStore_Layers[{i}]")
        for j in range(num_tag_cells):
            path = _resolve_tag(tag_tmpl, i, j)
            lines.append(f"    // g_tagStore_Cells[{j}]")
            lines += _zero_cell_lines(path, random_mode)
        lines.append("")

    # ── Data Store – fully unrolled over [layer][cell][word] ───────────────
    lines.append("    // Data Store")
    for i in range(num_data_layers):
        lines.append(f"    // g_mem_layer[{i}]")
        for j in range(num_data_cells):
            path = _resolve_data(data_tmpl, i, j)
            lines.append(f"    // g_memCells[{j}]")
            lines += _zero_cell_lines(path, random_mode)
        lines.append("")

    lines += ["end", "", "endmodule", ""]

    return "\n".join(lines)

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: ICache_Startup_Gen.py <icache_conf.json>")
        return 2

    conf            = load_conf(sys.argv[1])
    random_mode     = _is_random_mode(conf)
    out_dir         = Path(conf["outputPath"].strip())
    out_file        = out_dir / conf["readmemFilePath"].strip()

    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        print(f"[ERROR] ICache_Startup_Gen: cannot create output dir {out_dir}: {exc}")
        return 1

    verilog = generate(conf)

    try:
        out_file.write_text(verilog)
    except OSError as exc:
        print(f"[ERROR] ICache_Startup_Gen: cannot write {out_file}: {exc}")
        return 1

    num_tag_layers  = int(conf["numTagStore_Layers"])
    num_tag_cells   = int(conf["numTagStore_Cells"])
    num_data_layers = int(conf["numDataStore_CellLayers"])
    num_data_cells  = int(conf["numDataStoreCells"])
    tag_total       = num_tag_layers * num_tag_cells * WORDS_PER_CELL
    data_total      = num_data_layers * num_data_cells * WORDS_PER_CELL

    print(f"[ICache_Startup_Gen] written → {out_file.resolve()}")
    print(f"  tag store path  : {conf['TagStoreCellPath'].strip()}")
    print(f"  tag layers      : {num_tag_layers}")
    print(f"  tag cells/layer : {num_tag_cells}")
    print(f"  data layers     : {num_data_layers}")
    print(f"  data cells/layer: {num_data_cells}")
    print(f"  startup delay   : #{conf['startUpDelay'].strip()}")
    print(f"  fill mode       : {'RANDOM' if random_mode else 'ZERO'}")
    print(f"  total tag writes : {tag_total}  "
          f"({num_tag_layers}×{num_tag_cells} cells × {WORDS_PER_CELL} words)")
    print(f"  total data writes: {data_total}  "
          f"({num_data_layers}×{num_data_cells} cells × {WORDS_PER_CELL} words)")
    print(f"  total writes     : {tag_total + data_total}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
