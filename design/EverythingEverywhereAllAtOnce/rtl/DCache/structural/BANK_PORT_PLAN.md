# DCache Bank Structural Port — Plan & Loop Analysis

This document is the design record for the structural port of the DCache
Bank trio: `DCache_Bank_TagStore`, `DCache_Bank_DataStore`, `DCache_Bank`.
It captures the (we, d) decomposition for every register, the gate netlist
for every combinational output, and a full combinational-loop audit.

Reference SV files (DO NOT TOUCH):
- `rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank.sv`
- `rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank_TagStore.sv`
- `rtl/DCache/DCache_Block/DCache_Bank/DCache_Bank_DataStore.sv`
- `rtl/DCache/gen/DCache_Bank_FSM.sv` (already structural — instantiated as-is)

Reuse: `ram8b8w$` primitive instantiated directly (no macro wrapper —
matches existing SV pattern).

---

## Files

| Action | File |
|---|---|
| **Create** | `structural/DCache_Bank_TagStore.v` (module `DCache_Bank_TagStore_struct`) |
| **Create** | `structural/DCache_Bank_DataStore.v` (module `DCache_Bank_DataStore_struct`) |
| **Create** | `structural/DCache_Bank.v` (module `DCache_Bank_struct`) |
| **Modify** | `structural/DCache_Block.sv` — `` `ifdef USE_STRUCTURAL_BANK `` swap around bank instance |
| **Modify** | `structural/DCache_TOP.sv` — add commented `` `define USE_STRUCTURAL_BANK `` to flag block (no other change; vcache, MIO, arbitration untouched) |
| **Modify** | `structural/STRUCTURAL_PORT_GUIDE.md` — append row to ported-modules table |
| **Untouched** | `structural/DCache_Bank.sv`, `structural/DCache_Bank_TagStore.sv`, `structural/DCache_Bank_DataStore.sv` (SV fallback) |
| **Untouched** | All `rtl/DCache/*` originals, vcache, MIO, arbitration |

---

## Module 1: `DCache_Bank_TagStore_struct`

### Storage
- 1× `ram8b8w$` (direct primitive instance, no macro). Address = 3-bit
  `index = p_addr_i[8:6]`. Stores 6-bit tag in bits `[5:0]` of an 8-bit
  word (top 2 bits zero — DIN = `{2'b00, p_addr_i[14:9]}`).
- 8× `REG_RST_WE(1)` for per-line `valid`.
- 8× `REG_RST_WE(1)` for per-line `dirty`.

### Per-line we / d derivation
- `index_decoded[7:0] = DECODER_N(3, p_addr_i[8:6])`
- `fill_or_ldswap = OR_2(fill3_i, ld_From_V_Swap_i)`
- For each line `i ∈ [0..7]`:
  - `valid_we[i] = AND_2(index_decoded[i], fill_or_ldswap)`
  - `valid_d[i]  = 1'b1`  (alias)
  - `dirty_ws_event[i]   = AND_2(index_decoded[i], writeSuccess)`   ← priority 1
  - `dirty_fill_event[i] = AND_2(index_decoded[i], fill_or_ldswap)` ← priority 2
  - `dirty_we[i] = OR_2(dirty_ws_event[i], dirty_fill_event[i])`
  - `ldswap_dirty = AND_2(ld_From_V_Swap_i, V_Cache_SwapBuf_DirtyBit)` (computed once, shared)
  - `dirty_d[i]  = MUX_2(sel=dirty_ws_event[i], in0=ldswap_dirty, in1=1'b1)`
    (writeSuccess wins → 1; else load-swap value)

### Combinational outputs
- `currLine_V_o     = MUX_8(8 valid q-outputs, sel=index)`
- `currLine_Dirty_o = MUX_8(8 dirty q-outputs, sel=index)`
- `tagOut_o = DOUT_extended[5:0]` (slice — pure wire alias)

### Phased-clock RAM write gate
- `BUFFER_DELAY(u_phase, 10, 1, clk, clk_45_phase)` — 10 stages × 0.25 ns = 2.5 ns
- `WR_event = AND_2(rst, fill_or_ldswap)`            ← rst gating (rst=1 means "go")
- `WR_phased = AND_2(WR_event, clk_45_phase)`
- `WR_2_TagStore_actual = INV_N(WR_phased)`           ← active-low to ram8b8w$

