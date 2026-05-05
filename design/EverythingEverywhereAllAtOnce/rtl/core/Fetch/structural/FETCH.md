# Fetch — Design Reference for Structural Port

This document is the working reference for porting the Fetch stage from
SystemVerilog to structural Verilog 2005. All Fetch helper modules are
now structural; the only SV left in `Fetch.sv` is the top-level wiring
(struct declarations, JK flop blocks, mode-mux always_combs).

---

## What Fetch is responsible for

Fetch produces the next SPC (Structural Program Counter — the cache-line-
aligned program counter that drives the I-cache and instruction queue),
runs branch prediction speculatively against the SPC, fills the IDM
(instruction-decode buffer) slots from the I-cache, and detects fetch-
side faults / exception entry / interrupt entry.

Each cycle the stage:

1. **Drives I-cache & TLB** with the current SPC. The TLB physical
   address goes to the cache; the segment-translated virtual address is
   the byte address that the cache eventually stores against.
2. **Looks up BTB and the predictor** with the current SPC. If
   `btb.hit & predictor.taken` (or unconditional), the cache line will
   eventually be steered toward `btb.br_target`.
3. **Selects next SPC** via `SPC_Sel_Logic`. Source of truth: the
   `spc_sel_logic_output_options_e` enum — `SPC` (stall), `SPC_P16`
   (linear advance), `BR_RESTORE` (execute mispredict resolution),
   `BTB_TARGET` (predicted taken).
4. **Loads IDM slots** when the cache line returns (`IDM_Ctrl_Logic`).
   Branch metadata from the BTB rides along into the slot so later
   stages know "this slot ends in a branch."
5. **Invalidates IDM slots** that crossed a branch resolution boundary
   (`IDM_Invalidate_Logic`).
6. **Latches exception/interrupt mode JKs**:
   - `exp_mode_jk[0]` — generic exception mode (set by `exp_set_logic`,
     cleared by execute resolving the handler return).
   - `exp_mode_jk[1]` — DC-stage exception mode (DC fault path).
   - `int_mode_jk` — interrupt servicing.
   - `DMA_int_jk` — pending DMA interrupt from outside the core.
7. **Sources `rom_data_out`** from `EXP_Ctrl_ROMS` whenever exp/int mode
   is active (instructions come from microcode ROM instead of the cache).

The fetch outputs (`fetch_outputs_t`) feed the rest of the core: the
IDM-side `fetch_2_icache_t`, the IDM slot pushes, the pipe-clear signal,
the fetch-side fault flag, and the mode JK values.

---

## Modules already ported

Predictor stack: `BTB`, `Predictor`, `GShare`, `BTFN`, `two_bit_sat_count`.
Exception helpers: `EXP_Set_logic`, `EXP_Ctrl_ROMS`.
SPC / IDM helpers: `ICache_En_Logic`, `SPC_Sel_Logic`,
`IDM_Invalidate_Logic`, `IDM_Ctrl_Logic`.

### `BTB`
Direct-mapped, `BTB_ENTRIES` entries (default 64; configure via
`` `define BTB_ENTRIES `` at top of file). Address fields:

```
spc[ADDRESS_BITS-1 : INDEX_OFF+INDEX_BITS] = tag    (default 22 bits)
spc[INDEX_OFF+INDEX_BITS-1 : INDEX_OFF]    = index  (default  6 bits)
spc[INDEX_OFF-1 : 0]                       = byte offset (always 0 for fetch)
```

with `INDEX_OFF = $clog2(CACHE_LINES_SIZE_B) = 4` and
`INDEX_BITS = $clog2(BTB_ENTRIES)`.

Per-entry storage is one `REG_RST_WE` packing
`{valid, br_ucond, XCL, br_eip, br_target, tag}` (msb→lsb), width
`TAG_BITS + 67`. Read uses a binary tree of `MUX_2` (heap-layout —
`tree[1]` is the root) selected by `spc_index`. Write uses `DECODER_N`
on `exe_index` ANDed with `exe_br_valid` to produce one-hot per-entry
write enables. Hit = tag-match (`CMP_N`) AND valid.

The `BTB_ENTRIES` macro must be a power of 2.

### `Predictor`
Thin wrapper. Currently routes to `GShare`. The original
`predictor_input_t` had `btfn_target` and `exe_br_target` — those were
only consumed by BTFN and are dropped from the wrapper's port list. Add
them back if you swap to BTFN.

### `GShare`
Two history registers — `bhr_real` (architectural) and `bhr_spec`
(speculative) — and a 2^`BHR_SIZE` PHT of two_bit_sat_count cells
(default `BHR_SIZE = 8`, configure via `` `define GSHARE_BHR_SIZE ``).

