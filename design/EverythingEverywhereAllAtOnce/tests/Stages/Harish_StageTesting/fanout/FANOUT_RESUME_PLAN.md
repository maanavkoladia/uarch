# Fanout Optimization — Resume Plan

Pick up where we left off. The flow stays the same: `make check` → `python3 scripts/fanout_optimize.py --check-log ./check.log --module dcache --output reports/dcache_fanout_plan_RX.md` → review → fix → repeat.

Snapshots so far in `tests/Stages/Harish_StageTesting/fanout/`:
- `check.log.dcache_r3` — 247 violations (after 4× bufferH256$ on busy_o/ldFrom_V_swap_o/store_path)
- `check.log.dcache_r4` — 173 (−58)
- `check.log.dcache_r5` — 65 (−108) ← last completed run
- next will be `check.log.dcache_r6`

User constraints (from CLAUDE memory + recent messages):
- 8 ns target, DCache margins are thin → never put massive (>0.30 ns) buffers on the cache-read hit critical path.
- Read crit path: `paddr → reqInUse_paddr mux → TagStore.p_addr_i → ram.A → ram → DOUT → tag_eq → hit`. Also: `valid_q → MUX_8 → currLineValid → AND_2 → hit`.
- Off-crit (safe to bufferH16$/H64$): FSM transitions, fill/swap-write, EB control, arbitration WE, LRU update, bus-tristate enable.
- Clock signals do NOT count for fanout (CTS handles them). User changed clock scheme — don't touch clk/rst.
- 0-ns fixes via gate replication or register duplication are always preferable.
- Do NOT touch `kogge_stone` library cells.

## Status at end of session (mid-r6, edits already made BUT not yet `make check`'d)

These edits were applied during the cut-off session and need verifying with the next `make check`. **All r6 edits compile against the current `master.txt` listing.**

Files already touched this round:
1. `rtl/DCache/structural/fanout/DCache_Bank_DataStore_structural.v`
   - Replicated `u_oe_actual` nor2$ ×4 (fanout 16 → 4 each, drives 4 ram OE pins/copy). 0 ns. Expected to clear 4 violations × 4 banks = **16**.
2. `rtl/DCache/structural/fanout/DCache_Bank_FSM.sv`
   - bufferH16$ on `write_to_dswap_o` (fanout 8) and `D_will_evict_o` (fanout 6). +0.24 ns each, off read crit. **8 cleared**.
3. `rtl/DCache/structural/fanout/VCache_FSM.sv`
   - bufferH16$ on `WR_2_EB_o`, `Read_DSWAP_o`, `Write_VSWAP_o` (each fanout 7). +0.24 ns each, off read crit. **12 cleared**.
4. `rtl/DCache/structural/fanout/DCache_Bank_structural.v`
   - bufferH16$ on `reqInUse_we` (fanout 12). +0.24 ns, off read crit (only gates writes/FSM). **4 cleared**.

**Expected after r6 `make check`:** 65 → ~25.

## What's still pending after r6 verifies

Listed in priority order. For each: file, fanout source, suggested approach, delay impact.

