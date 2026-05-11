# EXE Stage — Design Report

## 1. Overview

The EXE (Execute) stage takes operands from the Register-Read stage and the load buffer from MEM, runs the actual computation, and produces three outputs: an updated destination register, an updated source register (some ops write both), and a packed store-result buffer for memory writes. It also resolves branches and emits the misprediction flush back to Fetch. It is a **single-cycle stage**.

The interesting thing about EXE is not any individual functional unit — it is the *organization* of the stage. All functional units run in parallel every cycle. Only one is "active" per instruction (selected by the op-type), but every unit's inputs are driven and every unit's output is computed. The stage avoids a deep, wide mux tree by using **tristate-driver result buses**: each FU's result is gated onto a shared bus by a tristate driver enabled by the op-type decode, and a final 2:1 mux at the end picks bus-or-default. This shortens the result-selection path compared to a wide multiplexer. Per-flag selection works the same way, one small selector per flag bit instead of one wide flag mux.

Two pieces of cross-stage work also live here on purpose: **load-data alignment** (deferred from MEM) and **store-data alignment** (deferred from the back end). Both are simple byte-array indexing — there is no behavioral barrel-shifter in this stage.

## 2. Interesting Features

- **Parallel FU dispatch with tristate-mux result selection** — every functional unit runs every cycle on the same `srA`/`srB`. Result selection (`dr_sel`, `sr_sel`, `res_buf_sel`) uses tristate drivers gated by op-type match instead of a wide OR / mux tree, keeping the result path shallow.
- **Three independent result paths in parallel** — destination register (`dr_sel`), source register / second writeback (`sr_sel`), and the store-data buffer (`res_buf_sel` → `res_buf_logic`). Each is its own selector, fed by its own subset of FUs.
- **Per-flag selectors instead of one wide flag mux** — each architectural flag (ZF, CF, OF, PF, SF, AF, DF) has its own small `*_flag_sel` module. Flags from different FUs get muxed in cheaply, one bit at a time.
- **Load-data alignment lives here** — the 32-byte `ld_buf` from MEM is indexed by the low bits of the load address inside [alu_input_sel.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/alu_input_sel.sv) to pull out the 16-byte window that feeds the operand muxes.
- **Store-data alignment also lives here** — [res_buf_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/res_buf_logic.sv) takes the chosen FU result and the store address's byte offset and packs the bytes into a 2-cache-line (256-bit) store buffer that WB drains.
- **Branch resolution runs in parallel with FU execution** — [branch_res.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/branch_res.sv) takes the branch target from the operand path, compares against the prediction held in the IDM slot, and emits the misprediction / flush back to Fetch the same cycle.
## 3. Stage Organization

```
   ┌──────────────────────────────────────────────────────┐
   │                  EXE stage  (one cycle)              │
   │                                                      │
   │   from RR:  DR, SR, EAX, EIP, FLAGS, immediates      │
   │   from MEM: ld_buf [32 B], ld_addr                   │
   │             ──────────────┬───────────                │
   │                           ▼                          │
   │              ┌─────────────────────────┐             │
   │              │     alu_input_sel       │             │
   │              │  - extract 16 B window  │             │
   │              │    from ld_buf by addr  │             │
   │              │  - mux operands → srA   │             │
   │              │  - mux operands → srB   │             │
   │              │  - branch target select │             │
   │              └────────────┬────────────┘             │
   │                           │ srA, srB                 │
   │           ┌───────────────┼───────────────┐          │
   │           ▼               ▼               ▼          │
   │     ┌──────────┐   ┌──────────┐   ┌──────────┐       │
   │     │   FU 0   │   │   FU 1   │ ..│  FU N    │       │
   │     │ ADD/AND/ │   │ SAL/SAR/ │   │ SIMD,    │       │
   │     │  CMP …   │   │  PUSH …  │   │ FAR_CALL │       │
   │     └────┬─────┘   └────┬─────┘   └────┬─────┘       │
   │          │ all FUs run in parallel     │             │
   │          ▼              ▼              ▼             │
   │   ────────  tristate result buses  ─────────────     │
   │     dr_sel       sr_sel       res_buf_sel            │
   │       │            │              │                  │
   │       ▼            ▼              ▼                  │
   │   ┌──────┐    ┌──────┐     ┌─────────────────┐       │
   │   │ DR   │    │ SR   │     │  res_buf_logic  │       │
   │   │ next │    │ next │     │  pack into 2-CL │       │
   │   └──┬───┘    └──┬───┘     │  byte buffer    │       │
   │      │           │         └────────┬────────┘       │
   │      ▼           ▼                  ▼                │
   │   reg_wb_logic        bit_vec_logic (per-byte mask)  │
   │      │                          │                    │
   │      ▼                          ▼                    │
   │   to WB latches: dr_next, sr_next, res_buf, bit_vec  │
   │                                                      │
   │   in parallel:                                       │
   │     branch_res ─► flush / target back to Fetch       │
   │     flag_sel/* ─► individual flag bits → flags_reg   │
   └──────────────────────────────────────────────────────┘
```