Indexing folds PC bits with the BHR:

```
pht_index_spec   = bhr_spec ^ spc[CACHE_LINE_OFF +: BHR_SIZE]
pht_index_update = bhr_real ^ exe_br_eip[CACHE_LINE_OFF +: BHR_SIZE]
```

Read path uses the same heap-layout binary `MUX_2` tree as BTB to pull
`pht_taken[pht_index_spec]`. Train path uses `DECODER_N` on
`pht_index_update` to one-hot the trained entry, then ANDs with
`exe_br_valid & exe_br_taken` (inc) or `exe_br_valid & ~exe_br_taken`
(dec).

History updates:
- `bhr_real`: shift `exe_br_taken` in when `exe_br_valid`. WE =
  `exe_br_valid`.
- `bhr_spec`: priority `misprediction > btb_hit > hold`. On
  misprediction, snap to `next_bhr_real` (the value `bhr_real` is taking
  this cycle). On btb_hit, shift the predicted `taken` in. WE =
  `misprediction | btb_hit`.

### `BTFN`
Static "backward = taken, forward = not-taken." `taken =
(btfn_target < spc)` unsigned. Implemented as `~cout` of
`btfn_target + ~spc + 1` via `ADD_N` (Kogge-Stone) — no dedicated
comparator macro is needed.

Currently dead code (Predictor wires GShare). Kept structural for
parity.

### `ICache_En_Logic`
Pure combinational. `out = ~exp_mode & ~cs_sb & ~int_mode & ~f_exp & ~DMA_int & rst`
where `rst` is active low (forces `out = 0` during reset). 5× `INV_N` +
1× `AND_6`.

### `SPC_Sel_Logic`
Picks the SPC update source for next cycle and tracks XCL_stall,
flush_reg, and a registered branch target. Output `sel` is encoded as
the same 2-bit values as `Fetch_pkg::spc_sel_logic_output_options_e`
(SPC=00, SPC_P16=01, BR_RESTORE=10, BTB_TARGET=11). Fetch.sv casts the
2-bit wire back to the enum field via
`spc_sel_logic_output_options_e'(spc_sel_w)`.

Sel chain (chained `MUX_2` width-2 mirroring the SV if/else priorities):
```
inner  = cond_btb     ? BTB_TARGET : SPC_P16
middle = flush_reg    ? SPC_P16    : inner
outer1 = push_success ? middle     : SPC
sel    = flush        ? BR_RESTORE : outer1
cond_btb = ((br_taken & ~btb_xcl) | XCL_stall) & ~target_same_line
```

Three registers, all `REG_RST_WE` with active-low rst:
- `XCL_stall` (1 bit): WE = (case1 | case2 | case3), D = case2 & ~case1
  where case1=`flush|flush_reg`, case2=`~XCL_stall & br_taken & btb_xcl & push_success`,
  case3=`XCL_stall & push_success`.
- `BR_target_reg` (32 bits): WE = `~XCL_stall | push_success`
  (consensus simplification of the SV `(!XCL_stall) || (XCL_stall && push_success)`),
  D = `btb_br_target`.
- `flush_reg` (1 bit): WE = `flush | (flush_reg & push_success)`,
  D = `flush` (set-dominant, both code paths drive D=flush).

`target_same_line` uses `CMP_N` width=32 over `{btb_target[31:4], 4'b0}`
vs `spc`. `br_target` output is `MUX_2` width=32 picking
`BR_target_reg` when `XCL_stall=1`, else `btb_br_target`.

Convention change vs. SV: rst is now active-low (Fetch.sv passes top-level
`rst` directly instead of `!rst`).