### A. `u_savedIDX_qc.q[1]` fanout=7 — VCache_TagStore  (4 violations, 4 banks)
- File: `rtl/DCache/structural/fanout/VCache_TagStore_structural.v` line ~283 (`REG_RST_WE u_savedIDX_qc`).
- Drives only `LRU_unit.savedIDX[1]`. LRU internally consumes bit 1 in 3 places (u_saved_hi_bar INV, u_we_RIGHT AND, u_LRU_ROOT REG.D). Why 7? `MPS_reg_rst_we$` macro probably has internal expansion that pushes the visible flat-leaf count up.
- Fix: **bufferH16$ on `savedIDX_q_c[1]`** (just bit 1, leave bit 0 alone). +0.24 ns on the LRU-update path — NOT on cache read crit. Pattern:
  ```verilog
  wire [1:0] savedIDX_q_c_pre;
  `REG_RST_WE(u_savedIDX_qc, 2, clk, rst, saveIDX, savedIDX_d, savedIDX_q_c_pre)
  assign savedIDX_q_c[0] = savedIDX_q_c_pre[0];
  bufferH16$ u_savedIDX_qc_b1_buf (.out(savedIDX_q_c[1]), .in(savedIDX_q_c_pre[1]));
  ```
- Expected: −4.

### B. `u_reg_pa.q[14]` fanout=7 — DCache_Arbitration  (4 violations)
- File: `rtl/DCache/structural/fanout/DCache_Arbitration_structural.v` (~line 270, inside `g_arb_block`).
- Bit 14 of paddr register, drives output port → DCache_Block → bank/vcache. 7 flat leaves.
- **DEFERRED previously** because it's the tag MSB — on read crit path.
- Two options:
  - **Option 1 (cheap, +0.24 ns crit):** bufferH16$ on `reqs_paddr_q[g_i][14]`. Direct cost on tag compare path.
  - **Option 2 (0 ns, port restructure):** Add a separate output port for paddr bit 14 in DCache_Arbitration; inside DCache_TOP route the duplicate to a different downstream submodule. Significant edit (DCache_Arbitration ports + DCache_TOP wiring + DCache_Block port for the duplicate).
  - **Option 3 (compromise):** Register duplication × 2 inside g_arb_block, but you need TWO output port wires to make duplication count. Same issue as option 2.
- Recommended: ask user. If margins really thin, do option 2. Else option 1 (+0.24 ns).
- Expected: −4.

### C. DCache_Bank `u_reqInUse_paddr` index bits [6,7,8] — fanouts 21/23/23  (12 violations)
- File: `rtl/DCache/structural/fanout/DCache_Bank_structural.v` line 83 (existing wide MUX_2(15)).
- These ARE the heavy paddr-index fanouts driving `DCache_Bank_TagStore.p_addr_i[8:6]` (decoder + valid MUX_8 + dirty MUX_8 + ram.A internally) AND `DCache_Bank_DataStore.p_addr_i[8:6]` (16 ram.A pins).
- **On cache read crit path** — gates ram-A address.
- Approaches:
  - **Approach P (recommended, +0.24 ns crit):** bufferH16$ ×3 on the 3 index-bit mux outputs only (gen_mux[6,7,8]) — single buffer per index bit. Cost: 0.24 ns added to read path on top of existing path. Simplest. Code pattern:
    ```verilog
    wire [14:0] reqInUse_paddr_pre;
    // change MUX_2 destination to _pre
    `MUX_2(u_reqInUse_paddr, 15, reqInUse_paddr_pre, blockReq_paddr_i, savedReq_paddr_q, useSavedReq)
    // assign through, except buffer index bits
    assign reqInUse_paddr[5:0]   = reqInUse_paddr_pre[5:0];
    assign reqInUse_paddr[14:9]  = reqInUse_paddr_pre[14:9];
    bufferH16$ u_paddr_b6 (.out(reqInUse_paddr[6]), .in(reqInUse_paddr_pre[6]));
    bufferH16$ u_paddr_b7 (.out(reqInUse_paddr[7]), .in(reqInUse_paddr_pre[7]));
    bufferH16$ u_paddr_b8 (.out(reqInUse_paddr[8]), .in(reqInUse_paddr_pre[8]));
    ```
  - **Approach Q (0 ns, big restructure):** Modify `DCache_Bank_DataStore` port to add 4× 3-bit index inputs (`p_addr_idx0_i..idx3_i`); each idx port drives 4 ram cells (4 leaves). Modify `DCache_Bank_TagStore` similarly: 4× 3-bit index ports (one per consumer cell — DECODER, MUX_8 valid, MUX_8 dirty, ram.A). Then in DCache_Bank generate per-port index muxes from blockReq/savedReq. **Cascade trap:** blockReq_paddr_i[8:6] fanout grows to (savedReq REG.D=1) + (orig wide mux=1) + (8 narrow muxes for idx) = 10. Need to also dedupe the savedReq REG path or accept a buffer on blockReq inside the bank. Total ~6 file changes. ~0.30 ns saved vs Approach P. Probably not worth it unless STA shows infeasibility with Approach P.
- **Decision needed from user.** Probably go with Approach P unless STA (post-r6) shows tag-compare path is borderline.
- Expected: −12.

### D. `u_valid_mux gen_mux[0]` fanout=7 — DCache_Bank_TagStore  (4 violations)
- File: `rtl/DCache/structural/fanout/DCache_Bank_TagStore_structural.v` line ~76 (`MUX_8 u_valid_mux`).
- The wire is the FINAL stage `mux2$.outb` of MUX_8(width=1) producing `currLine_V_o`. Fanout 7 = (`u_clv_buf.in` 1 leaf) + (FSM `Line_valid_i` port → 11 internal SOP-term uses inside FSM, but optimization presumably reduces some).
- `currLineValid` is on read crit path (feeds tag_eq_and_v through u_clv_buf).
- **Fix (0 ns recommended):** Replicate the MUX_8 ×2 inside DCache_Bank_TagStore, plus add a 2nd output port `currLine_V_for_fsm_o`:
  ```verilog
  // Original kept for buf path (drives u_clv_buf):
  `MUX_8(u_valid_mux, 1, currLine_V_o, valid_q[0..7], index)
  // New copy for FSM path:
  `MUX_8(u_valid_mux_fsm, 1, currLine_V_for_fsm_o, valid_q[0..7], index)
  ```
  Outside in DCache_Bank, route `currLine_V_for_fsm_o → fsm.Line_valid_i`. Each MUX_8 output now has fanout 1.
  - Cascade: `valid_q[0..7]` fanout grows from 1 → 2 (≤4 OK).
  - `index[2:0]` fanout grows similarly (≤4 OK).
