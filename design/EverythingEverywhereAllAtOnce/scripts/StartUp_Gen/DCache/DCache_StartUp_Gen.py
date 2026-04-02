#!/usr/bin/env python3
"""
DCache_Startup_Gen.py
---------------------
Generates a Verilog file containing a single `initial begin` block that
fills every ram cell in the DCache at simulation start (zero or random).

Usage:
    python3 DCache_Startup_Gen.py <dcache_conf.json>

Conf keys:
    readmemFilePath      – output filename        (e.g. "dcache_loader.sv")
    outputPath           – directory to write into
    startUpDelay         – single delay at top of initial begin
    numBlocks            – number of dcache blocks
    numDataStoreCells    – data store cells per block, shared by bank AND vcache
    numBankLines         – words per bank ram cell        (ram8b8w$ → 8)
    numVCacheLines       – vcache tag store entry count   (outer generate loop)
                           also used as words per vcache DATA store cell (ram8b4w$ → 4)
    numCellsNeeded       – vcache tag store cells per entry (inner generate loop)
                           NUM_CELLS_NEEDED in RTL (typically 2)

    Bank_TagStorePath    – path template for bank tag store cell
    Bank_DataStorePath   – path template for bank data store cells
    VCache_TagStorePath  – path template for vcache tag store cells
                           must contain <numVCacheLines> and <numCellsNeeded>
                           tokens (iterated as entry index and cell index)
    VCache_DataStorePath – path template for vcache data store cells

    Path template tokens:
        <blockNum>       → block index          (0 .. numBlocks-1)
        <cellNum>        → data cell index      (0 .. numDataStoreCells-1)
        <numVCacheLines> → vcache tag entry idx (0 .. numVCacheLines-1)
        <numCellsNeeded> → vcache tag cell idx  (0 .. numCellsNeeded-1)

    loadRandomData       – (optional) "true" → random 8-bit value per word
                           Any other value / omitted → zero-fill.

Cell geometry:
    Bank  tag  store  : ram8b8w$  → numBankLines words   (1 cell / block)
    Bank  data store  : ram8b8w$  → numBankLines words   (numDataStoreCells / block)
    VCache tag  store : ram8b4w$  → numVCacheLines words (numVCacheLines entries ×
                                                           numCellsNeeded cells each)
    VCache data store : ram8b4w$  → numVCacheLines words (numDataStoreCells / block)

Generated Verilog is fully unrolled — no for-loops, no generate blocks.
Every mem[] assignment is an explicit statement so VCS has no issues.

Total writes emitted per block:
    bank  tag  : 1                × numBankLines
    bank  data : numDataStoreCells × numBankLines
    vcache tag : numVCacheLines   × numCellsNeeded × numVCacheLines  (words)
    vcache data: numDataStoreCells × numVCacheLines
"""

import json
import random
import re
import sys
from pathlib import Path

REQUIRED_KEYS = [
    "readmemFilePath",
    "outputPath",
    "startUpDelay",
    "numBlocks",
    "numDataStoreCells",
    "numBankLines",
    "numVCacheLines",
    "numCellsNeeded",
    "Bank_TagStorePath",
    "Bank_DataStorePath",
    "VCache_TagStorePath",
    "VCache_DataStorePath",
]

# ---------------------------------------------------------------------------
# Conf loader
# ---------------------------------------------------------------------------

def load_conf(path: str) -> dict:
    p = Path(path)
    if not p.exists():
        print(f"[ERROR] DCache_Startup_Gen: conf not found: {p}")
        sys.exit(1)
    try:
        conf = json.loads(p.read_text())
    except json.JSONDecodeError as exc:
        print(f"[ERROR] DCache_Startup_Gen: bad JSON in conf: {exc}")
        sys.exit(1)
    missing = [k for k in REQUIRED_KEYS if k not in conf]
    if missing:
        print(f"[ERROR] DCache_Startup_Gen: missing conf keys: {missing}")
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