### `IDM_Invalidate_Logic`
Decides which IDM slots to invalidate this cycle. Three sources of
invalidates that are OR'd together:
1. **Global flush** (`flush | exp_pipeclear | int_pipe_clear | ~rst`) —
   forces all four invalidates plus `no_writes` high.
2. **slot_in_use_changed** (`eip_slot_num != prev_eip_slot_num`) —
   invalidates the *previous* eip slot via `prev_eip_slot_oh[i]`.
3. **will_leave_for_br** — the EIP slot has a valid branch whose `br_eip`
   matches `eip` and whose `br_btb_target` line differs from `eip`'s line,
   gated by `decode_forward`. Invalidate eip_slot (and next_slot too if
   the branch is XCL and next_slot is valid).

Per-slot one-hot decoding via `DECODER_N` (`eip_slot_oh`,
`prev_eip_slot_oh`); next_slot one-hot is just `eip_slot_oh` rotated by
1 (no gates). Per-eip-slot field reads (br_valid, br_eip, br_btb_target,
br_xcl) use `MUX_4` (sel = `eip_slot_num`, 2 bits). `next_slot_valid` is
4-input AND-OR over the rotated one-hot and the per-slot valid bits.
`will_leave_for_br` itself is `AND_4(eip_br_valid, br_eip_match,
br_target_line_diff, decode_forward)` with `br_target_line_match` done
as `CMP_N` width=28 over the top 28 bits.

`prev_eip` is a 32-bit `REG_RST_WE` (always-WE; resets to 0 — the SV
reset-to-eip is approximated here, see header comment in the file).
`prev_eip_next` muxes between `eip` and `eip_slot_br_btb_target` based
on `(will_leave_for_br & ~case_b)`.

Convention change vs. SV: rst is now active-low. Same Fetch.sv
adjustment as `SPC_Sel_Logic`.

### `IDM_Ctrl_Logic`
Pure combinational. Builds per-slot IDM write requests. Per-slot
control signals:
```
wc[i]         = invalidate[i] | ~idm_slot_valid[i]
sel[i]        = slot_oh[i] & (icache_hit | exp_mode | int_mode) & ~no_writes
wc_and_sel[i] = wc[i] & sel[i]
br_active[i]  = wc_and_sel[i] & btb_hit & pred_taken & ~spc_sel_flush_reg
```

slot_oh from `DECODER_N(2, spc[5:4], slot_oh)`. Per-slot scalar outputs
fall directly out of the above; per-slot 32-bit outputs use `MUX_2`
width-32 (zero when not gated). Per-slot 16-byte data output packs
`data_in` into a 128-bit bus, runs through one `MUX_2` width-128
per slot, then unpacks back into the unpacked output array.

`push_success = OR_4(wc_and_sel[0..3])`. Slots are mutually exclusive on
`slot_oh`, so at most one term is hot.

### `EXP_Set_logic`
Pure combinational. Three pipe-clear / set outputs, all gated on the rest
of the pipeline being drained:

```
not_*           = ~rr_valid, ~dc_valid, ~mem_valid, ~exe_valid, ~wb_valid
f_pipe_clear    = invalid_instruction & not_rr_valid & not_dc_valid &
                  not_mem_valid & not_exe_valid & not_wb_valid &
                  f_exp & ~exp_mode_jk
dc_pipe_clear   = not_mem_valid & not_exe_valid & not_wb_valid &
                  dc_exp & ~exp_mode_jk
exp_pipe_clear  = dc_exp ? dc_pipe_clear : f_pipe_clear
int_pipe_clear  = (same 6-input AND as f_pipe_clear, but with int_set & ~int_mode_jk
                   replacing f_exp & ~exp_mode_jk)
dc_exp_set      = dc_pipe_clear
```

Implemented as 7× `INV_N`, 2× `AND_8`, 1× `AND_5`, 1× `MUX_2`, plus a wire
`assign` for `dc_exp_set`.

### `EXP_Ctrl_ROMS`
Picks the IDT entry index for the firing exception/interrupt, latches it on
the pipe-clear cycle, and emits a 16-byte microcode-style cache line with
the IDT entry address embedded in bytes 2..5.

