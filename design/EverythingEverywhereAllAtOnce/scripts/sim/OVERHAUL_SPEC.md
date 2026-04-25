# Simulator Overhaul Specification — Segmented Memory Model

## 0. Purpose

This document is a complete, unambiguous specification for overhauling the x86-32 functional
simulator (`sim.py` and supporting files) to accurately model the segmented memory architecture
of the target core. It is intended to be handed to an LLM to implement with no additional
clarification needed.

---

## 1. Conceptual Architecture

### 1.1 Address Translation Pipeline

Every memory access (code fetch, data read, data write) goes through **three layers**:

```
logical/effective address  (produced by instruction)
          │
          │  Step 1 — Segment Limit Check  (skipped for SS)
          │  if effective_offset > seg_limits[seg]:  → #GP (Segment Limit Exception)
          │
          │  Step 2 — Segment Translation
          │  linear = (seg_reg_value << 16) + effective_offset
          ▼
      linear address  (32-bit)
          │
          │  Step 3 — TLB Translation
          │  vpn = linear >> 12  (top 20 bits)
          │  offset = linear & 0xFFF  (bottom 12 bits)
          │  pfn = TLB_lookup(vpn)    (3-bit, 0–7)
          │  paddr = (pfn << 12) | offset
          ▼
    physical address  (15-bit, 0x0000–0x7FFF)
          │
          │  Step 4 — Physical Memory
          │  value = mem[paddr : paddr+size]
          ▼
         value
```

**Segment register**: a 16-bit value stored in CS/DS/SS/ES/FS/GS.
**Segment base**: `seg_reg_value << 16` — this is the segment's base linear address.
**Effective offset**: computed from the instruction operand (base register + index*scale + displacement).
**Segment limit**: a 20-bit value per segment loaded from `CoreRegs.conf.json["SegLimitVals"]`, stored in `regs.seg_limits`. An effective offset exceeding this limit triggers a `#GP` exception **before** translation proceeds. The check is `effective_offset > seg_limits[seg_name]`.
**Linear address**: 32-bit result of `(seg_reg << 16) + effective_offset` (computed only after the limit check passes).
**TLB**: maps a 20-bit VPN to a 3-bit PFN. Physical memory is 32KB (8 frames × 4KB).
**Physical memory**: a 32KB `bytearray` loaded from `program.bin`.

### 1.2 Segment Defaults by Access Type

| Access type                         | Default segment |
|-------------------------------------|-----------------|
| Code fetch                          | CS              |
| Data load/store (most instructions) | DS              |
| Stack (ESP-relative, PUSH/POP)      | SS              |
| String destination (MOVS, STOS)     | ES              |
| String source (MOVS, LODS)          | DS              |
| Explicit override `%es:`, `%fs:` … | that segment    |

These follow standard x86-32 rules.

### 1.3 Segment Register Initialization

All segment registers start at **zero** (including CS, DS, SS, ES, FS, GS).
EIP starts at the value in `CoreRegs.conf.json["EIP"]["val"]` (parse the Verilog literal, e.g.
`"32'h00000000"` → 0).

The **program itself** is responsible for loading segment registers during its startup routine
(typically the first few instructions do `movl $__DS__, %eax; movw %ax, %ds; …`).
The simulator must faithfully execute those MOV-to-segment-register instructions.

The simulator must **NOT** pre-load segment registers from `memGen.conf.json` SegmentMappings.

### 1.5 Exception Hierarchy

The simulator raises two classes of memory-access exception, each surfaced as a `CPUException`
with a descriptive string:

| Exception | Trigger | Example message |
|---|---|---|
| `#GP` — Segment Limit | `effective_offset > seg_limits[seg]` (not SS) | `"#GP: DS offset 0x5000 exceeds limit 0xFFFFF"` |
| `#PF` — Page Fault | TLB entry `present=0` | `"#PF: VPN 0x40002 not present"` |
| `#PF` — TLB Miss | VPN not found in any TLB entry | `"#PF: VPN 0x40002 not in TLB"` |
| `#GP` — Physical OOB | `paddr >= 32768` | `"#GP: paddr 0x8100 out of physical range"` |

