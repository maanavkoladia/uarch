# EXE Structural Porting Guide

Step-by-step rules for porting modules in `rtl/core/EXE/` from behavioral
SystemVerilog to structural Verilog 2005.

## Goals

1. **Verilog 2005 only.** No `always_*`, no struct ports, no SV-only types in
   the structural files. Every output is driven by a module instance, gate
   primitive, or `assign`-of-a-wire (no `&` `|` `~` `^` operators in `assign`
   data paths — concatenation/replication are fine since they're not
   operators).
2. **Use STDCell macros** from `lib/STDCells/STDCell_Macros.vh`. Prefer
   NAND/NOR over AND/OR — NAND/NOR are single-stage primitives at 0.30 ns;
   AND/OR are NAND+INV pairs at ~0.50 ns.
3. **Critical path first.** Pick the topology that minimises gate-depth on
   the longest path. The big rules:
   - **Result selection: tristate-mux** (single-driver bus) plus a final
     2:1 MUX selecting between the bus and a passthrough/zero default.
   - **Use `tristateL$`** (via the `TRISTATE_L` macro). It is the *fastest*
     tristate (0.26 ns) and is correct any time the bus has only a few
     receivers, which is always our case here.
   - **NEVER use `BUS_TRISTATE`** — its underlying primitive
     `tristate_bus_driver1$` has a 5 ns delay (designed for off-chip
     buses).
   - **NEVER use OR/AND chains for `match_any`.** Always build with NAND/NOR
     alternation (NOR_4 of inputs → NAND of NOR outputs). Wide ORs become
     NAND→NOR towers, which add extra inverter stages.
4. **Fanout ≤ 4** on every signal. Insert lib2 high-drive buffers
   (`bufferH16$`, `bufferH64$`, ...) on signals that exceed it. Do NOT use
   `BUFFER_DELAY` for fanout — it builds a delay chain, not a fanout
   buffer. (See TODO below.)
5. **No giant packed wires for structs.** Each struct field becomes its own
   named wire (`<struct>_<field>` style).

> **TODO (user):** Add a width-parameterized macro for instantiating
> `bufferH16$` / `bufferH64$` / `bufferH256$` arrays — e.g.
> `\`BUFFER_HFAN(name, WIDTH, FAN, in, out)` that picks the right primitive
> by FAN. Currently every structural file open-codes the generate loop.

## Naming and layout

- Structural files live in `rtl/core/EXE/structural/` (mirrors
  `Decode/structural/`, `DCache/structural/`, `mem/.../structural/`).
- File name: `<original_basename>_structural.v` — e.g. `dr_sel.sv` →
  `structural/dr_sel_structural.v`.
- **Module name stays the same** as the SV reference. EXE.sv (which keeps
  its struct ports) instantiates by module name, so flipping `srcs.mk` is
  enough to swap implementations.
- The deprecated/empty `cs_change_logic.sv` is not ported. The
  auto-generated `gen/wb_valid_logic.v` is already structural; leave it.

## Result-selector pattern (dr_sel / sr_sel)

Modules with a clean "write-enable" control signal use a tristate-mux
+ 2:1 MUX, **not** a `match_any` computation:

```
                       op_type ──┬──► CMP_N's per matched op_type
                                 │
                                 ├──► INV's → enbar's
                                 │
   <FU outputs> ────► TRISTATE_L (one per op) ──┐
                                                │
                            tristated_bus ──────┤
                                                ├── MUX_2 ──► out
                                  passthrough ──┘
                                  (dr_data /     ▲
                                  sr_data)       │
                                                 │
                              wb_dr / wb_sr ─────┘
```

When `wb_dr=0` (instruction does not write DR), the mux selects `dr_data`
and the floating tristated bus is ignored. When `wb_dr=1` exactly one
tristate fires (per the `op_type ⇔ wb_dr` invariant from the control
store).

This **eliminates the wide `match_any` OR tree** entirely. EXE.sv is
responsible for routing `latches_i.wb_cs.WB_DR` / `WB_SR` into the
selectors.

## Result-selector pattern (res_buf_sel and flag selectors)

These have no convenient write-enable, so we compute `match_any` from a
NAND-NOR tree over the per-op `is_X` one-hots, then do the same
tristate-mux + 2:1 MUX:

```
   is_X[0..N-1] ──► NOR_4 (in groups of ≤4) ──► NAND_? ──► match_any
                                                              │
   <FU outputs> ────► TRISTATE_L (one per op) ──┐             │
                                                │             │
                            tristated_bus ──────┤             │
                                                ├── MUX_2 ────┘── out
                                  passthrough ──┘             ▲
                                  (curr_X_flag /              │
                                   64'h0)                     │
                                                              │
```

NAND-NOR layout for `match_any` of N inputs:

| N  | Group split | Stage 1                | Stage 2     |
|----|-------------|------------------------|-------------|
| 2  | 1+1         | (none — direct OR_2)   | —           |
| 10 | 4+3+3       | NOR_4 + 2× NOR_3       | NAND_3      |
| 11 | 4+4+3       | 2× NOR_4 + NOR_3       | NAND_3      |
| 12 | 4+4+4       | 3× NOR_4               | NAND_3      |
| 17 | 4+4+4+4 + 1 | 4× NOR_4 (+1 leftover) | NAND_4 + OR_2 |

Build with the macros: `\`NOR_4(name, 1, out, in0, in1, in2, in3)`,
`\`NAND_3(name, 1, out, in0, in1, in2)`, etc.

## Tristate primitive selection

Use `\`TRISTATE_L(name, WIDTH, enbar, in, out)`. Internally this maps to
WIDTH instances of `tristateL$` (0.26 ns each). For 64-bit data buses
that's 64 instances per driver; the macro generates the loop.

`\`BUS_TRISTATE` is forbidden — its underlying primitive has 5 ns delay.

## Sequential elements (in EXE.sv)

EXE.sv stays SystemVerilog (struct ports). Inside it, replace `always_ff`
flop blocks with structural `\`REG_RST_WE` / `\`REG_RST` instantiations:

- `flags_reg` (32-bit, gated by `latches_i.valid`, `!rst` reset) →
  one `REG_RST_WE` with WIDTH=32. The `din` injects flag-bit values at
  CF/PF/AF/ZF/SF/DF/OF positions; remaining bits get tied to 0.
- `stall_flop` (1-bit, always-write) → `REG_RST`.

## Struct field unrolling

When a SV reference has a struct port, the structural version replaces it
with one flat port per scalar field, named `<struct>_<field>_<i|o>`. The
wrapping SV module (e.g. EXE.sv) is responsible for unpacking on the input
side and reassembling on the output side. Don't pack a struct as one wide
wire — the field boundaries get lost and reads-of-fields require slicing
constants.

## Worked example: porting a step-2 functional unit

Suppose the next FU to port is `add_op.sv`:

```sv
module add_op (
    input  uint64_t srA, srB,
    input  logic [3:0] data_size,
    output uint64_t dr_o, res_buf_o,
    output logic ZF, SF, PF, OF, CF, AF
);
```

Steps:

1. Create `structural/FunctionalUnits/add_op_structural.v`, module name
   `add_op`. Replace SV types with `wire [N-1:0]`.
2. **Adder core:** `\`ADD_N(u_add, 64, sum, cout, srA, srB, 1'b0)`. The
   Kogge-Stone primitive is already structural — reuse.
3. **Data-size masking** for outputs: build per-byte write-enable from a
   4-bit decoder of `data_size`, then per-byte mux between `sum[i*8 +: 8]`
   and a default value (`8'h00` or the source byte, depending on op
   semantics).
4. **ZF:** wide NOR over the participating bits. Hand-build a NOR-tree —
   never use `OR_N` for >4 inputs.
5. **SF:** the MSB of the participating slice. Per-data-size mux to pick
   `sum[7]/[15]/[31]/[63]`.
6. **PF:** XOR-tree over the low byte. `xor2$` primitives, four levels.
7. **CF:** the `cout` from `ADD_N` (or an internal carry-chain tap for
   smaller widths).
8. **AF:** carry out of bit 3.
9. **OF:** sign-bit XOR of `srA[N-1] ^ sum[N-1]` AND-with `~(srA[N-1] ^
   srB[N-1])`. Per-data-size mux selects N.

For each FU, identify:
- The dominant arithmetic primitive (adder, comparator, shifter, etc.).
  Use existing structural primitives (`ADD_N`, `CMP_N`, ...) when one fits.
- The flag-derivation logic (depends on data-size — forces a per-size mux
  on flag outputs).
- Whether `data_size` masking is needed.

After porting one FU:
- Add the file to `EXE_STRUCTURAL_SRC_FILES` in `srcs.mk`.
- Remove the `.sv` from `EXE_SRC_FILES`.
- Run the EXE-level testbench. The behavioural ref still exists in
  `EXE/FunctionalUnits/<name>.sv` — keep it on disk for easy revert until
  the structural one is verified.

## Quick sanity checklist for any structural file

- [ ] No `always_*`, `case`, `if`/`else`, `for` outside `generate`.
- [ ] No `&`, `|`, `~`, `^`, `?:`, `==` operators in `assign` statements.
- [ ] All ports are `wire [N-1:0]` (no SV types, no struct types).
- [ ] All internal nets are explicit `wire` declarations.
- [ ] No `import <pkg>::*` — use `\`include "<file>.vh"` for defines.
- [ ] File header comment: one-line description + reference to the SV
  source it ports.
- [ ] File name ends with `_structural.v`; module name matches the SV
  reference.
- [ ] Match_any (where needed) built from NAND-NOR alternation, not a
  long OR chain.
- [ ] `TRISTATE_L` (never `BUS_TRISTATE`).
- [ ] When fanout would exceed 4, instantiate `bufferH16$` /
  `bufferH64$` / `bufferH256$` from lib2 (open-coded generate for now;
  see TODO above).
