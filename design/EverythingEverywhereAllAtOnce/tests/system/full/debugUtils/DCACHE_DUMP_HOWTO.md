# DCache Full-Contents Dump — How To Use

## Quick Start

Run the simulation with a cycle range:
```bash
make run SIMFLAGS="+DCACHE_DUMP_START=340 +DCACHE_DUMP_END=370"
```

Results go to **`logDumps/dcache_dump.log`** — completely separate from `run.log` so the compare flow is unaffected.

---

## Cycle Range Options

| Goal | Command |
|------|---------|
| Dump cycles 340–370 | `make run SIMFLAGS="+DCACHE_DUMP_START=340 +DCACHE_DUMP_END=370"` |
| Single cycle | `make run SIMFLAGS="+DCACHE_DUMP_START=369 +DCACHE_DUMP_END=369"` |
| From cycle 200 to end | `make run SIMFLAGS="+DCACHE_DUMP_START=200"` |
| No dump (default) | `make run` |

You can also bake the range into the build so you don't have to retype it every run:
```bash
make DCACHE_DUMP_START=340 DCACHE_DUMP_END=370   # compiles with range built in
make run                                          # no SIMFLAGS needed
```

---

## Finding the Right Cycle Range

If you don't know which cycles to look at, grep `run.log` for the addresses you care about:
```bash
# addresses are esi-relative — esi starts at 0x2000 in MovHeavy
grep -n "paddr0=0x2200\|paddr0=0x2600\|ld_addy=0x2" logDumps/run.log | head -20
```
That prints `CYCLE N` context lines. Pick a range ±20 cycles around the cycle of interest.

---

## Output Format

Each cycle looks like this:
```
===== DCACHE DUMP (cycle 369, t=2948000) =====
[Bank 0  DCache]
  Set 0: V=1 D=1  Tag=0x13  Addr=0x00002600  08 00 00 00 00 00 00 00 | 00 00 00 00 00 00 00 00
  Set 1: V=0 ---
  ...
[Bank 0  VCache]
  Way 0: V=1 D=1  Tag=0x080  Addr=0x00002000  01 00 00 00 00 00 00 00 | ...
  Way 1: V=1 D=1  Tag=0x088  Addr=0x00002200  02 00 00 00 00 00 00 00 | ...
  ...
[Bank 0  EvicBuf]
  EB: V=1 Commit=0  Addr=0x00002800  e4 e4 e4 e4 00 00 00 00 | ...
[Bank 1  DCache]
  ...
```

**Fields:**
- `V` — valid bit (register, not RAM)
- `D` — dirty bit (register, not RAM)
- `Tag` — tag bits read directly from the RAM cell
- `Addr` — reconstructed line address: `(tag << 9) | (set << 6) | (bank << 4)` for DCache; `(vtag << 6) | (bank << 4)` for VCache
- `Data` — 16 bytes of the cache line, split `|` at byte 8

---

## Address Mapping (for MovHeavy with esi=0x2000)

| Instruction | Physical addr | Bank | Set | Tag |
|-------------|--------------|------|-----|-----|
| `(%esi)`        | 0x2000 | 0 | 0 | 0x10 |
| `0x200(%esi)`   | 0x2200 | 0 | 0 | 0x11 |
| `0x400(%esi)`   | 0x2400 | 0 | 0 | 0x12 |
| `0x600(%esi)`   | 0x2600 | 0 | 0 | 0x13 |
| `0x800(%esi)`   | 0x2800 | 0 | 0 | 0x14 |

**All of these conflict in Bank 0, Set 0.** Only one can live in the DCache at a time; the rest must be in the VCache or EvicBuf.

General formula:
```
bank  = addr[5:4]
set   = addr[8:6]
tag   = addr[14:9]      (DCache, 6 bits)
vtag  = addr[14:6]      (VCache, 9 bits — includes index bits)
```

---

## What to Look For When Debugging

**Tracking a cache line through an eviction:**
1. Find the cycle where Set 0 tag changes (e.g., 0x11 → 0x13 means 0x2200 was evicted for 0x2600)
2. Check VCache ways at that same cycle — the evicted line should appear with `V=1` and correct data
3. If VCache shows `V=1` but wrong data, the eviction wrote bad data from DCache
4. If VCache shows `V=0` for all ways, the eviction itself was dropped

**Useful greps on `dcache_dump.log`:**
```bash
# Watch tag transitions in Bank 0 Set 0 only
grep "Set 0:\|DUMP (cycle" logDumps/dcache_dump.log | grep -v "V=0"

# Find first cycle where a specific address appears
grep "Addr=0x00002200" logDumps/dcache_dump.log | head -3

# Check VCache state at a specific cycle
awk '/DUMP \(cycle 369/,/DUMP \(cycle 370/' logDumps/dcache_dump.log
```

---

## Implementation Notes

- **Source:** `debugUtils/debugUtils_DCache_Full.svh` — path macros + per-bank task generators
- **Activated by:** `` `DCACHE_DUMP_INIT `` in `tb_SystemTest.sv` (expands the `always_ff` trigger after `clk` is declared)
- **Log file path:** injected at compile time via `+define+DCACHE_LOG_FILE_NAME=...` in the Makefile
- **No RTL changes** — reads directly from `ram8b8w$.mem[]` / `ram8b4w$.mem[]` internal arrays and register arrays via hierarchical paths
- Valid/dirty bits come from `tagMetaStore[]` registers; tag and data come from the RAM cell `mem[]` arrays