**SS is exempt from segment limit checking.** Stack accesses (push, pop, call, ret, and any
ESP/EBP-relative memory operand resolved under SS) bypass the limit check entirely and go
directly to TLB translation. This matches the project hardware specification.

**CS limit is checked on instruction fetch.** If `eip > seg_limits['cs']`, a `#GP` is raised
before the fetch attempt.

---

### 1.4 CS and Far Calls

CS starts at 0. EIP is always an **offset within CS** (not a linear address on its own).
The linear address of the next instruction is always `(CS << 16) + EIP`.
Far jumps (`ljmp`) and far calls (`lcall`) can modify CS; the simulator must handle this.

---

## 2. Input Files (Per Test Case)

Each test case lives in a folder. The sim is invoked with:

```
python3 sim.py --test-dir <path/to/test/case/folder> --bin <path/to/program.bin>
```

Fixed filenames inside `--test-dir`:

| File                | Purpose                                         |
|---------------------|-------------------------------------------------|
| `TLB.conf.json`     | TLB VPN→PFN mappings (same format as before)   |
| `CoreRegs.conf.json`| Initial EIP and segment limit values            |
| `memGen.conf.json`  | Informational; used only to read `mem_size_bytes` (should always be 32768) |

`program.bin` path is given explicitly via `--bin` because it lives under `gen/memGen/meta/`
relative to the test run directory, which may differ.

---

## 3. File-by-File Changes

### 3.1 `memory.py` — REWRITE

Replace entirely. New responsibilities:

1. Load `program.bin` into `self.data = bytearray(32768)`.
2. Load TLB from `TLB.conf.json` (same format as current — `num entries`, entries with
   `valid`, `present`, `r_w`, `MMIO`, `VPN`, `PFN`).
3. Expose `translate(linear_addr) -> (paddr, error_str|None)`.
4. Expose `read(effective_offset, size, seg_reg_val, seg_name, seg_limits, skip_limit=False) -> (value, error_str|None)`.
5. Expose `write(effective_offset, size, value, seg_reg_val, seg_name, seg_limits, skip_limit=False) -> error_str|None`.
   - `seg_name`: lowercase string e.g. `'ds'`, `'cs'` — used to look up the limit.
   - `seg_limits`: the `regs.seg_limits` dict.
   - `skip_limit`: set to `True` for SS-based accesses to bypass limit checking.

**`translate` implementation:**
```python
def translate(self, linear):
    vpn    = (linear >> 12) & 0xFFFFF   # top 20 bits
    offset = linear & 0xFFF              # bottom 12 bits
    for e in self.entries:
        if e['valid'] and e['vpn'] == vpn:
            if not e['present']:
                return None, f"Page fault: VPN 0x{vpn:05X} not present"
            paddr = (e['pfn'] << 12) | offset
            if paddr < 0 or paddr >= len(self.data):
                return None, f"GP fault: paddr 0x{paddr:X} out of range"
            return paddr, None
    return None, f"TLB miss: VPN 0x{vpn:05X} not found"
```

**`read` implementation:**
```python
def read(self, effective_offset, size, seg_reg_val, seg_name, seg_limits, skip_limit=False):
    # Step 1: Segment limit check (skip for SS per project spec)
    if not skip_limit:
        limit = seg_limits.get(seg_name, 0xFFFFF)
        if (effective_offset & 0xFFFFFFFF) > limit:
            return None, f"#GP: {seg_name.upper()} offset 0x{effective_offset:08X} exceeds limit 0x{limit:05X}"
    # Step 2: Segment translation
    linear = ((seg_reg_val & 0xFFFF) << 16) + (effective_offset & 0xFFFFFFFF)
    linear &= 0xFFFFFFFF
    # Step 3: TLB translation
    paddr, err = self.translate(linear)
    if err: return None, err
    # Step 4: Physical memory access
    if paddr + size > len(self.data):
        return None, f"#GP: paddr 0x{paddr:04X} + {size} overflows physical memory"
    val = int.from_bytes(self.data[paddr : paddr + size], 'little')
    return val, None
```

