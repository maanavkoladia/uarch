# DCache Structural Port — Per-Module Recipe & Reprompt Template

This file documents the conventions for porting DCache modules from
SystemVerilog to structural Verilog 2005, and provides a reusable prompt
to drive each module's port. Every iteration ports **one** module while
leaving the SV reference intact behind a `` `ifdef `` swap.

The first port (EvictionBuf) follows every rule below — use it as the
worked example when porting the next module.

---

## Hard rules for the structural `.v` file

1. **Verilog 2005 only.** No `always_ff`, `always_comb`, `logic`, struct,
   typedef, enum, package import, `int`, `for/while` outside `generate`.
2. **No behavioral logic.** No `?:` ternary. No `&&`/`||` logical ops.
   No `&`/`|`/`^`/`~` bitwise ops. No `==`/`!=` comparators in expressions.
   Arithmetic operators are also forbidden (use `ADD_N` if needed).
3. **`assign` is for wire aliasing only.** Allowed: `assign x = y;`,
   `assign x = struct.field;`, `assign x = bus[hi:lo];`, `assign x = {...};`
   (concatenation for repacking byte arrays). Forbidden: `assign x = a & b;`,
   `assign x = a ? b : c;`, etc.
4. **All logic comes from STDCell macros.** The macros are defined in
   `lib/STDCells/STDCell_Macros.vh` and are available globally to the
   structural sources via the build's include path.
5. **Storage uses `REG_RST_WE`.** Async active-low reset clears `q` to 0.
   To hold a value, drive `we = 0`. To overwrite conditionally, build the
   `we` and `d` muxes from gate macros.
6. **Each register has exactly one (we, d) pair.** If multiple update
   conditions write the same register, OR the conditions into a single
   `we`, and MUX the data into a single `d` (with `MUX_2`/`MUX_4`/etc).
   When write conditions are mutually exclusive, the `d` mux often
   collapses to a direct wire (no MUX needed) — see EvictionBuf.

## STDCell macro cheatsheet (what's available — no new macros needed)

Source: `lib/STDCells/STDCell_Macros.vh`. Arguments are positional.

| Macro | Signature | Notes |
|---|---|---|
| `INV_N`        | `(name, width, in, out)`                              | Vector inverter |
| `AND_2..AND_12`| `(name, width, out, in0, in1, ...)`                   | N-input AND |
| `OR_2..OR_12`  | `(name, width, out, in0, in1, ...)`                   | N-input OR |
| `MUX_2`        | `(name, width, out, in0, in1, sel)`                   | sel is 1-bit |
| `MUX_3`        | `(name, width, out, in0, in1, in2, sel)`              | sel is 2-bit |
| `MUX_4`        | `(name, width, out, in0..in3, sel)`                   | sel is 2-bit |
| `MUX_8`        | `(name, width, out, in0..in7, sel)`                   | sel is 3-bit |
| `MUX_16/32/64` | `(name, width, out, in0..inN, sel)`                   | sel is log2(N) bit |
| `CMP_N`        | `(name, width, out, in0, in1)`                        | Equality only |
| `ADD_N`        | `(name, width, sum, cout, in0, in1, cin)`             | Kogge-Stone |
| `BUFFER_DELAY` | `(name, stages, width, in, out)`                      | 0.25 ns / stage |
| `TRISTATE_L`   | `(name, width, enbar, in, out)`                       | Active-low en |
| `BUS_TRISTATE` | `(name, width, enbar, in, out)`                       | Bus-grade |
| `DECODER_N`    | `(name, inputs, in, out)`                             | INPUTS=N → 2^N out |
| `REG_RST_WE`   | `(name, width, clk, rst, we, din, dout)`              | Async low rst |
| `REG_RST`      | `(name, width, clk, rst, din, dout)`                  | Always-write |
| `ROM_32W_64b`  | `(name, addr, oe, dout)`                              | 32×64 ROM |

**No NAND/NOR/XOR/BUF or set-flop macros.** Build XOR from `AND/OR/INV`
or just use `MUX_2` (`a^b == MUX_2(sel=a, in0=b, in1=~b)`). Build a
sync-set as `we | set; d_pre = MUX_2(sel=set, in0=d, in1=1)`.

## Port-shape rules

- **No struct ports.** Each struct field becomes its own `input wire` /
  `output wire`. Use suffixes:
  - `..._i` for inputs, `..._o` for outputs.
  - When a port unpacks an SV struct, prefix with the struct name:
    `blockReq_oe_i`, `vcache_LD_EB_i`, `ebOut_addr_o`.
- **A cache line MAY be a single 128-bit wire.** (User exception. Apply
  to any `byte_t [CACHE_LINES_SIZE_B]` field — pack LSB-first: byte 0 in
  bits `[7:0]`, byte 15 in `[127:120]`.)
- **Address fields**: `p_address_t` is 15 bits (`$clog2(PHY_MEM_SIZE)`,
  `PHY_MEM_SIZE = 1<<15`).
- **Boolean fields**: 1-bit wire.
- **Module name**: append `_struct` to the SV name. Example:
  `EvictionBuf` → `EvictionBuf_struct`. File name uses `.v` extension and
  drops the suffix: `EvictionBuf.v`.

## Swap pattern (parent of the ported module)

The structural module name differs from the SV one (suffix `_struct`),
so both can coexist. The parent guards which one it instantiates with
`` `ifdef ``:

```systemverilog
`ifdef USE_STRUCTURAL_<MOD>
    // adapter wires: struct -> flat (concatenations / slices only)
    <MOD>_struct unit_name (
        .clk_i(...), .rst_i(...),
        // flat ports
    );
    // adapter assigns: flat -> struct (drive each struct field individually,
    // use generate-for to unpack byte arrays)
`else
    <MOD> unit_name (
        // original SV port mapping (struct ports)
    );
`endif
```

The `` `define USE_STRUCTURAL_<MOD> `` lives in
`structural/DCache_TOP.sv` (commented-out by default). Each port adds
one line there.

## Per-module port recipe (6 steps)

1. **Read the SV** under `rtl/DCache/<path>/<MOD>.sv`. Identify:
   - Every state register (name, width).
   - Every combinational output (and its formula).
   - Reset behavior (async low expected).
2. **List registers and per-condition (we, d).** For each register write
   case in the always_ff, write a row: condition → (we contribution, d
   contribution). When done, OR the we contributions, MUX the d
   contributions. Mutually exclusive cases → no MUX.
3. **List combinational outputs.** Each becomes either a direct register
   tap (`assign output = q;`) or a gate netlist ending in the output
   wire.
4. **Plan the gate netlist.** Pick macros from the cheatsheet. Name
   intermediate wires by their meaning (`LD_EB_qual`, `addr_eq`, ...).
   Verify no `&&`/`||`/`?:`/`==` slipped in.
5. **Write the `.v` file** under `rtl/DCache/structural/<MOD>.v` with
   the `_struct` suffix on the module name. Order: ports → q-wires →
   helper wires → gate macros → register macros → output assigns.
6. **Wire the `` `ifdef `` into the parent** (still under
   `rtl/DCache/structural/`). Add adapter logic to convert structs
   ↔ flat wires. Add `` `define USE_STRUCTURAL_<MOD> `` (commented) to
   `structural/DCache_TOP.sv`.

## Loop / timing checklist (one pass before declaring done)

- [ ] Are all of this module's outputs either (a) direct register taps
      or (b) ending in a structural macro?
- [ ] Is every combinational output's input cone broken at every cycle
      by at least one register on every feedback path through the rest
      of the design? (Re-check sources of LD/clr-style inputs: they
      typically come from another module that consumed last cycle's
      output of THIS module — a register break is required.)
- [ ] Did any tri-state driver (`BUS_TRISTATE`) read a wire that was
      previously a 0-delay assign and now goes through gate delays?
      Confirm tri-state enable timing still arrives before/with data.

## Reprompt skeleton (drop-in for the next module)

```
Port `<MODULE>` to structural Verilog 2005 following
`rtl/DCache/structural/STRUCTURAL_PORT_GUIDE.md`. Constraints:

- New file: `rtl/DCache/structural/<MODULE>.v`, module named
  `<MODULE>_struct`, flat individual ports (cache lines may be one wire).
- Wrap the existing instantiation in
  `rtl/DCache/structural/<PARENT>.sv` with
  `` `ifdef USE_STRUCTURAL_<MODULE> / `else / `endif ``. Add adapter
  assigns (struct ↔ flat) inside the structural branch.
- Add a commented `` `define USE_STRUCTURAL_<MODULE> `` block to
  `rtl/DCache/structural/DCache_TOP.sv` at the top, alongside the
  existing flags.
- Do not modify any file outside `rtl/DCache/structural/`.
- Do not implement new STDCell macros — flag any that are missing.
- Verify the loop / timing checklist before declaring done.

Reference port: see `rtl/DCache/structural/EvictionBuf.v` for the
worked example and `rtl/DCache/structural/DCache_Block.sv` for the
parent-side adapter pattern.
```

## What's been ported so far

| Module       | File                                     | `` `ifdef `` flag        | Parent                 |
|--------------|------------------------------------------|--------------------------|------------------------|
| EvictionBuf  | `structural/EvictionBuf.v`               | `USE_STRUCTURAL_EB`      | `DCache_Block.sv`      |
| Bank trio    | `structural/DCache_Bank.v`, `_TagStore.v`, `_DataStore.v` | `USE_STRUCTURAL_BANK`   | `DCache_Block.sv` |
| VCache quartet | `structural/VCache.v`, `_TagStore.v`, `_DataStore.v`, `LRU.v` | `USE_STRUCTURAL_VCACHE` | `DCache_Block.sv` |

The Bank trio shares one flag because the structural Bank instantiates
the structural TagStore + DataStore directly. The FSM
(`gen/DCache_Bank_FSM.sv`) is already pure structural Verilog 2005 and
is reused as-is by both the SV bank and the structural bank.

Design record for the Bank port (decomposition, gate netlists, full
combinational-loop audit) lives at `BANK_PORT_PLAN.md` next to this
guide — use it as the worked example when porting the next module.

Do not change the name of the module names or generate blocks because I use them for internal pathing.

(Add a row when a new module ships.)