### Read OE gate
- `oe_or_we      = OR_2(oe_i, we_i)`
- `not_busy      = INV_N(bankControllerBusy_i)`
- `access_active = AND_2(oe_or_we, not_busy)`
- `read_event    = OR_2(access_active, write2_Dwap_i)`
- `rst_and_read  = AND_2(rst, read_event)`
- `OE_2_TagStore = INV_N(rst_and_read)`               ← active-low

### Ports (flat)
Inputs: `clk`, `rst`, `p_addr_i[14:0]`, `oe_i`, `we_i`, `ld_From_V_Swap_i`,
`V_Cache_SwapBuf_DirtyBit`, `fill3_i`, `write2_Dwap_i`,
`bankControllerBusy_i`, `writeSuccess`.
Outputs: `tagOut_o[5:0]`, `currLine_V_o`, `currLine_Dirty_o`.

---

## Module 2: `DCache_Bank_DataStore_struct`

### Storage
- 16× `ram8b8w$` (direct primitive, instantiated via Verilog `generate
  for` — same pattern as the SV at lines 81–93). One byte per cell. All
  share the 3-bit address and OE; each has its own WR and DIN/DOUT.

**No additional flops.** All gating is combinational.

### Per-byte write enable (mutually-exclusive priority by FSM construction)
- `any_high_pri = OR_5(ld_From_V_Swap_i, fill0_i, fill1_i, fill2_i, fill3_i)`
- `no_high_pri  = INV_N(any_high_pri)`
- `not_busy     = INV_N(bankControllerBusy_i)`
- For each `i ∈ [0..15]`:
  - `store_event[i] = AND_5(st_data_vec[i], we, not_busy, tagStore_hit_i, no_high_pri)`
  - `byte_write[i]  = OR_3(ld_From_V_Swap_i, fillN_i, store_event[i])`
    where `fillN_i` is `fill0` for `i∈0..3`, `fill1` for `4..7`, `fill2`
    for `8..11`, `fill3` for `12..15`.
- Phased gate (single shared phased clock):
  - `BUFFER_DELAY(u_phase, 10, 1, clk, clk_45_phase)`
  - `byte_write_en[i]  = AND_3(byte_write[i], rst, clk_45_phase)`
  - `WR_2_DataStore_actual[i] = INV_N(byte_write_en[i])`  ← active-low

### Per-byte DIN mux (priority: ld > fillN > store)
For each byte `i`:
- `mid[i] = MUX_2 #(8)(sel=fillN_i, in0=stq_data_i[i*8 +: 8], in1=dataBus_i[(i mod 4)*8 +: 8])`
- `DIN_2_DataStore[i] = MUX_2 #(8)(sel=ld_From_V_Swap_i, in0=mid[i], in1=vcache_swapBuf_line_i[i*8 +: 8])`

### Read OE gate
- `oe_and_not_busy = AND_2(oe, not_busy)`
- `oe_event       = OR_2(write2_Dwap_i, oe_and_not_busy)`
- `OE_2_DataStore = INV_N(oe_event)`                    ← active-low

### Output
- `lineOut_o[127:0] = { DOUT[15], DOUT[14], …, DOUT[0] }` — wire concat
  (LSB-first byte ordering, matches existing pack/unpack convention in
  EvictionBuf adapter and in DCache_Block lines 207–225).

### Ports (flat, cache lines as 128-bit wires per user exception)
Inputs: `clk`, `rst`, `p_addr_i[14:0]`, `oe`, `we`, `ld_From_V_Swap_i`,
`fill0_i..fill3_i`, `write2_Dwap_i`, `bankControllerBusy_i`,
`stq_data_i[127:0]`, `st_data_vec[15:0]`, `vcache_swapBuf_line_i[127:0]`,
`dataBus_i[31:0]`, `tagStore_hit_i`.
Output: `lineOut_o[127:0]`.

---

## Module 3: `DCache_Bank_struct`

### Registers (all `REG_RST_WE`, async active-low rst)