**`write` implementation:** mirror of `read` — same limit check (with `skip_limit`), then
compute linear, translate, write bytes. Return `error_str|None`.

**`translate` error strings** use `#PF` prefix for page-fault conditions:
- `present=0` → `"#PF: VPN 0x{vpn:05X} not present"`
- VPN not found → `"#PF: VPN 0x{vpn:05X} not in TLB"`
- Physical OOB → `"#GP: paddr 0x{paddr:X} out of physical range"`

**`load_from_bin(path)`** — open binary file, read exactly 32768 bytes into `self.data`.

**`load_tlb(path)`** — parse `TLB.conf.json`, populate `self.entries` list of dicts with keys
`valid`, `present`, `r_w`, `mmio`, `vpn`, `pfn` (parse Verilog literals like `"20'h00000"` and
`"3'h2"` using `int(s.split("'h")[1], 16)`).

**`fetch_bytes(eip, cs_reg_val, seg_limits, count=15) -> (bytes, error_str|None)`** — check
the CS segment limit first (`eip > seg_limits.get('cs', 0xFFFFF)` → return `(b'', "#GP: CS...")`),
then read `count` raw bytes from `((cs_reg_val << 16) + eip) & 0xFFFFFFFF` through the TLB.
Returns the bytes fetched and the first error encountered (or `None` if all bytes read cleanly).
SS limit check is **not** involved here — this is a CS fetch.

Remove all of: `TLB` class, `add_identity_mapping`, `load_data_section`,
`load_bytes_physical`, the `SIZE` constant as a class attribute (just use `len(self.data)`).

---

### 3.2 `parser.py` — REPLACE WITH `decoder.py`

Delete the old `parser.py` (GNU toolchain-based). Create a new file `decoder.py`.

**Purpose:** Given raw bytes and a linear address, use Capstone to decode a single x86-32
instruction and return a structured `Instruction` object compatible with the existing
`execute.py` dispatch table.

**Dependency:** `pip install capstone`

**`Instruction` class** — keep the same fields as the old one:
```
addr        int        linear address (for display/trace)
size        int        instruction byte size
mnemonic    str        lowercase, size-suffix stripped (e.g. "mov" not "movl")
operands    list       list of Operand
raw         str        human-readable string (e.g. "movl $0x1000, %eax")
size_suffix str|None   'b', 'w', 'l', 'q' or None
```

**`Operand` class** — same fields as old one:
```
typ         str        'imm' | 'reg' | 'mem'
imm_val     int|None
reg_name    str|None   lowercase, no '%'
base_reg    str|None   lowercase
index_reg   str|None   lowercase
scale       int        1/2/4/8
disp        int        signed displacement
seg_prefix  str|None   'cs'/'ds'/'ss'/'es'/'fs'/'gs' if explicit override
far_seg     int|None   for far pointers
far_off     int|None
```

**Capstone usage:**
```python
from capstone import *
from capstone.x86 import *
_CS = Cs(CS_ARCH_X86, CS_MODE_32)
_CS.detail = True
_CS.syntax = CS_OPT_SYNTAX_ATT   # AT&T syntax for mnemonic strings
```

**`decode_one(raw_bytes, linear_addr) -> Instruction | None`:**
```python
def decode_one(raw_bytes, linear_addr):
    for insn in _CS.disasm(raw_bytes, linear_addr, count=1):
        return _capstone_to_instruction(insn)
    return None
```

**`_capstone_to_instruction(insn) -> Instruction`:**

Use `insn.operands` (from Capstone detail) — do NOT parse the text representation.
Each `op` in `insn.operands` has `op.type`:
- `X86_OP_IMM` → `Operand('imm', imm_val=op.imm)`
- `X86_OP_REG` → `Operand('reg', reg_name=insn.reg_name(op.reg).lower())`
- `X86_OP_MEM`:
  ```
  base_reg  = insn.reg_name(op.mem.base).lower()  if op.mem.base  else None
  index_reg = insn.reg_name(op.mem.index).lower() if op.mem.index else None
  scale     = op.mem.scale
  disp      = op.mem.disp     # already signed int
  seg       = insn.reg_name(op.mem.segment).lower() if op.mem.segment else None
  # Filter out empty string register names (Capstone returns "" for "no register"):
  if base_reg  == "": base_reg  = None
  if index_reg == "": index_reg = None
  if seg       in ("", "cs", None) and this_is_code_fetch: seg = "cs"
  ```
  Build `Operand('mem', base_reg=base_reg, index_reg=index_reg, scale=scale, disp=disp, seg_prefix=seg)`

