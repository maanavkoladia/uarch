# Simulator Segment Awareness — Analysis Report

## Overview

This report documents exactly how the simulator (`sim.py` and friends) handles memory access, code traversal, and whether it supports the segmented-code model your core uses.

**Short answer:** The sim is **not currently segmented-aware** in any meaningful way for your use case.  
Segment registers and bases exist in the data structures but are largely ignored during execution.  
Multiple `.orig` directives are only partially handled.

---

## Phase 1 — Parsing & Assembly (parser.py)

### `.orig` / Section Placement

`_extract_orgs()` does a single linear scan of the source file and extracts **one** `text_org` and **one** `data_org`:

```python
text_org = 0x1000      # default if no .org found in .code/.text
data_org = 0x56559000  # default if no .org found in .data
```

It runs through every line and **overwrites** these values whenever it sees a new `.org`. This means:

- If you have **multiple** `.org` values inside the code section, only the **last one wins**.
- There is **no list** of multiple code origins — it's a single scalar.
- The resulting GNU `ld` linker script places the **entire `.text` section at a single base**:

```ld
. = 0x<text_org>;
.text : { *(.text) }
. = 0x<data_org>;
.data : { *(.data) }
```

There is **no mechanism** to place multiple disjoint code regions. Every `.orig` you write in the code section collapses into one start address.

### `.org` Stripping

Before assembling, the parser strips all `.org` directives from the processed source:

```python
processed = re.sub(r'^\s*\.org\s+(0x[0-9a-fA-F]+|\d+)\s*$', '', processed, flags=re.MULTILINE)
```

`gas` (GNU assembler) never sees the `.org` — only the linker script controls section placement.

---

## Phase 2 — Instruction Address Space (sim.py)

### Code Section Loaded

After assembly, the sim does **not** load code bytes into the physical memory array at all. Code is entirely represented by the `instructions[]` list and the `addr_to_idx` dictionary (a Python dict of `{virtual_address: index}`).

EIP is initialised to the first instruction's address as given by `objdump`:

```python
regs.eip = text_org  # later overridden to instructions[0].addr
```

### Code Fetch / PC Traversal

The main execution loop uses an integer `pc` (instruction index), **not** EIP, to fetch the next instruction:

```python
inst = instructions[pc]
regs.eip = inst.addr          # EIP updated to the instruction's linked address
next_eip = inst.addr + inst.size
regs.eip = next_eip           # EIP advanced past the instruction
...
pc += 1                        # actual fetch index
```

**Critical gap:** There is no `CS_base + EIP` → linear address translation anywhere in the fetch path. EIP is set to the absolute address that `objdump` reported after linking, and `pc` is just an array index. Even if you set `regs.seg_bases['cs']` to a non-zero value, it is **never added to EIP** during instruction fetch.

### Jump/Call Target Resolution

When a jump or call modifies EIP, the sim looks up the target in `addr_to_idx`:

```python
if target in addr_to_idx:
    pc = addr_to_idx[target]
else:
    # WARNING: Jump target not found — simulation stops
    break
```

Targets are the **absolute post-link addresses** that `objdump` emitted. There is no `CS_base + offset` computation — if your segment model intends `EIP = 0` to mean offset 0 within the CS segment (where CS base holds the actual physical/linear start), that math is never done.

---

## Phase 3 — Data Memory Access (execute.py + memory.py)

### Segment Data Structures (registers.py)

The register file has the structures:

```python
self.seg_bases  = {"cs": 0, "ds": 0, "ss": 0, "es": 0, "fs": 0, "gs": 0}
self.seg_limits = {"cs": 0xFFFFF, "ds": 0xFFFFF, "ss": 0xFFFFF,
                   "es": 0x00000, "fs": 0x00000, "gs": 0x00000}
```

These can be configured via `CoreRegs.conf.json` (for limits only — there is **no config path to set `seg_bases`** from a file at startup).

### `_read_operand` / `_write_operand` — The Core Gap

The general operand read/write functions in `execute.py`:

```python
def _read_operand(self, op, size_bytes):
    ...
    if op.typ == 'mem':
        addr = self._effective_addr(op)
        val, err = self.mem.read(addr, size_bytes)   # seg_base=0 always
        ...

def _write_operand(self, op, value, size_bytes):
    ...
    elif op.typ == 'mem':
        addr = self._effective_addr(op)
        err = self.mem.write(addr, size_bytes, value & mask)  # seg_base=0 always
```

`mem.read()` has a `seg_base=0` default parameter, and **`_read_operand` never passes one**. This means:

- `mov $0, %eax` followed by `mov (%eax), %ebx` computes `effective_addr = 0`, then calls `mem.read(0, 4)` — it accesses physical/linear address 0, **not** `DS_base + 0`.
- Segment override prefixes (e.g. `%es:(%edi)`) **are parsed** by `parser.py` into `op.seg_prefix`, but **`_read_operand` never reads `op.seg_prefix`** — that field is silently ignored.

### Where Segment Bases ARE Used

There are a few specific instructions that correctly apply segment bases:

| Instruction | Segment Applied |
|---|---|
| `MOVS` / `REP MOVS` | DS base → ESI source; ES base → EDI destination |
| `PUSH` / `POP` / `CALL` / `RET` (stack) | SS base → ESP |

These are the **only** paths where `seg_bases` are consulted. All other `MOV`, `ADD`, `LOAD`, etc. ignore them.

### Memory Translation Path

For the data that IS loaded (the `.data` section), the TLB maps:

```
virtual_addr (from .data .org) → physical_addr (identity-mapped automatically)
```

The `mem.read()` path is:

```
vaddr  →  linear = (seg_base + vaddr) & 0xFFFFFFFF
linear →  TLB translate  →  paddr
paddr  →  self.data[paddr]
```

If `seg_base=0` (which it always is for general instructions), then `linear = vaddr`, and the TLB lookup uses the virtual address directly. This only works because the sim auto-creates identity mappings for data — but the mapping is keyed to the virtual address as-is, not offset by a segment base.

---

## Summary Table

| Feature | Status |
|---|---|
| Multiple `.orig` in code section | **Not supported** — only last `.orig` used as `text_org` |
| CS:EIP segmented code fetch | **Not implemented** — CS base never added to EIP |
| Jump targets across segment base | **Not implemented** — jumps use raw linked addresses |
| DS/ES base for general data loads | **Not implemented** — `_read_operand` ignores seg_prefix and seg_bases |
| DS/ES base for `MOVS`/`REP MOVS` | **Implemented** |
| SS base for push/pop/call/ret | **Implemented** |
| Segment descriptor table (GDT/LDT) | **Not present** — seg_bases is a flat dict, not a descriptor table |
| `seg_limits` enforcement | **Not enforced** — limits are stored but never checked on access |
| Setting `seg_bases` from config | **No config path** — only `seg_limits` are loadable from `CoreRegs.conf.json` |

---

## What Needs to Change for Your Model

Your model says:
- EIP always starts at 0 (offset within CS)
- Every `.orig` is a virtual address
- Data access is relative to DS base
- The segment table maps virtual segment offset → physical/linear location

To properly support this, the sim needs:

1. **Multiple code `.orig` support**: `_extract_orgs` needs to produce a list of `(offset, label)` pairs for each `.orig` in the code section, and the linker script needs corresponding section placements (or a flat binary is loaded and the `addr_to_idx` is built from segment-offset addresses, not linked absolute addresses).

2. **CS base applied on fetch**: In the execution loop, instruction lookup should be `cs_base + eip_offset` → `addr_to_idx`, or alternatively the entire `instructions` list should store addresses as offsets from CS base.

3. **DS/SS/ES base in `_read_operand` / `_write_operand`**: These functions need to determine the applicable segment (default DS for data reads, SS for ESP-relative, ES for string destinations) and pass `seg_base` to `mem.read()`/`mem.write()`.

4. **Segment override prefix honored**: `op.seg_prefix` is already parsed — `_read_operand` just needs to use it:

    ```python
    seg = op.seg_prefix or 'ds'
    base = self.regs.seg_bases.get(seg, 0)
    val, err = self.mem.read(addr, size_bytes, seg_base=base)
    ```

5. **Segment table config**: A way to load `seg_bases` (not just limits) from the config, or derive them from the segment descriptor table your hardware maintains.