Operand prep, FU dispatch, and result collection are all combinational inside the cycle. The latch boundary at the output captures the destination register, source register, packed store buffer, byte mask, branch result, and updated flags into the WB-stage latch.

## 4. Per-Block Walkthrough (Organizational Blocks Only)

The functional units themselves are not described here — the report is about how the stage is organized around them.

- **[EXE.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/EXE.sv)** — top-level wiring. Instantiates `alu_input_sel`, every functional unit (each consuming `srA`/`srB`), the result selectors (`dr_sel`, `sr_sel`, `res_buf_sel`), `res_buf_logic`, `bit_vec_logic`, `branch_res`, the `flag_sel/*` per-flag muxes, `reg_wb_logic`, and the truth-table-based `gen/wb_valid_logic.v` for handshake. Outputs the WB latch.

- **[alu_input_sel.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/alu_input_sel.sv)** — operand selection front-end. Pulls a 16-byte window out of the 32-byte `ld_buf` using the load-address byte offset, then muxes the available sources (DR, SR, EAX, immediate, EIP/NEIP, FLAGS, the extracted load bytes) onto `srA` and `srB`. Also computes the branch target operand. Handles the 8-bit-high register case (`AH`) by exposing pre-shifted `srB` versions.

- **[FunctionalUnits/](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/FunctionalUnits/) (treated as a block)** — many small SV modules, each taking `srA`/`srB` (and sometimes flags) and emitting a 64-bit result plus the flag bits it touches. They run in parallel. The categories present are arithmetic/logic, shifts/bit-ops, stack/control-flow (PUSH/POP/CALL/RET in their various forms), data movement (MOV/XCHG/MOVS), SIMD-packed, and exception-flow units (FAR_JMP, EXP_CALL, IRETD).

- **[dr_sel.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/dr_sel.sv)** — destination register result selector. One tristate driver per candidate FU result, all gated by op-type match, all driving a shared bus. A final 2:1 mux between the bus and the existing `dr_data` (passthrough default) produces `dr_next`.

- **[sr_sel.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/sr_sel.sv)** — source-register result selector. Same tristate-bus pattern; the smaller subset of FUs that write the source register (POP, PUSH, CALL, XCHG, etc.) drive this bus. Default passthrough is `sr_data`.

- **[res_buf_sel.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/res_buf_sel.sv)** — store-data result selector. Same pattern again; the FUs that produce stored data (ADC, ADD, AND, MOV, PUSH, CALL, etc.) drive this bus. Default is zero.

- **[res_buf_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/res_buf_logic.sv)** — store-data alignment. Takes the 64-bit selected result and the store-address byte offset (`ST_PADDR_0[3:0]`) and writes the bytes into the right slots of a 256-bit (2-cache-line) buffer. WB drains the buffer into the store queue.

- **[bit_vec_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/bit_vec_logic.sv)** — generates the per-byte valid-mask for the store. Maps the 2-bit data-size to a byte count, then sets the correct contiguous run of bits in `ST_BIT_VEC_0` (and `ST_BIT_VEC_1` if the store crosses the cache-line boundary).