**Mnemonic normalization:**
- Use `insn.mnemonic` from Capstone (already lowercase).
- Strip AT&T size suffixes (`b`/`w`/`l`/`q`) using the same logic as the old `parse_objdump` —
  record the suffix in `size_suffix`, store the stripped mnemonic.
- Same exclusions apply: `hlt`, `nop`, mnemonics starting with `j`/`call`/`ret`/`cmov`, MMX
  mnemonics (`movq`, `movd`, `paddw`, …) do not get stripped.
- REP prefix: Capstone folds `rep movsb` into a single instruction with mnemonic `rep movsb`.
  The decoder should detect the `rep`/`repe`/`repne` prefix from `insn.prefix` or from
  `insn.mnemonic` starting with `"rep"`, and produce a mnemonic like `"rep_movs"` with the
  appropriate `size_suffix`, matching the existing handler names in `execute.py`.

**Branch instruction detection:** For `jmp`, `jcc`, `call`, `loop` the immediate operand from
Capstone is already the **absolute linear target address** — no further adjustment needed.

---

### 3.3 `execute.py` — TARGETED UPDATES ONLY

The instruction handler functions stay. Only the following plumbing changes:

#### 3.3.1 `_effective_addr`

No change needed — it still computes `disp + base_reg + index_reg*scale` from the operand
fields. This produces the **logical effective offset** (not yet a linear address). That is correct.

#### 3.3.2 `_read_operand`

Change the `mem` branch:

```python
if op.typ == 'mem':
    if op.far_seg is not None:
        raise CPUException("Cannot read far pointer")
    addr     = self._effective_addr(op)
    seg_name = self._resolve_seg_name(op, default='ds')
    seg_val  = self.regs.get(seg_name)
    val, err = self.mem.read(addr, size_bytes, seg_val,
                             seg_name, self.regs.seg_limits)
    if err:
        raise CPUException(err)
    return val
```

#### 3.3.3 `_write_operand`

Same change in the `mem` branch:

```python
elif op.typ == 'mem':
    addr     = self._effective_addr(op)
    seg_name = self._resolve_seg_name(op, default='ds')
    seg_val  = self.regs.get(seg_name)
    err = self.mem.write(addr, size_bytes, value & mask, seg_val,
                         seg_name, self.regs.seg_limits)
    if err:
        raise CPUException(err)
```

#### 3.3.4 New helpers `_resolve_seg` and `_resolve_seg_name`

```python
def _resolve_seg_name(self, op, default='ds'):
    """Return the segment register name ('ds', 'ss', …) for a memory operand."""
    return op.seg_prefix if op.seg_prefix else default

def _resolve_seg(self, op, default='ds'):
    """Return the 16-bit segment register value for a memory operand."""
    return self.regs.get(self._resolve_seg_name(op, default))
```

Both `seg_val` **and** `seg_name` must be passed to `mem.read`/`mem.write` so the limit check
can use the correct limit entry.

#### 3.3.5 Stack instructions (PUSH, POP, CALL, RET, ENTER, LEAVE)

These already use `ss_base = self.regs.seg_bases.get('ss', 0)`. Replace that line with:
```python
ss_val = self.regs.get('ss')
```
And call `mem.read`/`mem.write` with `seg_reg_val=ss_val`, `seg_name='ss'`,
`seg_limits=self.regs.seg_limits`, **`skip_limit=True`**.

**SS is exempt from segment limit exceptions** (project hardware specification). The
`skip_limit=True` flag bypasses the `#GP` limit check entirely for all stack operations.
TLB translation and physical memory bounds checks still apply.

#### 3.3.6 MOVS / REP MOVS