Index muxes (all `MUX_2` width=5):
```
fetch_exp_out = Fetch_pf ? PF_IDT(14) : GP_IDT(13)
DC_exp_out    = DC_pf    ? PF_IDT     : GP_IDT
exp_idx       = DC_exp   ? DC_exp_out : fetch_exp_out
int_idx       = DMA_int  ? DMA_IDT(7) : DDR_IDT(4)
rom_idx       = exp_pipe_clear ? exp_idx : int_idx
```

Storage: a single 5-bit `REG_RST_WE` (`rom_sel`) with WE
`= exp_pipe_clear | int_pipe_clear` and D `= rom_idx`. Adds an active-low
`rst` port that the SV reference didn't have — the SV `always_ff` had no
reset, so `rom_sel` was X at startup. Fetch.sv passes its top-level `rst`.

Address compute: `idtEntryAddy = IDTR + (rom_sel << 3)` via `ADD_N` (32 bits,
`cin = 0`). The shift is a wire concat — `{24'h0, rom_sel, 3'b0}`.
**`IDTR` is tied to `32'h0` inside the module** because the SV reference
declared it but never assigned it (no LIDT mechanism in the design yet).
If a future LIDT lands, replace the `assign idtr = 32'h0;` with an input
port.

Output cache line is 16 plain `assign`s — bytes 0/1/6 are constants
(`8'h31, 8'h32, 8'h30`), bytes 2..5 carry `idtEntryAddy` little-endian,
bytes 7..15 are `8'h00`. The port stays as the V2005 unpacked-array
`output wire [7:0] rom_data_out [0:15]` so Fetch.sv's existing
`byte_t rom_data_out[CACHE_LINES_SIZE_B]` connection works unchanged.

### `two_bit_sat_count`
2-bit saturating counter. Reset value `2'b10` (weakly taken). Because
`REG_RST_WE` only resets to 0, bit[1] is stored inverted: on reset,
`stored_q = 2'b00` so logical `q = {~0, 0} = 2'b10`. Each write inverts
bit[1] going in, and the read inverts it back out. `taken = q[1]`.

Inc/dec next-state logic:
- `q_next[0] = ~q[0]` (always flips on +/-1).
- `q_next[1] = q[1] XOR (inc_active ? q[0] : ~q[0])`. The XOR comes from
  the `XOR_2` macro added to `STDCell_Macros.vh`.

Inc has priority over dec (matches the SV `if/else if`).

---

## Conventions for porting the remaining Fetch modules

These rules come from this port and the DCache structural guide. Apply
them to every new module.

### Verilog 2005 only
No `always_ff`, `always_comb`, `logic`, struct, typedef, enum, package
import, `int`, `for`/`while` outside `generate`. No `?:` ternary. No
`&&`/`||` logical ops, no `&`/`|`/`^`/`~` bitwise ops, no `==`/`!=`
comparators in expressions, no arithmetic operators (use `ADD_N`).

### `assign` is for wire aliasing only
Allowed: `assign x = y;`, slicing `bus[hi:lo]`, concatenation
`{a, b, c}`, bit-replication `{N{x}}`. Forbidden: any logical or
bitwise expression.