- **[branch_res.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/branch_res.sv)** — branch resolution. Computes the actual taken/not-taken decision and the actual target from the operand path and the resolved flags. Compares against the prediction information that traveled with the instruction in the IDM slot and asserts mispredict/flush, plus the correct redirect target back to Fetch. Also emits special control flush signals (far-jmp, call, exception-mode-clear).

- **[flag_sel/](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/flag_sel/) (one module per architectural flag)** — `zf_flag_sel`, `cf_flag_sel`, `of_flag_sel`, `pf_flag_sel`, `sf_flag_sel`, `af_flag_sel`, `df_flag_sel`. Each is a small mux that picks the bit produced by the active FU and writes it into the architectural flags register, with a special blocker for REP-prefixed instructions (which suppress flag updates).

- **[reg_wb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/reg_wb_logic.sv)** — routes the two write-back ports. `DR_0` carries `dr_next` (with the destination register ID, swapped for CS on `EXP_CALL`); `DR_1` carries `sr_next`, except on `WB_EAX` where it instead carries the `cmpxchg` EAX result. Write enables are gated by the per-port WB control bits and the back-end stall.

- **[gen/wb_valid_logic.v](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/gen/wb_valid_logic.v)** — auto-generated 2-input / 2-output handshake from a truth table. Inputs `EXE_V`, `WB_stall`; outputs `WB_we`, `N_WB_V`. Same pattern as the MEM stage's truth-table handshake — keep the cross-stage valid path off behavioral logic.

The [structural/](design/EverythingEverywhereAllAtOnce/rtl/core/EXE/structural/) folder contains synthesis-targeted versions of every block.

## 5. Interesting Features — In Depth

### 5.1 Parallel FU Dispatch with Tristate-Mux Result Selection

The naive way to build this stage would be a giant case statement: "based on op-type, pick which FU's result to forward." Synthesized, that becomes a wide multi-input mux on the result bus and tends to dominate the cycle.

This stage does it differently:

- Every FU runs every cycle on `srA`/`srB`. There is no input-side dispatch.
- Each FU's output drives a tristate onto the shared bus, whose enable is the `(op_type == this_FU)` match.
- All the tristates share a single bus.
- A final 2:1 mux between that bus and a passthrough default (`dr_data` / `sr_data` / `0`) produces the selector's output.

The op-type decode that drives the tristate enables runs in parallel with the FUs; it does not sit in series with them. The result bus has many drivers but only one is enabled in any given cycle. Practically, this turns "wide selection mux" into "shared bus with one driver active," which is the design choice that keeps the result-selection delay short.

### 5.2 Three Independent Result Paths

The stage doesn't have one result selector — it has three:

- **`dr_sel`** drives the destination-register write-back. Largest set of candidate FUs.
- **`sr_sel`** drives the source-register write-back. Used by the smaller set of ops that write both registers (push/pop, xchg, call, etc.).
- **`res_buf_sel`** drives the *store data* — the bytes that go to memory, not to a register.

Each is its own tristate bus with its own subset of FUs as drivers. This is cleaner than one giant selector with multiple fan-outs because each bus has a smaller driver count, and the three results have different consumers (register file vs. store buffer) and different downstream alignment needs.

### 5.3 Per-Flag Selection

Architectural flags (`ZF`, `CF`, `OF`, `PF`, `SF`, `AF`, `DF`) come from many different FUs, and not all FUs touch every flag. Rather than building one fat "flags" mux that takes 7-bit tuples from every FU, this stage has **one selector per flag**:

- `zf_flag_sel` picks ZF from {ADC, ADD, AND, BSF, CMP, CMPXCHG, OR, SAL, SAR, SBB, IRETD, REP_CMP} or holds.
- `cf_flag_sel`, `of_flag_sel`, etc. each pick from their own (smaller) FU set.

Each selector is 1 bit wide instead of 7, and each one only sees the FUs that actually touch its flag. The REP-prefixed-instruction flag-suppression case is handled inside each module locally.

### 5.4 Load-Data Alignment Deferred to EXE