Replace:
```python
src_base = self.regs.seg_bases.get('ds', 0)
dst_base = self.regs.seg_bases.get('es', 0)
```
With:
```python
src_val = self.regs.get('ds')
dst_val = self.regs.get('es')
```
Pass `seg_reg_val=src_val, seg_name='ds', seg_limits=self.regs.seg_limits` to the source read.
Pass `seg_reg_val=dst_val, seg_name='es', seg_limits=self.regs.seg_limits` to the destination write.
Both DS and ES are subject to normal segment limit checking (`skip_limit=False`).

#### 3.3.7 Far JMP / Far CALL

On `ljmp seg:off`:
- Set `CS` register to `far_seg` (call `self.regs.set('cs', far_seg)`).
- Set `self.regs.eip = far_off & 0xFFFFFFFF`.
- Return `True` (EIP modified).

On `lcall seg:off`:
- Push current CS and EIP onto the SS:ESP stack.
- Then set CS and EIP as above.

These are important because CS can be changed at runtime.

#### 3.3.8 MOV to/from segment registers

`exec_mov` currently handles `MOV Sreg, r/m16` and `MOV r/m16, Sreg` by treating segment
registers as 16-bit regs. This already works via `regs.set('ds', val)` etc. because the
`RegisterFile.set` method handles `SREG` names. **No change needed.**

Remove the `seg_bases` dict from `CPU` — it no longer exists. All segment base computations
are done inside `memory.py` from the live `seg_reg_val` passed in.

---

### 3.4 `registers.py` — MINOR CLEANUP

Remove `self.seg_bases` from `RegisterFile.__init__`. It is no longer needed anywhere.
Keep `self.seg_limits` (used by CoreRegs config loading for verification).
Keep `self.sreg` as the authoritative store of current segment register values.
`regs.get('ds')` already returns `self.sreg[1] & 0xFFFF` — no change needed.

Update `dump()` to not include `seg_bases`.

---

### 3.5 `sim.py` — REWRITE MAIN LOOP + CONFIG LOADING

#### 3.5.1 CLI

```
python3 sim.py --test-dir PATH --bin PATH [--verbose] [--max-cycles N] [--dump-cycle N]
```

`--test-dir` is the folder containing `TLB.conf.json`, `CoreRegs.conf.json`, `memGen.conf.json`.
`--bin` is the path to `program.bin`.

Remove `--asm`, `--tlb`, `--core-regs`, `--config` flags (or keep `--config` as an alternative
that accepts a JSON with `test_dir` and `bin_path` keys for scripted runs).

#### 3.5.2 Initialization sequence

```python
def run_simulation(test_dir, bin_path, verbose, max_cycles, dump_cycle):
    regs  = RegisterFile()
    flags = Flags()
    mem   = Memory()

    # 1. Load physical memory
    mem.load_from_bin(bin_path)

    # 2. Load TLB
    mem.load_tlb(os.path.join(test_dir, "TLB.conf.json"))

    # 3. Load initial EIP and segment limits from CoreRegs.conf.json
    core_cfg = json.load(open(os.path.join(test_dir, "CoreRegs.conf.json")))
    if core_cfg["EIP"]["load"] == "true":
        eip_str = core_cfg["EIP"]["val"]      # e.g. "32'h00000000"
        regs.eip = int(eip_str.split("'h")[1], 16)
    if core_cfg["SegLimitVals"]["load"] == "true":
        sl = core_cfg["SegLimitVals"]
        for seg in ["CS","DS","SS","ES","FS","GS"]:
            if seg in sl:
                val_str = sl[seg][0]          # e.g. "20'hFFFFF"
                regs.seg_limits[seg.lower()] = int(val_str.split("'h")[1], 16)

    # 4. All segment registers start at 0 (already the case from RegisterFile.__init__)

    cpu = CPU(regs, flags, mem)
    trace = []

    # 5. Main execution loop (see 3.5.3)
```

#### 3.5.3 Main execution loop

Replace the old `instructions[]` / `addr_to_idx` approach entirely.