def _resolve_bank(template: str, block: int, cell: int | None = None) -> str:
    """
    Resolve tokens for bank tag/data store paths:
        <blockNum>  → block index
        [<cellNum>] → [cell index]  (tolerates missing closing '>')
    """
    result = template.strip()
    result = result.replace("<blockNum>", str(block))
    if cell is not None:
        result = re.sub(r'\[<cellNum>?\]', f'[{cell}]', result)
    return result


def _resolve_vcache_tag(template: str, block: int, entry: int, cell: int) -> str:
    """
    Resolve tokens for vcache tag store paths (2D generate):
        <blockNum>       → block index
        <numVCacheLines> → entry index  (outer generate: g_tagStore_Entry)
        <numCellsNeeded> → cell index   (inner generate: g_tagStoreCell)
    Both [<tok>] and [<tok] (missing '>') are accepted.
    """
    result = template.strip()
    result = result.replace("<blockNum>", str(block))
    result = re.sub(r'\[<numVCacheLines>?\]', f'[{entry}]', result)
    result = re.sub(r'\[<numCellsNeeded>?\]',  f'[{cell}]',  result)
    return result


def _resolve_vcache_data(template: str, block: int, cell: int) -> str:
    """
    Resolve tokens for vcache data store paths:
        <blockNum>  → block index
        [<cellNum>] → [cell index]
    """
    return _resolve_bank(template, block=block, cell=cell)


def _cell_lines(hier_path: str, num_words: int, random_mode: bool) -> list[str]:
    """
    Return one fully-explicit assignment per word in a ram cell.
    No loops — each line is a standalone Verilog statement.
    """
    path = hier_path.strip()
    return [
        f"    {path}.mem[{w}] = {_cell_value(random_mode)};"
        for w in range(num_words)
    ]

# ---------------------------------------------------------------------------
# Top-level generator
# ---------------------------------------------------------------------------