### All logic via macros
Pulled from `lib/STDCells/STDCell_Macros.vh` (no `` `include `` — the
build's source list publishes them globally). When something is missing
(we hit this with `XOR_2`), add the macro to that header and have the
underlying cell implemented in `lib/STDCells/`.

### Storage uses `REG_RST_WE` (or `REG_RST`)
Async active-low reset clears `q` to 0. Each register has exactly one
`(we, d)` pair. If multiple update conditions write the same register,
OR them into a single `we` and MUX their data into a single `d`. When
the register needs a non-zero reset, store the value with the differing
bits inverted (see `two_bit_sat_count`).

### Port-shape rules — unrolled structs
- **No struct ports.** Each struct field is its own `input wire` /
  `output wire`. Don't pack into one giant bus.
- **No SV constructs in port lists** — no `bool`, no typedef'd vectors,
  no enums. Use plain `wire [N-1:0]` / `wire`.
- Internal packing (e.g. BTB's per-entry `ENTRY_W` register) is fine
  when you genuinely need a single MUX/REG over the whole entry —
  document the bit layout with named offset `localparam`s.
- Drop fields that the body does not actually consume. Adding "dead"
  ports forces every caller to wire them.

### Configurable sizes
Use a `` `ifndef ... `define ... `endif `` block at the top of the file
so callers can override on the command line. Mirror it into a
`localparam` inside the module:

```verilog
`ifndef GSHARE_BHR_SIZE
`define GSHARE_BHR_SIZE 8
`endif

module GShare (...);
    localparam BHR_SIZE = `GSHARE_BHR_SIZE;
    localparam PHT_SIZE = 1 << BHR_SIZE;
    ...
```

### Configurable-size mux / decode trees
For an N-input mux configurable by `define`, build a binary `MUX_2`
tree using a heap layout in a generate block:

```
wire [W-1:0] tree [0:2*N-1];

generate
    for (i = 0; i < N; i = i + 1) begin : g_leaf
        assign tree[N + i] = inputs[i];
    end
    for (i = 1; i < N; i = i + 1) begin : g_node
        localparam DEPTH   = $clog2(i + 1) - 1;       // floor(log2(i))
        localparam SEL_BIT = SEL_W - 1 - DEPTH;
        `MUX_2(u_mux, W, tree[i], tree[2*i], tree[2*i + 1], sel[SEL_BIT])
    end
endgenerate
// tree[1] is the muxed output
```

`floor(log2(i))` for `i ≥ 1` is `$clog2(i+1) - 1`. Root takes the MSB
of the selector; leaves' parents take the LSB. Verified by hand for
`N = 64` and `i = 0, 1, 2^k - 1, 2^k`.

For one-hot decode the existing `DECODER_N(name, INPUTS, in, out)`
already scales — no tree needed.

### Updating the parent (`Fetch.sv`)
The structural module name stays the same; only the connection list
changes. Pass each struct field explicitly:

```verilog
BTB btb (
    ...
    .hit       (btb_outs.hit),
    .br_target (btb_outs.br_target),
    .br_eip    (btb_outs.br_eip),
    .XCL       (btb_outs.XCL),
    .br_ucond  (btb_outs.br_ucond)
);
```

`btb_outs` is still declared as the SV struct type inside `Fetch.sv`,
so downstream consumers (still SV) see no change. Only the leaf module
went structural.

If a struct is no longer used after unrolling (e.g. `predictor_inputs`
is dead now that Predictor takes flat fields), delete its declaration
and `assign` block — leaving them as dead code makes future ports
harder to read.

---

## Macro cheatsheet (Fetch port)

| Macro | Signature | Where used |
|---|---|---|
| `INV_N`        | `(name, width, in, out)`                              | Polarity flips, ~q workarounds |
| `AND_2..AND_12`| `(name, width, out, in0, in1, ...)`                   | Per-entry write enables, hit = match&valid |
| `OR_2..OR_12`  | `(name, width, out, in0, in1, ...)`                   | spec_we = misprediction | btb_hit |
| `NAND_2..4`, `NOR_2..4` | same shape                                   | empty = NOR(q[1], q[0]) |
| `XOR_2`        | `(name, width, out, in0, in1)`                        | GShare PHT index, sat-counter next-state |
| `MUX_2..MUX_64`| `(name, width, out, in0..inN, sel)`                   | Tree muxes for BTB read & PHT read |
| `CMP_N`        | `(name, width, out, in0, in1)`                        | BTB tag compare |
| `ADD_N`        | `(name, width, sum, cout, in0, in1, cin)`             | BTFN unsigned compare |
| `DECODER_N`    | `(name, inputs, in, out)`                             | BTB write decode, GShare train decode |
| `REG_RST_WE`   | `(name, width, clk, rst, we, din, dout)`              | All Fetch storage |
| `REG_RST`      | `(name, width, clk, rst, din, dout)`                  | (unused so far) |

---

## What's still SV in Fetch.sv

Fetch.sv itself is left as SV until every leaf module is ported. It
still uses struct typedefs (`btb_output_t`, `predictor_output_t`,
`tlb_inputs_t`, `idm_outputs_t`, ...), `always_ff` blocks for the
mode JKs, and ternaries / case for the SPC mux and idm_ctrl_data_in.
Those will go away in the final pass when we fold all leaf modules
together; for now they live alongside structural instantiations.