| Name | Width | we | d |
|---|---|---|---|
| `swapBuf_valid`     | 1   | `OR_2(vcache_DCache_swapBuf_valid_clr_i, fsm_write_to_dswap)` | `MUX_2(sel=vcache_DCache_swapBuf_valid_clr_i, in0=fsm_write_to_dswap, in1=1'b0)` |
| `swapBuf_dirty`     | 1   | `fsm_write_to_dswap` | `currLineDirty` |
| `swapBuf_lineAddr`  | 15  | `fsm_write_to_dswap` | `{currTag[5:0], index[2:0], bank[1:0], 4'b0000}` |
| `swapBuf_line`      | 128 | `fsm_write_to_dswap` | `dataStore_line[127:0]` |
| `savedReq_oe`       | 1   | `saveReq` | `blockReq_oe_i` |
| `savedReq_we`       | 1   | `saveReq` | `blockReq_we_i` |
| `savedReq_paddr`    | 15  | `saveReq` | `blockReq_paddr_i` |
| `savedReq_stq_data` | 128 | `saveReq` | `blockReq_stq_data_i` |
| `savedReq_vec`      | 16  | `saveReq` | `blockReq_vec_i` |

Where `saveReq = INV_N(fsm_busy)`.

### Combinational netlist
- `useSavedReq` ← alias of `fsm_busy`
- 5× `MUX_2` per savedReq field → `reqInUse_*` (each is `MUX_2(sel=useSavedReq, in0=blockReq_*_i, in1=savedReq_*_q)`)
- Address slices (wire aliases):
  - `tag    = reqInUse_paddr[14:9]`
  - `index  = reqInUse_paddr[8:6]`
  - `bank   = reqInUse_paddr[5:4]`
  - `offset = reqInUse_paddr[3:0]`
- `oe_or_we     = OR_2(reqInUse_oe, reqInUse_we)`
- `not_busy_ext = INV_N(block_busy_i)`
- `doAccess     = AND_2(not_busy_ext, oe_or_we)`
- `tag_eq       = CMP_N(6, currTag, tag)`
- `tag_eq_and_v = AND_2(tag_eq, currLineValid)`
- `hit          = AND_2(tag_eq_and_v, doAccess)`
- `not_hit      = INV_N(hit)`
- `miss         = AND_2(doAccess, not_hit)`
- `writeSuccess2TagStore = AND_2(hit, reqInUse_we)`

### Sub-instances
- `DCache_Bank_FSM` (already structural, in `gen/`) — instantiated as-is.
- `DCache_Bank_TagStore_struct`
- `DCache_Bank_DataStore_struct`

### Outputs (flat, `d_cache_bank_outputs_t` fields)
- `dcacheBankOut_hit_o`                       ← `hit`
- `dcacheBankOut_swapBuf_valid_o`             ← swapBuf_valid q
- `dcacheBankOut_swapBuf_dirty_o`             ← swapBuf_dirty q
- `dcacheBankOut_swapBuf_addr_o[14:0]`        ← swapBuf_lineAddr q
- `dcacheBankOut_swapBuf_line_o[127:0]`       ← swapBuf_line q
- `dcacheBankOut_VCache_swapBuf_valid_clr_o`  ← `fsm_clr_v_swap`
- `dcacheBankOut_D_will_evict_o`              ← `fsm_D_will_evict`
- `dcacheBankOut_busy_o`                      ← `fsm_busy`
- `dcacheBankOut_data_lineOut_o[127:0]`       ← `dataStore_line`
- `dcacheBankOut_MakeReq_o`                   ← `fsm_MakeReq`
- `dcacheBankOut_eb_stalling_o`               ← `fsm_Blocked`

### Ports (flat)
Inputs: `clk`, `rst`, `vcache_miss_i`, `vcache_DCache_swapBuf_valid_clr_i`,
`vcache_swapBuf_dirty_i`, `vcache_swapBuf_line_i[127:0]`, `eb_reqHit_i`,
`mem_Valid_FromDte_i`, `blockReq_oe_i`, `blockReq_we_i`,
`blockReq_paddr_i[14:0]`, `blockReq_stq_data_i[127:0]`,
`blockReq_vec_i[15:0]`, `block_busy_i`, `dataBus[31:0]`.
Outputs: 11 unpacked `dcacheBankOut_*_o` listed above.

---

## Parent adapter (`structural/DCache_Block.sv`)