MEM forwards a 32-byte `ld_buf` and the load address but does **no** alignment. EXE handles it inside `alu_input_sel`:

```
res_buf_offset = ld_addr_0[ low bits ]
for i in 0..15:
    extracted[i] = ld_buf[res_buf_offset + i]
```

The extracted 16-byte window then enters the operand mux as one of the choices for `srA`/`srB`. Sign-extension for narrower data types is folded into the mux cases (`SEXT8`, etc.). The end result: no separate barrel-shifter exists for loads — the array index *is* the shift.

### 5.5 Store-Data Alignment Deferred to EXE

Symmetrical to loads. The chosen FU result (selected by `res_buf_sel`) is 64 bits. `res_buf_logic` packs those 8 bytes into a 256-bit two-cache-line buffer at the position determined by `ST_PADDR_0[3:0]`:

```
for i in 0..7:
    res_buf[i + offset] = selected[i*8 +: 8]
```

`bit_vec_logic` builds the matching per-byte valid mask, splitting it across two cache-line halves if the store crosses the boundary. Both pieces flow into the WB store queue together.

### 5.6 Branch Resolution in Parallel

`branch_res` runs in parallel with the FUs. Its inputs are: the branch's resolved target operand (from `alu_input_sel`), the live flags (from the back end of the cycle), and the prediction information that traveled with the instruction in the IDM slot.

Outputs: the misprediction bit, the correct target, and a set of flush flavors (regular flush, far-jump flush, call flush, exception-mode-clear). This is what feeds the front-end redirect path back into the SPC mux in Fetch.

## 6. Critical Path / Timing

The dominant arc in EXE runs from `srA`/`srB` (out of `alu_input_sel`), through whichever FU is the slowest of the parallel set, through the tristate result bus, through the final 2:1 mux, into the WB-stage latch. The tristate-mux pattern is what keeps this path shallow despite having many candidate drivers.

This arc contributes to the overall **11.2 ns** clock period but was not the binding stage — the Decode stage set the cycle time.

Two secondary arcs:

- **`branch_res` → flush/target back to Fetch** — runs in parallel but feeds an externally-visible signal (the front-end redirect). If it ever exceeds the FU arc, the stage's clock isn't the binding number anymore — Fetch's SPC mux is.
- **Op-type decode → tristate enable** — must settle before the corresponding tristate fires onto the bus. If this ever overtook the FU-output arc, the tristate-mux pattern would lose its win.

## 7. Design Considerations and Trade-offs

- **All FUs run every cycle**: avoids the input-side dispatch mux that would otherwise sit in series with the FUs; timing is much better than a dispatch-then-compute organization, at the cost of some extra toggling in unused FUs.
- **Tristate result buses over wide muxes**: shortens the result-selection path compared to a multi-input mux, since only one driver is active per cycle and the bus collapses many candidate results onto a single wire.
- **Three result paths instead of one**: more wiring, but each bus has fewer drivers and a clearer downstream consumer.
- **Per-flag selection over a fat flag mux**: many small modules instead of one big one, but each is trivial and the timing per bit is short.
- **Alignment for loads and stores in EXE**: reuses the byte-array indexing pattern that fits naturally next to operand selection; avoids a separate alignment stage.
- **Branch resolution in EXE**: misprediction penalty is "EXE → flush back to Fetch in the next cycle." Earlier resolution would require a parallel mini-execute earlier in the pipe, which would duplicate hardware.

## 8. Conclusions

EXE is a single-cycle stage with a deliberately flat shape: every functional unit runs every cycle, every result selector is a tristate-driven shared bus, every flag has its own small selector, and the alignment work for loads and stores is folded into the same byte-indexing operand-mux that prepares `srA`/`srB`. The result is a stage with many functional units but a shallow critical path — the hard timing problem (selecting one of many results) is solved by the shared-bus pattern rather than with extra pipe stages.

A natural next design would (1) split EXE into two cycles to relax the FU + selector path (at the cost of adding bypass logic for back-to-back dependencies), and (2) move branch resolution earlier in the pipe to reduce the misprediction penalty.