```python
while cpu.cycle < max_cycles:

    # --- Instruction Fetch ---
    eip     = regs.eip
    cs_val  = regs.get('cs')
    raw_bytes, fetch_err = mem.fetch_bytes(eip, cs_val, regs.seg_limits, count=15)

    if fetch_err or len(raw_bytes) == 0:
        print(f"[cycle {cpu.cycle}] Fetch fault at CS:EIP={cs_val:04X}:{eip:08X}: {fetch_err}")
        break

    linear_fetch = ((cs_val << 16) + eip) & 0xFFFFFFFF

    # --- Decode ---
    inst = decode_one(raw_bytes, linear_fetch)
    if inst is None:
        print(f"[cycle {cpu.cycle}] Decode failed at 0x{linear_fetch:08X}, halting.")
        break

    # --- Snapshot before ---
    snap_before = regs.dump()
    snap_before["flags"] = flags.dump()
    snap_before["cycle"] = cpu.cycle
    snap_before["instruction"] = str(inst)
    snap_before["raw"] = inst.raw
    snap_before["addr"] = linear_fetch

    # --- Advance EIP past instruction ---
    regs.eip = (eip + inst.size) & 0xFFFFFFFF

    # --- Execute ---
    try:
        eip_modified = cpu.execute(inst)
    except HaltException:
        # record trace entry, break
        ...
        cpu.halted = True
        break
    except CPUException as e:
        print(f"!!! EXCEPTION at cycle {cpu.cycle}, CS:EIP={cs_val:04X}:{eip:08X}: {e}")
        break

    # --- Snapshot after ---
    snap_after = regs.dump()
    snap_after["flags"] = flags.dump()
    trace.append({"before": snap_before, "after": snap_after})

    if verbose:
        print(f"[cycle {cpu.cycle:4d}] {cs_val:04X}:{eip:08X}: {inst.raw}")
        _print_changed(snap_before, snap_after)

    # --- EIP already advanced; if execute modified it (jump/call/ret), it set regs.eip ---
    # No addr_to_idx lookup needed; next iteration just fetches from new regs.eip

    cpu.cycle += 1
```

The `cpu.execute(inst)` contract is unchanged: returns `True` if EIP was directly modified
(jump/call/ret), `False` otherwise. When `False`, `regs.eip` already has the sequential value
set before the execute call. When `True`, the handler has written a new `regs.eip`.

Remove all of: `assemble_and_disassemble`, `parse_objdump`, `parse_data_from_source`,
`setup_from_args` (old), the GNU toolchain invocations, and the `addr_to_idx` dict.

---

### 3.6 Trace / `compare.py` — NO CHANGE

The trace format written by `_write_trace` and consumed by `compare.py` is unchanged.
`snap_before["addr"]` is now the **linear fetch address** (CS_base + EIP) rather than a
post-link ELF address — make sure `_write_trace` reads from `snap_before["addr"]` which it
already does.

---

## 4. Detailed Data Flow Walkthrough

Walk through the first meaningful instruction of `TheBigOne.s` after assembly.

### Program begins at CS:EIP = 0x0000:0x00000000

The assembly `.org 0x00000` means the code section starts at linear address 0x00000000.
TLB entry 0 maps VPN=0x00000 → PFN=2 → physical base 0x2000.
So instruction bytes for EIP=0 live at `mem.data[0x2000 : 0x2000+15]`.

### Fetching "movl $__DS__, %eax"

`raw_bytes = mem.fetch_bytes(eip=0, cs_val=0, count=15)`
→ `linear = (0<<16) + 0 = 0x00000000`
→ TLB: VPN=0x00000, PFN=2, paddr=0x2000
→ reads `mem.data[0x2000:0x200F]`

Capstone decodes: `movl $0x4000, %eax` (the preprocessor replaced `__DS__` with `0x4000`)
→ `Instruction(addr=0, size=5, mnemonic="mov", operands=[Operand('imm', imm_val=0x4000), Operand('reg', reg_name='eax')], size_suffix='l')`

Execute: `EAX ← 0x4000`. EIP advances to 5.

### "movw %ax, %ds"

