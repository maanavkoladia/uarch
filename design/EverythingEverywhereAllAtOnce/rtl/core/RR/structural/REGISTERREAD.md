# RegisterRead (RR) Stage — Structural Port Reference

This is a reference for porting RR-stage SystemVerilog modules to pure
Verilog 2005 structural form (gates only, no `always`, no ternaries, no
bitwise/logical operators in expressions, only `assign` for wires).

## High-level pipeline role

The RR (Register Read) stage sits between Decode and DC (Data-Cache addy-gen).
It performs three things:

1. **RegFile** — reads the architectural register file for `dr`, `sr`,
   sib base/index, ECX, EAX, CS, segment0, segment1. Writebacks come from
   exe via `WB_DR0_*` / `WB_DR1_*`.
2. **RegSB (Register Scoreboard)** — tracks pending writes for each
   architectural register. Emits `dep_stall`, `ecx_sb`, `codeSeg_sb`.
3. **npu_node1 (addy-gen)** — computes load/store linear/virtual
   addresses, using regfile outputs + sib + displacement + segment data.

Top-level `RR_structural.sv` wires these together and produces
`dc_latches_next` (next-stage latches) and `outs_o` (outputs to other
stages including stall, ecx/codeSeg sb, regFileValues for debug, etc.).

## Package types you will encounter

* `bool` — `typedef logic bool;` in `rtl/pkgs/common_pkg.sv`. 1-bit.
* `reg_ids_e` — `rtl/core/pkgs/reg_ids_pkg.sv`. 5-bit enum:
  `CS=0, DS=1, SS=2, ES=3, FS=4, GS=5, EXPS=6, EAX=7, EBX=8, ECX=9,
   EDX=10, ESI=11, EDI=12, ESP=13, EBP=14, MM0=15..MM7=22, ETR=23,
   ERROR_REG=24, NO_REG=25`. NUM_REGS=26.
* `regsb_entry_t` — `rtl/core/RR/pkg/RegisterRead_pkg.sv`. Holds a
  single `uint8_t counter`. Each scoreboard slot is one of these.
* `regfile_output_t` — same package. Bundle of all regfile outputs:
  `DR_data`, `SR_data`, `SIB_IDX_data`, `SIB_BASE_data`, `ECX_data`,
  `EAX_data`, `CS_data`, `Segment0_data`, `Segment1_data`,
  `regFileValues_o[NUM_REGS]`.
* `rr_cs_t` — `rtl/core/pkgs/core_stage_latches_pkg.sv`. The control-store
  fields RR consumes: `dr_id`, `sr_id`, `seg_0_id`, `seg_1_id`,
  `seg_1_valid`, `dr_rd`, `sr_rd`, `eax_rd`, `dr_wr`, `sr_wr`, `eax_wr`,
  `LD_OP`, `ST_OP`, `MODRM_NEEDED`, `RM_IS_DR`, `ST_SEL`, `MOVS_OP`,
  `SWITCH_LD_ADDY`, `special_br`, `special_modrm_bs`, `datasize`,
  `will_mod_zf`.
* `segment_limit_reg_entry_t` — `rtl/core/RR/pkg/RegisterRead_pkg.sv`.
  Holds `uint32_t limit`.

## Struct unrolling rule (per project convention)

When a structural module needs to expose or accept a struct-typed
signal, **do not pack into one giant wire**. Instead expose **one port
per field**. Example for RegFile: instead of one packed `outputs` port,
expose `DR_data`, `SR_data`, `SIB_IDX_data`, ..., plus 26 separate
`REG_<NAME>_o` ports for the per-register backing values. The parent
`RR_structural.sv` then re-aggregates these into a `regfile_output_t`
struct with simple `assign` statements, so the rest of RR (which still
uses the struct) is untouched.

## Macros (see `lib/STDCells/STDCell_Macros.vh`)

Argument order is **always** `name, width, out, in0, in1, ...` for combinational
gates. Notable macros:

| Macro              | Signature                                                       | Behavior                              |
| ------------------ | --------------------------------------------------------------- | ------------------------------------- |
| `INV_N`            | `(name, width, in, out)`                                        | bitwise NOT                           |
| `AND_2..AND_12`    | `(name, width, out, in0, in1, ...)`                             | N-input AND                           |
| `OR_2..OR_12`      | same                                                            | N-input OR                            |
| `NAND_*`, `NOR_*`  | same                                                            | NAND / NOR                            |
| `MUX_2`            | `(name, width, out, in0, in1, sel)`                             | `sel ? in1 : in0`                     |
| `MUX_4/8/16/32/64` | same with respective input count, sel width = log2(N)           | one-hot positional select             |
| `CMP_N`            | `(name, width, out, in0, in1)`                                  | `out = (in0 == in1)`                  |
| `ADD_N`            | `(name, width, sum, cout, in0, in1, cin)`                       | Kogge-Stone adder                     |
| `REG_RST_WE`       | `(name, width, clk, rst, we, d, q)`                             | active-LOW sync rst, active-high we   |
| `REG_RST`          | `(name, width, clk, rst, d, q)`                                 | same, we tied 1                       |
| `DECODER_N`        | `(name, inputs, in, out)`                                       | one-hot decoder                       |
| `ROM_32W_64b`      | `(name, ADDR, OE, dout)`                                        | 32-word × 64-bit ROM                  |

**Rules of thumb:**
* Every signal is driven by exactly one gate or `assign`.
* Multi-bit constants like `8'h00` / `8'hFF` / `7'b0` are fine in macro args.
* Bit-slice continuous-assigns (e.g. `assign x[7:1] = 7'b0; assign x[0] = ...;`)
  are valid Verilog 2005 and are commonly used here to compose multi-bit values
  without resorting to concatenation in expressions.
* Subtraction is implemented as "add the two's-complement", e.g.
  `dec_neg_8b = dec ? 8'hFF : 8'h00`, then `ADD_N(counter, dec_neg_8b, cin=0)`.

## Reset folding pattern

The SV side often writes `if (!rst || flush || callFlush || farFlush) ...`.
The structural form folds that into a single active-low reset wire feeding
`REG_RST_WE.rst`:

```
NOR_3(nor_flushes, 1, flushes_none, flush, callFlush, farFlush)   // ~(any flush)
AND_2(and_combined, 1, combined_rst_n, rst, flushes_none)          // rst & ~flushes
```

Then every register slot uses `combined_rst_n` as its `.rst`.

## RegSB module — algorithm (from `RegSB.sv`)

26 8-bit counters, one per `reg_ids_e` slot. Each cycle the counter is
updated as `counter_next = counter + inc - dec` (mod 256), where `inc`
and `dec` are derived from the inputs.

### Increment paths (gated by `updateSB = ~dep_stall & instructionforward`)

The SV expresses this via two branches based on `cs_wr_to_both`:

```
cs_wr_to_both = cs_dr_wr & cs_sr_wr & (dr_id == sr_id);

if (cs_wr_to_both) begin
    // dr/sr collapse into a single increment at dr_id (because
    // they target the same physical register).
    if (updateSB) next[dr_id]++;
end else begin
    if (cs_dr_wr   && updateSB) next[dr_id]++;
    if (cs_sr_wr   && updateSB) next[sr_id]++;
    if (cs_eax_wr  && updateSB) next[EAX]++;
end
```

Translated to per-slot R logic:

| Term            | Condition                                                |
| --------------- | -------------------------------------------------------- |
| `dr_inc_R`      | `updateSB & cs_dr_wr & (dr_id == R)`                     |
| `sr_inc_R`      | `updateSB & cs_sr_wr & (sr_id == R) & ~cs_wr_to_both`    |
| `eax_inc_R`     | only at R==EAX: `updateSB & cs_eax_wr & ~cs_wr_to_both`  |
| `inc_R`         | `dr_inc_R \| sr_inc_R \| eax_inc_R` (capped at 1)        |

Note: `dr_inc_R` is **not** gated by `~cs_wr_to_both` because the SV
still increments `dr_id` in the `cs_wr_to_both` branch (cs_dr_wr is
implied true there).

### Decrement paths (always live, no `updateSB` gate)

```
wb_wr_to_both = wb_dr0_we & wb_dr1_we & (wb_dr0_id == wb_dr1_id);

if (wb_wr_to_both) begin
    next[wb_dr0_id]--;
end else begin
    if (wb_dr0_we) next[wb_dr0_id]--;
    if (wb_dr1_we) next[wb_dr1_id]--;
end
```

Per-slot R:

| Term       | Condition                                                  |
| ---------- | ---------------------------------------------------------- |
| `wb0_dec_R`| `wb_dr0_we & (wb_dr0_id == R)`                             |
| `wb1_dec_R`| `wb_dr1_we & (wb_dr1_id == R) & ~wb_wr_to_both`            |
| `dec_R`    | `wb0_dec_R \| wb1_dec_R`                                   |

### Counter update

```
inc_8b_R       = {7'b0, inc_R}                       // 8-bit zero-extended
dec_neg_8b_R   = dec_R ? 8'hFF : 8'h00               // sign-extended -dec_R
counter_plus   = ADD_N(counter_R, inc_8b_R, cin=0)
counter_next_R = ADD_N(counter_plus, dec_neg_8b_R, cin=0)
REG_RST_WE(REG_R, 8, clk, combined_rst_n, 1'b1, counter_next_R, counter_R)
```

`we` is tied to `1'b1` because the +0 -0 case naturally holds the value.

### Stall paths (each is a 32-input MUX over the 26 counters + 6×8'h00)

For source ID `sel` ∈ {dr_id, sr_id, sib_base_id, sib_idx_id,
Segment0_ID, Segment1_ID}:

```
counter_lookup = MUX_32(counter_CS, counter_DS, ..., counter_NO_REG,
                        8'h00 ×6, sel)
nonzero        = ~(counter_lookup == 8'h00)
stall_path     = nonzero & gate
```

| Path             | Gate                                  |
| ---------------- | ------------------------------------- |
| `dr_stall`       | `cs_dr_rd & (LD_OP \| ST_OP \| REP_OP)` |
| `sr_stall`       | `cs_sr_rd & (LD_OP \| ST_OP \| REP_OP)` |
| `seg0_stall`     | (no gate — always considered)         |
| `seg1_stall`     | `Segment1_valid`                      |
| `sib_base_stall` | `cs_sib_size`                         |
| `sib_idx_stall`  | `cs_sib_size`                         |

`eax_stall` is hardcoded `0` in the SV (the line is commented out), so
the structural simply does not generate an `eax_stall` and `dep_stall`
ORs only the six paths above.

```
dep_stall = dr_stall | sr_stall | seg0_stall | seg1_stall
          | sib_base_stall | sib_idx_stall
```

### Direct status outputs

```
ecx_sb     = (counter_ECX != 0)
codeSeg_sb = (counter_CS  != 0)
```

## RegFile module — algorithm

Each register R is a 64-bit `REG_RST_WE` with:

```
match0_R = (WB_DR0_ID == R)
match1_R = (WB_DR1_ID == R)
we0_R    = WB_DR0_we & match0_R
we1_R    = WB_DR1_we & match1_R
we_R     = we0_R | we1_R
din_R    = MUX_2(we0_R ? WB_DR0_data : WB_DR1_data)   // DR0 wins on collision
REG_RST_WE(REG_R, 64, clk, rst, we_R, din_R, REG_R_o)
```

(There is no flush/callFlush/farFlush on the regfile — only `rst`.)

The read ports are MUX_32s over the 26 register backing values, indexed
by `DR_ID`, `SR_ID`, `SIB_IDX_ID`, `SIB_BASE_ID`, `Segment0_ID`,
`Segment1_ID`, with slots 26..31 tied to 0. `ECX_data`, `EAX_data`,
`CS_data` are direct constant-index reads (lower 32 bits of REG_ECX_o /
REG_EAX_o / REG_CS_o).

## Pattern checklist when porting

1. List every SV input/output and its width. For struct ports, **unroll
   into per-field ports** rather than concatenating.
2. List every internal SV signal. Each becomes one or more `wire`s in
   structural form.
3. Translate every `if/else` and ternary into AND/OR/MUX gate
   expressions. Capture `~X` with `INV_N`.
4. Translate every `+ / -` into `ADD_N` chains; subtraction → "add the
   two's complement" with a `MUX_2(8'h00, 8'hFF, sub)` or equivalent.
5. Translate every comparison into `CMP_N`.
6. Translate every state element into `REG_RST_WE` (or `REG_RST` if
   always-enabled). Fold reset/flush conditions into a single
   active-low net.
7. Re-aggregate unrolled fields back into the struct in the **parent**
   module so consumers don't have to change.
8. Update the parent module's instantiation to match the new (unrolled)
   port list.
9. Make sure the structural module's outputs **never** carry a
   SystemVerilog construct (no struct, no enum) — they should always be
   `wire` of an explicit width.
