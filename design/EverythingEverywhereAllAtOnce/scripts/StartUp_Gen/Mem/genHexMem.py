#!/usr/bin/env python3
"""
genHexMem.py
------------
Stage 2 of the memGen pipeline.

Reads the flat binary produced by compile.py and generates loadable
$readmemh hex files for each memCell module.

Memory architecture
───────────────────
  Total memory : 32 KB  (configurable via mem_size_bytes)
  Banks        : 64     (configurable via num_banks)
  Cache line   : 16 B   (configurable via cache_line_bytes)
  memCells/bank: 4      (configurable via cells_per_bank)

Interleaving (at cache-line granularity)
  $line N  →  bank  (N % num_banks)
           →  local line index inside that bank = N // num_banks

Each cache line (16 B) is split across 4 memCells:
  cell 0 : bytes [0:3]
  cell 1 : bytes [4:7]
  cell 2 : bytes [8:11]
  cell 3 : bytes [12:15]

Output files
  <loadDir>/mem_<bank>_<cell>.hex   – one per (bank, cell) pair
  Each file has <lines_per_bank> entries, one 32-bit word per line (8 hex chars).
  A readmemh address tag is written at the top so the simulator can
  map the file directly: @0000 .. @001f for 32 lines.

Debug / meta outputs (written to metaDir)
  interleave_map.txt   – shows which global line goes to which bank/local-line
  bank_<N>_layout.hex  – human-readable full layout for each bank (optional,
                          controlled by debug_bank_layouts flag)

JSON config keys consumed here
  output_metaData_Path     : directory containing program.bin (from compile.py)
  output_LoadableHex_Path  : directory for mem_<bank>_<cell>.hex files
  mem_size_bytes           : (optional) default 32768
  num_banks                : (optional) default 64
  cache_line_bytes         : (optional) default 16
  cells_per_bank           : (optional) default 4
  debug_bank_layouts       : (optional) "true"/"false", default "false"
"""

import json, sys, os, argparse, struct

# ── defaults ─────────────────────────────────────────────────────────────────
DEFAULT_MEM_SIZE    = 32 * 1024
DEFAULT_NUM_BANKS   = 64
DEFAULT_LINE_BYTES  = 16
DEFAULT_CELLS       = 4    # must divide cache_line_bytes evenly

# ── helpers ──────────────────────────────────────────────────────────────────

def load_config(path: str) -> dict:
    with open(path) as f:
        return json.load(f)

def make_dir(p: str):
    os.makedirs(p, exist_ok=True)

# ── core mapping ──────────────────────────────────────────────────────────────

def build_bank_tables(image: bytearray,
                      num_banks:  int,
                      line_bytes: int,
                      cells:      int) -> dict:
    """
    Returns a dict:
      bank_tables[bank][cell] = list of 4-byte words (one per local line)

    Interleave rule:
      global_line N  →  bank = N % num_banks
                        local_line inside bank = N // num_banks

    Cell split rule (for a 16-byte line, 4 cells, 4 bytes each):
      cell k  →  bytes [k*cell_width : (k+1)*cell_width] of the line
    """
    total_bytes  = len(image)
    total_lines  = total_bytes // line_bytes
    lines_per_bank = total_lines // num_banks

    if total_lines % num_banks != 0:
        sys.exit(f"[genHexMem] total_lines ({total_lines}) not divisible by "
                 f"num_banks ({num_banks}). Check mem_size_bytes / num_banks.")

    cell_width = line_bytes // cells   # bytes per cell per line
    if line_bytes % cells != 0:
        sys.exit(f"[genHexMem] cache_line_bytes ({line_bytes}) not divisible "
                 f"by cells_per_bank ({cells}).")

    # initialise empty tables
    bank_tables = {
        b: {c: [] for c in range(cells)}
        for b in range(num_banks)
    }

    for global_line in range(total_lines):
        bank       = global_line % num_banks
        # local_line = global_line // num_banks   (sequential fill inside bank)
        addr       = global_line * line_bytes
        line_data  = image[addr : addr + line_bytes]

        for c in range(cells):
            word_bytes = line_data[c * cell_width : (c + 1) * cell_width]
            bank_tables[bank][c].append(bytes(word_bytes))

    return bank_tables, lines_per_bank, cell_width


# ── readmemh writers ──────────────────────────────────────────────────────────

def write_cell_hex(words: list, cell_width: int,
                   bank: int, cell: int,
                   out_path: str):
    """
    Write a $readmemh-compatible file for one (bank, cell) memCell module.
    Each word is stored little-endian in the binary; we unpack it as a
    uint32-LE and re-emit it as a plain hex integer so $readmemh sees the
    architecturally-correct value.
    """
    fmt = {1: 'B', 2: '<H', 4: '<I', 8: '<Q'}.get(cell_width)
    if fmt is None:
        raise ValueError(f"Unsupported cell_width={cell_width}; "
                         f"expected 1/2/4/8 bytes")
    hex_digits = cell_width * 2          # e.g. 8 hex chars for 4-byte word

    with open(out_path, 'w') as f:
        for word in words:
            value = struct.unpack(fmt, word)[0]
            f.write(f'{value:0{hex_digits}x}\n')


# ── debug writers ─────────────────────────────────────────────────────────────