Decodes to: `Instruction(mnemonic="mov", operands=[Operand('reg','ax'), Operand('reg','ds')])`
Execute: `DS ← AX = 0x4000`.
Now `regs.sreg[1] = 0x4000`. Subsequent data accesses use DS=0x4000.

### "movl $0x2000, %esi"

ESI ← 0x2000.

### "movl $0xA0A0A0A0, (%esi)"

Operand is `Operand('mem', disp=0, base_reg='esi')`.
`_effective_addr` → `0 + ESI = 0x2000`.
`_resolve_seg(op, default='ds')` → no `seg_prefix`, returns `regs.get('ds') = 0x4000`.
`mem.write(effective=0x2000, size=4, value=0xA0A0A0A0, seg_reg_val=0x4000)`:
→ `linear = (0x4000 << 16) + 0x2000 = 0x40002000`
→ TLB: VPN = 0x40002000 >> 12 = 0x40002, look up → PFN=? (configured in test TLB.conf.json)
→ `paddr = (PFN << 12) | 0x000`, write 4 bytes there.

---

## 5. Config File Reference

### `TLB.conf.json`

```json
{
    "num entries": "8",
    "entries": {
        "0": { "valid":"1", "present":"1", "r_w":"0", "MMIO":"0",
               "VPN":"20'h00000", "PFN":"3'h2" },
        ...
    }
}
```

Parsing: `int("20'h00000".split("'h")[1], 16)` for VPN, `int("3'h2".split("'h")[1], 16)` for PFN.
Ignore `"Module Name"`, `"outputPath"`, `"startUpDelay"`, `"num tlbs"`, `"paths"` keys.

### `CoreRegs.conf.json`

```json
{
    "EIP": { "load": "true", "val": "32'h00000000" },
    "SegLimitVals": {
        "load": "true",
        "CS": ["20'hFFFFF", "...path..."],
        ...
    }
}
```

Only read `EIP.load`, `EIP.val`, `SegLimitVals.load`, and `SegLimitVals.<SEG>[0]`.
Ignore `SPC`, `IDTR`, and the HDL path strings (second element of each seg array).

---

## 6. `Memory.fetch_bytes` Implementation Detail

This needs to handle the case where an instruction straddles a page boundary (rare but possible).
It also must check the CS segment limit before fetching.

```python
def fetch_bytes(self, eip, cs_val, seg_limits, count=15):
    # CS limit check — EIP must not exceed the CS segment limit
    cs_limit = seg_limits.get('cs', 0xFFFFF)
    if (eip & 0xFFFFFFFF) > cs_limit:
        return b'', f"#GP: CS EIP 0x{eip:08X} exceeds limit 0x{cs_limit:05X}"

    out = bytearray()
    first_err = None
    linear_base = ((cs_val & 0xFFFF) << 16) + (eip & 0xFFFFFFFF)
    for i in range(count):
        linear = (linear_base + i) & 0xFFFFFFFF
        paddr, err = self.translate(linear)
        if err:
            first_err = err   # return bytes fetched so far; caller halts if 0 bytes
            break
        out.append(self.data[paddr])
    return bytes(out), first_err
```

**Note:** `first_err` is only returned if the fetch aborts mid-stream (e.g. a page boundary
crosses into an unmapped page). The caller in `sim.py` halts if either `fetch_err` is set
**or** `len(raw_bytes) == 0`.

---

## 7. Capstone Operand Edge Cases

### Register naming

Capstone returns register names like `"eax"`, `"ax"`, `"al"` — already lowercase, no `%`.
These match exactly what `RegisterFile.get/set` expect.

### Segment register operands in Capstone

For `movl %ds, %eax` or `movw %ax, %ds`, the segment register appears as an `X86_OP_REG`
operand with reg ID e.g. `X86_REG_DS`. `insn.reg_name(X86_REG_DS)` returns `"ds"`. Handle
these the same as any other register operand.

### Memory operand segment field

Capstone stores explicit segment overrides (e.g. `%es:(%edi)`) in `op.mem.segment`.
If `op.mem.segment == 0` (no override), `seg_prefix = None` in the `Operand`.
If `op.mem.segment != 0`, `seg_prefix = insn.reg_name(op.mem.segment).lower()`.
Do NOT set `seg_prefix = "cs"` for normal code — CS is only used for code fetches.