- Expected: −4.

### E. Cross-module / non-DCache leftovers
- 3 cross-module entries in r5 report (driver in BusArb/DTE, loads in DCache). Check `reports/dcache_fanout_plan_R5.md` "Cross-module" appendix for details.
- 17 non-DCache violations remaining in `check.log` (mem-side counters at fanout 519/2055 — these are the synthesizable counter outputs flagged INFO/over-buffer; verify they're not real violations).

## How to continue

1. User just ran `make check` for the **r6 mid-session edits** — I never got to verify. Snapshot it: `cp check.log check.log.dcache_r6 && python3 scripts/fanout_optimize.py --check-log ./check.log --module dcache --output reports/dcache_fanout_plan_R6.md`
2. Confirm count went **65 → ~25**. If higher, regression — diff against r5 to find what slipped.
3. Pick up at section A (savedIDX_qc bit 1 buffer). Do A + the smaller of B/D in r7. Defer C (heavy paddr index) until user weighs in on Approach P vs Q.
4. After r7, the only signals likely remaining are the 3 cross-module + the 12 paddr index violations. Discuss STA with user before committing to +0.24 ns (Approach P) or the bigger Approach Q restructure.

## Files we created/modified across all rounds (for recovery if anything's off)

`rtl/DCache/structural/fanout/`:
- DCache_Arbitration_structural.v (r4: u_reg_oe/we/ov_reg buffers; u_ld0/1_valid bufferH64; u_latch_we buffer in r5)
- DCache_Bank_DataStore_structural.v (r1: tagStore_hit_i 4-bit; r6: u_oe_actual ×4 split)
- DCache_Bank_FSM.sv (r2/r3: K-split state FFs, busy_o + ldFrom_V_swap_o bufferH256; r3: fill_o ×4 bufferH64; r6: write_to_dswap_o + D_will_evict_o bufferH16)
- DCache_Bank_structural.v (r1/r2: hit cascade rebuild; r5: u_miss/u_wr_success buffers; r6: u_reqInUse_we buffer)
- DCache_Bank_TagStore_structural.v (r5: u_fill_or_ldswap bufferH64 + u_ldswap_dirty buffer)
- DCache_Block_structural.v (r1: MUX_4(128) → 32×MUX_4(4); r5: u_block_busy + u_addr_drive_en bufferH64)
- EvictionBuf_structural.v (r4: u_eb_valid_reg buffer; r5: u_LDEB_qual + u_reqHit buffers)
- LRU_structural.v (r5: u_currLRU_lo buffer)
- MIO_Block_structural.v (r2: u_keep_sel bufferHInv256; r4: u_reg_oe/we buffers)
- VCache_DataStore_structural.v (r1: tagStore_hit_i 4-bit; r3: u_store_path bufferH256; r4: u_addr_final ×4 split + u_swap_path ×4 split)
- VCache_FSM.sv (r2: ff_0/1/2 triplicated; r3: busy_o bufferH256; r6: WR_2_EB_o/Read_DSWAP_o/Write_VSWAP_o buffers)
- VCache_structural.v (r1: hit_for_mux 4-copies; r5: u_reqInUse_paddr ×2 split for TS)
- VCache_TagStore_structural.v (r1: u_hit ×4 + bufferH64; r2: u_way_hit_*_idx replicas; r4: doAccess triplicated, savedIDX 3-copy; r5: savedIDX 4-copy + u_tag_vswap/eb_idx buffers + u_hitIdx_0/1 ×2 + u_miss buffer)

## Note on naming collisions

User hit `u_savedIDX_d already defined` because the existing MUX instance was named `u_savedIDX_d` (drives `savedIDX_d` wire). My fix renamed register copies to `u_savedIDX_qb/qc/qd` (matching the wire suffix). Apply the same convention if creating more dup copies.