def write_interleave_map(image: bytearray,
                         num_banks:  int,
                         line_bytes: int,
                         out_path:   str):
    """
    Human-readable table showing the global→bank mapping.
    """
    total_lines = len(image) // line_bytes
    with open(out_path, 'w') as f:
        f.write(f"// Interleave map  total_lines={total_lines}  "
                f"num_banks={num_banks}  line_bytes={line_bytes}\n")
        f.write(f"// {'global_line':>12}  {'addr':>8}  {'bank':>6}  "
                f"{'local_line':>10}  all_16_bytes\n\n")
        for gl in range(total_lines):
            addr       = gl * line_bytes
            bank       = gl % num_banks
            local_line = gl // num_banks
            preview    = ' '.join(f'{b:02x}' for b in image[addr:addr+16])
            f.write(f"  {gl:>12d}  0x{addr:04x}  {bank:>6d}  "
                    f"{local_line:>10d}  {preview}\n")
    print(f"[genHexMem] Wrote interleave map → {out_path}")


def write_bank_layout(bank: int, cells: int,
                      words_per_cell: list,
                      cell_width: int,
                      line_bytes: int,
                      num_banks: int,
                      out_path: str):
    """
    Human-readable layout of one bank: shows all local lines and
    how each is split across cells.
    """
    n_lines = len(words_per_cell[0])
    with open(out_path, 'w') as f:
        f.write(f"// Bank {bank} layout  local_lines={n_lines}  "
                f"cells={cells}  cell_width={cell_width}B\n")
        f.write(f"// global_line = (local_line * {num_banks}) + {bank}\n\n")
        f.write(f"  {'local_ln':>8}  {'global_ln':>9}  "
                + '  '.join(f'cell_{c}({cell_width*8}b)' for c in range(cells))
                + '\n\n')
        for ll in range(n_lines):
            gl = ll * num_banks + bank
            cell_strs = [''.join(f'{b:02x}' for b in words_per_cell[c][ll])
                         for c in range(cells)]
            f.write(f"  {ll:>8d}  {gl:>9d}  " + '  '.join(cell_strs) + '\n')


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(
        description="Stage 2: flat binary → interleaved bank memCell hex files")
    ap.add_argument('config', help='Path to JSON config file')
    args = ap.parse_args()

    cfg = load_config(args.config)

    meta_dir    = cfg['output_metaData_Path']
    load_dir    = cfg['output_LoadableHex_Path']
    mem_size    = int(cfg.get('mem_size_bytes',   DEFAULT_MEM_SIZE))
    num_banks   = int(cfg.get('num_banks',        DEFAULT_NUM_BANKS))
    line_bytes  = int(cfg.get('cache_line_bytes', DEFAULT_LINE_BYTES))
    cells       = int(cfg.get('cells_per_bank',   DEFAULT_CELLS))
    dbg_layouts = cfg.get('debug_bank_layouts', 'false').strip().lower() == 'true'

    make_dir(load_dir)
    make_dir(meta_dir)

    bin_path = os.path.join(meta_dir, 'program.bin')
    if not os.path.exists(bin_path):
        sys.exit(f"[genHexMem] program.bin not found at {bin_path}. "
                 f"Run compile.py first.")

    with open(bin_path, 'rb') as f:
        image = bytearray(f.read())

    if len(image) != mem_size:
        print(f"[genHexMem] WARNING: binary size {len(image)} B != "
              f"mem_size_bytes {mem_size} B. Truncating/padding.")
        if len(image) < mem_size:
            image += bytearray(mem_size - len(image))
        else:
            image = image[:mem_size]

    total_lines    = mem_size // line_bytes
    lines_per_bank = total_lines // num_banks
    cell_width     = line_bytes // cells

    print(f"[genHexMem] mem={mem_size}B  banks={num_banks}  "
          f"line={line_bytes}B  cells={cells}  cell_width={cell_width}B")
    print(f"[genHexMem] total_lines={total_lines}  "
          f"lines_per_bank={lines_per_bank}")

    # ── build bank tables ────────────────────────────────────────────────────
    bank_tables, lines_per_bank, cell_width = build_bank_tables(
        image, num_banks, line_bytes, cells)

    # ── write loadable hex files ─────────────────────────────────────────────
    for bank in range(num_banks):
        for cell in range(cells):
            fname    = f"mem_{bank}_{cell}.hex"
            out_path = os.path.join(load_dir, fname)
            write_cell_hex(bank_tables[bank][cell], cell_width,
                           bank, cell, out_path)
    print(f"[genHexMem] Wrote {num_banks * cells} hex files → {load_dir}")

    # ── debug: interleave map ────────────────────────────────────────────────
    write_interleave_map(image, num_banks, line_bytes,
                         os.path.join(meta_dir, 'interleave_map.txt'))

    # ── debug: per-bank layout (optional) ────────────────────────────────────
    if dbg_layouts:
        bank_dbg_dir = os.path.join(meta_dir, 'bank_layouts')
        make_dir(bank_dbg_dir)
        for bank in range(num_banks):
            words_per_cell = [bank_tables[bank][c] for c in range(cells)]
            write_bank_layout(bank, cells, words_per_cell, cell_width,
                              line_bytes, num_banks,
                              os.path.join(bank_dbg_dir, f'bank_{bank}_layout.hex'))
        print(f"[genHexMem] Wrote bank layouts → {bank_dbg_dir}")

    print("[genHexMem] Done.")


if __name__ == '__main__':
    main()