### Immediate sign extension

Capstone already handles sign extension correctly for x86 immediates.
`op.imm` is a Python int and may be negative for sign-extended values.
When passing to handlers, mask to `(1 << (size_bytes*8)) - 1` as before.

### Branch immediates

For `jmp`, `jne`, `call`, etc., Capstone gives the immediate as the **absolute linear target
address** (it already accounts for the instruction length and relative encoding). This matches
what the old objdump-based parser did.

---

## 8. Testing the Overhaul

Run against `TheBigOne` test case:

```bash
python3 sim.py \
  --test-dir tests/Stages/Harish_StageTesting/config/TestProgs/TheBigOne \
  --bin     tests/Stages/Harish_StageTesting/gen/memGen/meta/program.bin \
  --verbose
```

Expected first instructions decoded (from the binary at physical offset 0x2010):
```
CS:0000  EIP:00000000  movl  $0x????,%eax   (DS macro substituted by memGen)
CS:0000  EIP:00000005  movw  %ax,%ds
CS:0000  EIP:00000007  movl  $0x????,%eax   (SS macro)
CS:0000  EIP:0000000C  movw  %ax,%ss
...
```

Verify that after segment_init, `DS != 0` and `SS != 0`.

---

## 9. What Is NOT Changing

- `flags.py` — no changes needed
- `execute.py` instruction handler functions (all the `exec_*` methods) — logic unchanged
- `compare.py` — no changes
- `SUPPORTED_OPCODES.md` / `SUPPORTED_OPCODES.txt` — no changes
- The `Instruction` and `Operand` class interfaces — same fields, just populated by Capstone now
- The trace format written by `_write_trace`
- The `Flags` class and flag update methods (`update_add`, `update_sub`, etc.)

---

## 10. Summary of New File Structure

```
scripts/sim/
  sim.py          ← rewritten main loop + new CLI
  memory.py       ← fully rewritten (bin load, TLB, seg+TLB translation)
  decoder.py      ← new file replacing parser.py (Capstone-based)
  execute.py      ← targeted plumbing changes only (_read/_write operand, stack, movs)
  registers.py    ← remove seg_bases dict, keep everything else
  flags.py        ← no change
  compare.py      ← no change
  parser.py       ← DELETE (replaced by decoder.py)
```

---

## 11. Open Items / Assumptions

1. `memGen.conf.json` `mem_size_bytes` is always 32768. If it ever differs, `memory.py` should
   read this value and allocate `bytearray(mem_size_bytes)` accordingly.

2. The `program.bin` is always a **flat physical image** — byte at offset `N` in the file
   is the byte at physical address `N`. There is no ELF header or other wrapper.

3. MMIO TLB entries (`"MMIO":"1"`) — the existing TLB configs have no MMIO entries for code/data
   tests. For now, treat MMIO as a normal read/write with a warning printed to stderr.

4. If an instruction fetch hits a TLB miss or CS limit violation, print an error and halt.
   Data accesses that fault also halt with a CPUException (same as today).

5. The `r_w` TLB flag (read/write permission) — currently not checked in the old sim.
   Keep this behavior for now (ignore `r_w` during simulation).

6. **Segment limit checking summary:**
   - CS, DS, ES, FS, GS — limit check **enabled** (`skip_limit=False`).
   - SS — limit check **disabled** (`skip_limit=True`). This is a deliberate hardware
     design decision; the stack segment is not bounds-checked in this core.
   - The limit is a 20-bit unsigned value from `CoreRegs.conf.json["SegLimitVals"]`.
   - The check is: `effective_offset > limit` (unsigned comparison). If true, raise
     `CPUException("#GP: <SEG> offset 0x... exceeds limit 0x...")`.
   - The limit check happens **before** segment base addition and **before** TLB lookup.
   - Page faults (`#PF`) come from TLB misses or `present=0` entries; these are distinct
     from segment limit violations (`#GP`) and have separate error message prefixes.