Wrap the existing bank instance (lines 50–60) with
`` `ifdef USE_STRUCTURAL_BANK / `else / `endif ``. Structural branch:

1. Pack byte-arrays into 128-bit buses (LSB-first concat — same pattern
   as the EB adapter at lines 79–98 of the current file):
   - `block_req_i.st_q_data[16]`           → `[127:0]`
   - `vcache_outputs.vcache_swapBuf.line[16]` → `[127:0]`
2. Instantiate `DCache_Bank_struct` with all flat ports.
3. Repack flat outputs back into `dcache_bank_outputs` struct fields:
   - 1-bit and 15-bit fields: direct `assign dcache_bank_outputs.* = …`
   - `data_lineOut[127:0]` and `dcache_swapBuf.line[127:0]`: `generate
     for (i = 0; i < CACHE_LINES_SIZE_B; i++) assign dcache_bank_outputs.*[i] = flat[8*i +: 8];`

Default (flag undefined) keeps the SV instance verbatim; no functional change.

---

## DCache_TOP changes

Append one line and one comment to the existing flag block:

```
// USE_STRUCTURAL_BANK -> structural/DCache_Bank.v + DCache_Bank_TagStore.v
//                       + DCache_Bank_DataStore.v   (parent: DCache_Block.sv)
//`define USE_STRUCTURAL_BANK
```

No other changes. No new TOP taps (existing `tap_block_hit`,
`tap_eb_addr`, `tap_block_req2sch` already cover the bank's externally
visible signals).

---

## Combinational-loop audit

Goal: every combinational signal must trace back to a flop output or a
top-level input on every path. No path may form a closed loop without at
least one flop in the cycle.

**Storage cells used as "flops" for this audit:** `REG_RST_WE` /
`REG_RST` instances (Bank swapBuf, savedReq, TagStore valid/dirty,
FSM state). The `ram8b8w$` cell's DOUT is combinational from the
address (async read), but the *stored* tag/data values are written only
on a phased-clock edge — for cycle analysis the RAM contents are
treated as flops; only the address→DOUT path is comb.

### Edges enumerated

External inputs to the Bank trio:
`clk, rst, V_Cache_i.*, eb_i.reqHit, mem_Valid_FromDte_i, blockReq_i.*,
block_busy_i, dataBus`.
Flop outputs:
`fsm_S_0..S_3, swapBuf_*_q, savedReq_*_q, tagMetaStore.valid[0..7],
tagMetaStore.dirty[0..7]`. RAM stored values: tag word, 16 data bytes
(per index).

Combinational dependency edges that involve a Bank-trio output feeding
back into a Bank-trio input:

1. `currTag` (RAM DOUT, comb-from-A) → `tag_eq` → `hit` → `miss` →
   FSM `D_Miss_i` → FSM combinational outputs → ... back into `A`?
   - `A = index = reqInUse_paddr[8:6]`. `reqInUse_paddr` ← MUX_2(useSavedReq, blockReq_paddr, savedReq_paddr_q).
   - `useSavedReq = fsm_busy`. FSM busy_o equation: purely
     `S_*` (no `D_Miss_i` dependency).
   - `savedReq_paddr` is a flop output.
   - **Conclusion:** the path back to `A` goes through `fsm_busy` which
     is a flop function. **No comb loop.** ✓

2. `hit` → `writeSuccess2TagStore` → TagStore `dirty` flop we/d →
   `currLine_Dirty_o`?
   - `currLine_Dirty_o` is a flop output (MUX_8 of dirty q-bits).
   - The write path is fully gated through `REG_RST_WE` clk edge.
   - **No comb loop.** ✓

3. `hit` → DataStore `tagStore_hit_i` → `WR_actual[i]` → RAM stored
   bytes → `lineOut_o` → ... back into `hit`?
   - `WR_actual[i]` is gated by `clk_45_phase` (a delayed clock).
     Storage updates only on this phased edge.
   - The byte storage is treated as a flop for this audit (writes are
     phased-clock-edge).
   - `lineOut_o` is comb from the storage and `A`. `lineOut_o` does not
     feed back into `hit`'s cone. (It feeds: swapBuf_line register d
     [flop break], DCache_Block dataLineOut output [exits the trio].)
   - **No comb loop.** ✓

4. `miss` → FSM `D_Miss_i` → `write_to_dswap_o` → `write2_Dwap_i` →
   TagStore `OE_2_TagStore` → RAM DOUT → `currTag` → `tag_eq` → `hit` →
   `miss` ?
   - Topologically, this is a cycle if we treat OE→DOUT as a comb edge.
     OE controls high-Z gating; when OE=0, DOUT=stored value
     (independent of OE); when OE=1, DOUT=z (does not propagate a
     well-defined logic value).
   - This identical cycle exists in the SV reference (the SV uses the
     same RAM cell with the same OE-gating), and the SV regression
     passes. The cycle does not form a logical feedback because DOUT's
     value (when defined, i.e. OE=0) is set by stored bits, not by OE.
   - **No NEW loop introduced by the structural port.** Behavior
     matches SV. ✓
   - Mitigation if simulator flags it: read RAM DOUT on a
     buffered/registered version of the address, not on the live OE
     gating. **Not required for parity with SV.**

5. `dataStore_line` → `swapBuf_line.d` flop → `swapBuf_line.q` →
   bank output → DCache_Block → VCache → `vcache_outputs` → DataStore
   inputs?
   - `swapBuf_line.q` is a flop output. **Loop broken.** ✓

6. FSM `we_i = reqInUse_we` ← MUX_2(useSavedReq=fsm_busy_o, …) →
   FSM internals → back into `we_i`?
   - FSM outputs that depend on `we_i`: NS_0..3 (next-state, flopped),
     and that's it (per the equations). NS_x feeds the state flops
     only. **Loop broken at the state flops.** ✓

7. `reqInUse_oe / we / paddr` → DataStore/TagStore inputs → outputs →
   FSM inputs → FSM outputs → back into `reqInUse`?
   - The mux selector is `fsm_busy`, which is a function of `S_*` only
     (no input dependency). **Loop broken.** ✓

8. `vcache_swapBuf_dirty_i` (external) → swapBuf_dirty register?
   - This signal feeds the `swapBuf_dirty.d` only via flop; not in any
     loop ✓. (Note: the register d input is `currLineDirty`, not
     `vcache_swapBuf_dirty_i`. The vcache dirty bit feeds TagStore
     `V_Cache_SwapBuf_DirtyBit`, which goes into TagStore's dirty
     register d through `ldswap_dirty`. Flop-broken.) ✓

### Findings

- **No new combinational loops introduced** by the structural port.
- One pre-existing comb cycle (item 4 above: write2_Dwap → OE → DOUT)
  is structurally identical to the SV behavior and is a tristate
  gating relationship rather than logical feedback. Tools that flag
  this should be configured to ignore it (or, if needed, the address
  can be registered separately — but that would diverge from SV).
- All other paths from a Bank-trio output back to a Bank-trio input
  pass through at least one `REG_RST_WE` / `REG_RST` flop or a
  phased-clock RAM write edge.

### Non-loop timing notes

- The structural cells introduce gate delays. Critical comb path
  inside the bank is approximately:
  `RAM access (~2 ns) → CMP_N(6) → AND × 2 → INV → AND` for the `miss`
  signal that feeds the FSM. Far below any reasonable cycle period.
- TagStore and DataStore RAM writes share a single `BUFFER_DELAY`
  phased clock (10 stages × 0.25 ns = 2.5 ns), matching the SV
  `#CLK_PHASE_DELAY` semantics.
- All `BUS_TRISTATE` drivers in `DCache_Block` operate on
  `eb_outputs.lineOut` and `eb_outputs.addr` (untouched by this port).

---

## Verification (post-implementation)

1. Lint: compile with `USE_STRUCTURAL_BANK` undefined and defined.
   Both must elaborate. The `USE_STRUCTURAL_EB` flag must remain
   independently togglable.
2. Regression: existing DCache test suite must pass with each combination
   of {EB SV/struct, BANK SV/struct} = 4 modes.
3. Spot-check: confirm `swapBuf_valid` rises on `write_to_dswap`, falls
   on `D_Cache_swapBuf_valid_clr`, and that `tagStore.dirty[i]` becomes
   sticky after first `writeSuccess` on line `i`.