def generate(conf: dict) -> str:
    delay            = conf["startUpDelay"].strip()
    num_blocks       = int(conf["numBlocks"])
    num_cells        = int(conf["numDataStoreCells"])
    bank_words       = int(conf["numBankLines"])
    vcache_words     = int(conf["numVCacheLines"])   # words/cell AND entry count
    num_cells_needed = int(conf["numCellsNeeded"])   # inner tag store loop
    random_mode      = _is_random_mode(conf)

    tmpl_bank_tag    = conf["Bank_TagStorePath"]
    tmpl_bank_data   = conf["Bank_DataStorePath"]
    tmpl_vcache_tag  = conf["VCache_TagStorePath"]
    tmpl_vcache_data = conf["VCache_DataStorePath"]

    module_name = Path(conf["readmemFilePath"].strip()).stem
    fill_desc   = "random 8-bit values" if random_mode else "zeroes"

    lines: list[str] = []

    lines += [
        "// Auto-generated by DCache_Startup_Gen.py — do not edit by hand.",
        f"// Fills every ram cell in the DCache with {fill_desc} at simulation start.",
        "// All assignments are fully unrolled (no loops) for VCS compatibility.",
        "",
        f"// Geometry : {num_blocks} block(s)",
        f"//   Bank   : 1 tag cell × {bank_words} words",
        f"//            {num_cells} data cells × {bank_words} words",
        f"//   VCache : {vcache_words} tag entries × {num_cells_needed} cells × {vcache_words} words",
        f"//            {num_cells} data cells × {vcache_words} words",
        "",
        f"module {module_name};",
        "",
        "initial begin",
        "",
        f"    #{delay};",
        "",
    ]

    for b in range(num_blocks):
        lines += [
            f"    // =========================================================",
            f"    // Block [{b}]",
            f"    // =========================================================",
            "",
        ]

        # ── Bank Tag Store  (1 cell, ram8b8w$) ────────────────────────────
        lines.append(f"    // Block [{b}] – Bank Tag Store")
        path = _resolve_bank(tmpl_bank_tag, block=b)
        lines += _cell_lines(path, bank_words, random_mode)
        lines.append("")

        # ── Bank Data Store  (numDataStoreCells cells, ram8b8w$) ──────────
        lines.append(f"    // Block [{b}] – Bank Data Store")
        for c in range(num_cells):
            path = _resolve_bank(tmpl_bank_data, block=b, cell=c)
            lines.append(f"    // g_dcache_bank_data_store_ram_cells[{c}]")
            lines += _cell_lines(path, bank_words, random_mode)
        lines.append("")

        # ── VCache Tag Store  (numVCacheLines × numCellsNeeded, ram8b4w$) ─
        # Mirrors the RTL generate structure:
        #   for (genvar i = 0; i < VCACHE_NUM_LINES;  i++) : g_tagStore_Entry
        #     for (genvar j = 0; j < NUM_CELLS_NEEDED; j++) : g_tagStoreCell
        lines.append(f"    // Block [{b}] – VCache Tag Store")
        for entry in range(vcache_words):
            lines.append(f"    // g_tagStore_Entry[{entry}]")
            for cell in range(num_cells_needed):
                path = _resolve_vcache_tag(tmpl_vcache_tag, block=b,
                                           entry=entry, cell=cell)
                lines.append(f"    // g_tagStoreCell[{cell}]")
                lines += _cell_lines(path, vcache_words, random_mode)
        lines.append("")

        # ── VCache Data Store  (numDataStoreCells cells, ram8b4w$) ────────
        lines.append(f"    // Block [{b}] – VCache Data Store")
        for c in range(num_cells):
            path = _resolve_vcache_data(tmpl_vcache_data, block=b, cell=c)
            lines.append(f"    // g_vcache_data_store_ram_cells[{c}]")
            lines += _cell_lines(path, vcache_words, random_mode)
        lines.append("")

    lines += ["end", "", "endmodule", ""]

    return "\n".join(lines)

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: DCache_Startup_Gen.py <dcache_conf.json>")
        return 2

    conf        = load_conf(sys.argv[1])
    random_mode = _is_random_mode(conf)
    out_dir     = Path(conf["outputPath"].strip())
    out_file    = out_dir / conf["readmemFilePath"].strip()

    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        print(f"[ERROR] DCache_Startup_Gen: cannot create output dir {out_dir}: {exc}")
        return 1

    verilog = generate(conf)

    try:
        out_file.write_text(verilog)
    except OSError as exc:
        print(f"[ERROR] DCache_Startup_Gen: cannot write {out_file}: {exc}")
        return 1

    num_blocks       = int(conf["numBlocks"])
    num_cells        = int(conf["numDataStoreCells"])
    bank_words       = int(conf["numBankLines"])
    vcache_words     = int(conf["numVCacheLines"])
    num_cells_needed = int(conf["numCellsNeeded"])

    vc_tag_writes    = vcache_words * num_cells_needed * vcache_words
    writes_per_block = (
        (1         * bank_words)   +   # bank  tag  store
        (num_cells * bank_words)   +   # bank  data store
        vc_tag_writes              +   # vcache tag store (2D)
        (num_cells * vcache_words)     # vcache data store
    )
    total_writes = num_blocks * writes_per_block

    print(f"[DCache_Startup_Gen] written → {out_file.resolve()}")
    print(f"  blocks                  : {num_blocks}")
    print(f"  bank  tag  cells/block  : 1")
    print(f"  bank  data cells/block  : {num_cells}")
    print(f"  bank  words/cell        : {bank_words}")
    print(f"  vcache tag entries      : {vcache_words}  (g_tagStore_Entry)")
    print(f"  vcache tag cells/entry  : {num_cells_needed}  (g_tagStoreCell)")
    print(f"  vcache tag/data words   : {vcache_words}")
    print(f"  vcache data cells/block : {num_cells}")
    print(f"  startup delay           : #{conf['startUpDelay'].strip()}")
    print(f"  fill mode               : {'RANDOM' if random_mode else 'ZERO'}")
    print(f"  writes/block            : {writes_per_block}")
    print(f"  total writes            : {total_writes}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
