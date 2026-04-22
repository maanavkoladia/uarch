# memGen Pipeline

Two-stage tool that converts an x86-32 assembly program into loadable
`$readmemh` hex files for a banked, interleaved DRAM model.

---

## Memory Architecture

| Parameter         | Value  | Notes                              |
|-------------------|--------|------------------------------------|
| Total size        | 32 KB  | configurable `mem_size_bytes`      |
| Banks             | 64     | configurable `num_banks`           |
| Cache line        | 16 B   | configurable `cache_line_bytes`    |
| memCells per bank | 4      | configurable `cells_per_bank`      |
| Lines per bank    | 32     | = (32K/16) / 64                    |
| Bytes per cell    | 4      | = 16 / 4                           |

### Interleave Rule (cache-line granularity)

```
global_line N  →  bank       = N % 64
               →  local_line = N // 64
```

So line 0→bank0, line 1→bank1, …, line 63→bank63, line 64→bank0 again.

### Cell Split Rule (within a cache line)

```
cell 0 : bytes [0:3]   (bits 31:0   of the 128-bit line)
cell 1 : bytes [4:7]
cell 2 : bytes [8:11]
cell 3 : bytes [12:15]
```

### Output file naming

```
mem_<bank>_<cell>.hex    e.g. mem_0_0.hex  mem_63_3.hex
```

Each file is `$readmemh`-compatible with 32 entries (one per local line),
each entry being a 32-bit word (8 hex chars), addressed `@0000`–`@001f`.

---

## Scripts

### Stage 1 — `compile.py`

Assembles the `.s` source (via GNU `as` + `ld` for i386) into a flat
32 KB binary and produces three debug files.

**Requires:** `binutils` with i386 support (`as`, `ld`, `objcopy` on PATH).

```
python3 compile.py memGen.json
```

**Outputs (all in `output_metaData_Path`):**

| File                     | Description                                             |
|--------------------------|---------------------------------------------------------|
| `program.bin`            | Raw 32 KB flat image (input for stage 2)                |
| `program_flat.hex`       | Human-readable hex of full image, annotated by `$line`  |
| `program_sections.hex`   | Same, but only lines covering code + data regions       |
| `program_readmemh.hex`   | `$readmemh`-compatible flat image (byte-per-entry)      |

### Stage 2 — `genHexMem.py`

Reads `program.bin`, applies the interleave + cell-split mapping,
and emits all `mem_<bank>_<cell>.hex` files.

```
python3 genHexMem.py memGen.json
```

**Outputs:**

| Location                      | Description                                  |
|-------------------------------|----------------------------------------------|
| `output_LoadableHex_Path/`    | `mem_<B>_<C>.hex` for B in 0..63, C in 0..3 |
| `output_metaData_Path/interleave_map.txt` | Global line → bank/local-line table |
| `output_metaData_Path/bank_layouts/` | Per-bank human-readable layout (opt) |

---

## JSON Config Reference

```jsonc
{
    // --- program input ---
    "useProgram"              : "true",        // "true" = assemble .s, "false" = use hex
    "input_Program_Path"      : "memGen/testProg.s",
    "input_hex_file"          : "not_needed",  // used when useProgram = "false"

    // --- outputs ---
    "output_LoadableHex_Path" : "memGen/hexLoad/",
    "output_metaData_Path"    : "memGen/meta/",

    // --- memory behavior ---
    "randomizeMem"            : "true",        // randomize unused bytes (simulate real DRAM)

    // --- architecture (all optional, shown with defaults) ---
    "mem_size_bytes"          : 32768,         // 32 KB
    "num_banks"               : 64,
    "cache_line_bytes"        : 16,
    "cells_per_bank"          : 4,

    // --- debug ---
    "debug_bank_layouts"      : "false"        // "true" = write per-bank layout files
}
```

---

## Typical Verilog Testbench Usage

```verilog
// In your TB, one readmemh call per memCell instance
initial begin
    $readmemh("hexLoad/mem_0_0.hex",  bank0.cell0.mem);
    $readmemh("hexLoad/mem_0_1.hex",  bank0.cell1.mem);
    // ...
    $readmemh("hexLoad/mem_63_3.hex", bank63.cell3.mem);
end
```

Each `.hex` file word corresponds to `mem[local_line]` inside that cell.

---

## Full Run

```bash
python3 compile.py   memGen.json
python3 genHexMem.py memGen.json
```
