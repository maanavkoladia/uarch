# Fetch Stage — Design Report

## 1. Overview

The Fetch stage is the front-end of the CPU. Each cycle it produces a 16-byte instruction cache line, annotated with branch-prediction metadata, and pushes it into a small buffer (the **IDM**) for the Decode stage to consume. The cache hit path is single-cycle, so on a steady-state hit the back-end sees a new line every cycle. Speculation in front of the back-end is what hides the cost of branches: predictions are made at the cache-line granularity using a 64-entry BTB and a GShare predictor, the speculative line is parked in the IDM, and on a misprediction the speculative state is rolled back from a single point.

Three design choices shape the rest of this report:

1. **Speculative cache-line fetch** into a 4-slot IDM that carries both instruction bytes *and* branch info.
2. **Cache-line-granularity branch prediction** (BTB + GShare).
3. **Single-cycle VIPT instruction cache** with segment translation overlapping the array access.

## 2. Interesting Features

- **Speculative cache-line fetch into the IDM** — instructions are fetched ahead of the back-end and parked in a 4-slot buffer that doubles as the branch-info store.
- **Cache-line-granularity branch prediction** — one prediction per 16-byte line via a 64-entry BTB and an 8-bit-history GShare predictor.
- **Single-cycle VIPT instruction cache** — the segment-translated address indexes the cache combinationally; tag check and hit/miss decision happen the same cycle as the data array read.
- **IDM stores branch info alongside instruction bytes** — each slot carries `valid`, `br_valid`, branch EIP, predicted target, and the XCL (cross-cache-line) flag, so resolve-time checks in the back-end are local to the IDM entry — no second BTB lookup is needed.
- **Cross-cache-line (XCL) branch handling** — when a predicted-taken branch sits across the boundary of two cache lines, [SPC_Sel_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/SPC_Sel_Logic.sv) stalls and serializes the fetch of both halves before applying the redirect.
- **Exception / interrupt injection via ROM** — handler code is muxed into the IDM as a synthetic cache line by [EXP_Ctrl_ROMS.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/EXP_Ctrl_ROMS.sv), bypassing the I-cache entirely.

## 3. Top-Level Dataflow

```
                   ┌─────────────────────┐
                   │   SPC (next-PC reg) │
                   └─────────┬───────────┘
                             │
              ┌──────────────┼──────────────────────┐
              ▼              ▼                      ▼
      ┌───────────────┐ ┌──────────┐        ┌──────────────┐
      │ SegmentTrans  │ │   BTB    │        │   GShare     │
      │  (base+limit) │ │ (64 ent) │        │ PHT[256]+BHR │
      └──────┬────────┘ └────┬─────┘        └──────┬───────┘
             │ v_addr        │ target,EIP,XCL      │ taken/NT
             ▼               └──────────┬──────────┘
      ┌───────────────┐                 │
      │   ICache      │                 │
      │ (VIPT, 1cyc)  │                 │
      └──────┬────────┘                 │
             │ line + hit               │
             ▼                          ▼
            ┌────────────────────────────────┐
            │       IDM (4 slots)            │  ◄── EXP_Ctrl_ROMS
            │  line │ brValid │ target │ XCL │      (handler inject)
            └─────────────┬──────────────────┘
                          ▼
                       to Decode
```

The Speculative PC (SPC) is held in a register. Every cycle it drives **three things in parallel**: the segment translator (and from there, the I-cache index), the BTB lookup, and the GShare PHT lookup. On a cache hit, the line and its hit signal arrive in the same cycle as the BTB / GShare predictions. If the BTB hits and GShare predicts taken, the IDM slot for this line is filled with the cache line *and* the branch metadata, and on the following cycle SPC_Sel_Logic redirects SPC to the predicted target. On a miss or no-hit, SPC simply advances by 16 bytes.

## 4. Per-Block Walkthrough

The blocks are presented in the order a fetch flows through them.

- **[SPC_Sel_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/SPC_Sel_Logic.sv)** — 4-way mux for the next SPC: hold, +16, branch-restore (mispredict recovery), or BTB-target. Owns the XCL stall machine that holds SPC for one cycle when a predicted-taken branch crosses a cache line boundary, and the one-cycle sequential fetch after a flush before predictions resume.

- **[SegmentTranslation.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/SegmentTranslation.sv)** — combinational `phys = (segBase << 16) + logical`, with a GP fault when `logical >= segLimit`. It sits in the cache-access cycle so its delay overlaps with the array indexing, not in series with it.

- **[ICache_En_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/ICache_En_Logic.sv)** — gates the cache off when the front-end is in exception mode, interrupt mode, DMA, code-segment-busy, or a fetch-side fault. A clean AND of mode bits — no state.

- **[BTB.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/BTB.sv)** — 64-entry direct-mapped, indexed by `addr[9:4]`, tagged by `addr[31:10]` (with `CACHE_LINES_SIZE_B = 16`, `btb_entries = 64`). Each entry holds: target address, branch EIP within the line, the XCL flag, an unconditional flag, and a valid bit. **One prediction per 16-byte cache line.**

- **[Predictor/](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/Predictor/) subsystem** — wraps a [GShare.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/Predictor/GShare.sv) (8-bit BHR, 256-entry PHT of 2-bit saturating counters) and a [BTFN.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/Predictor/BTFN.sv) backwards-taken / forwards-not-taken fallback. The GShare PHT index is `bhr_spec ^ spc[11:4]`. **Two BHRs** are kept — `bhr_spec` (updated on speculative predictions) and `bhr_real` (updated on resolve) — so that on a mispredict `bhr_spec` can be restored from `bhr_real`.

- **[IDM_Ctrl_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/IDM_Ctrl_Logic.sv)** — manages the 4-slot speculative buffer (`NUM_IDM_SLOTS = 4`). The slot index is `spc[5:4]` — i.e. the cache-line bits above the line offset. On a successful fetch it loads the slot with the I-cache line and stamps in the branch metadata supplied by the BTB (`br_valid`, branch EIP, predicted target, XCL).

- **[IDM_Invalidate_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/IDM_Invalidate_Logic.sv)** — owns the squash policy. Slots are invalidated when (1) fetch advances past them, (2) a taken branch is taken in front of them (anything speculatively fetched past the branch point is wrong), or (3) a back-end mispredict / exception triggers a global flush.

- **[EXP_Ctrl_ROMS.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/EXP_Ctrl_ROMS.sv)** — on exception or interrupt, looks up the appropriate handler entry-point (GP fault, page fault, DMA interrupt, etc.) and presents it to the IDM as if it were a fetched cache line. This is how the front-end delivers handler code without going through the I-cache or even the normal SPC path.

- **[EXP_Set_Logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/EXP_Set_Logic.sv)** — decides *when* to assert the exception/interrupt pipeline-clear, prioritizing back-end (data-cache side) faults over fetch-side faults.

- **[Fetch.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/Fetch.sv)** — top-level wiring. Holds the SPC register and the front-end mode flags (exp/int mode, DMA-int latch); instantiates SegmentTranslation, the BTB, the predictor, the SPC mux, the IDM control/invalidate logic, and the exception logic; drives outputs to the I-cache and to Decode.

The [pkg/](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/pkg/) folder defines the structs that cross these blocks (BTB output, IDM slot layout, SPC selector enum, etc.), and the [structural/](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/structural/) folder holds synthesis-targeted versions of the same logic.

## 5. Interesting Features — In Depth

### 5.1 Speculative Fetching and the IDM

The IDM is the pivot point of the whole stage. It has 4 slots, indexed by `spc[5:4]`, and each slot holds both the 16-byte instruction line *and* the branch metadata for that line. Doing it this way is what makes the rest of the design simple:

- **Fetch can run ahead of the back-end** — as long as a slot is free or invalid, the front-end keeps producing lines.
- **No second prediction lookup at resolve time** — when the back-end resolves a branch, it compares its actual outcome against the `br_valid` / `target` / `XCL` already living in the IDM slot for that PC. The BTB and GShare are not on the resolve path.
- **Squashing is per-slot** — a taken branch invalidates only the slots speculatively fetched past it; a back-end flush clears everything.

The cost is small: 4 slots × (16 bytes + a handful of metadata bits). The benefit is one less lookup port on the BTB and a clean rollback story.

### 5.2 Cache-Line Branch Prediction (BTB + GShare)

Predictions are made **per cache line, not per instruction**. A 16-byte line tracks at most one branch — the one that, if taken, will redirect the front-end out of this line. This is what lets the BTB and the IDM share the same indexing scheme: one entry per line, one slot per line.

- **BTB**: 64 entries, direct-mapped, indexed by `addr[9:4]`, tagged by `addr[31:10]`. Per-entry payload is target, EIP-within-line, XCL flag, unconditional flag, valid.
- **GShare**: 8-bit global history register (BHR), 256-entry PHT of 2-bit saturating counters. Index is `bhr ^ spc[11:4]`. The XOR is the entire point of GShare — it lets the same branch in different control-flow contexts land in different PHT entries.
- **Two BHRs** — `bhr_spec` is updated every cycle on a BTB hit with the predicted direction; `bhr_real` is updated only when a branch resolves. On a mispredict `bhr_spec ← bhr_real`, which restores history to the last architecturally-correct state without rebuilding it.
- **BTFN fallback** — when the BTB misses, [BTFN.sv](design/EverythingEverywhereAllAtOnce/rtl/core/Fetch/Predictor/BTFN.sv) provides a default static prediction (backward branches taken, forward not taken).

The trade-off is that a cache line containing two real branches can only have one of them tracked — accuracy is given up in exchange for a much simpler structure (one-port BTB, one-slot-per-line IDM).

### 5.3 Single-Cycle VIPT Instruction Cache

The hit path runs entirely in one cycle:

1. SPC drives `SegmentTranslation` (combinational).
2. The translated virtual address indexes the cache tag and data arrays in parallel (`v_addr[7:4]` selects one of 16 entries).
3. The tag array's output is compared combinationally against `v_addr[31:8]`.
4. The hit signal and the line are returned to the front-end **the same cycle**.

The reason this works without a TLB on the critical path is the segmentation model: each segment has a unique base, so the segment-translated virtual address is unique within the segment context. That means a virtual-tag compare is sufficient for correctness — the physical address (latched in `saved_pAddr`) is only used by the bus on a miss/fill, never on the hit decision.

On a miss, a small FSM walks Fill0 → Fill1 → Fill2 → Fill3 → SWAP, taking 4-byte chunks from the bus into the data array and updating the tag array on completion. A small victim cache absorbs the line being evicted.

### 5.4 Cross-Cache-Line (XCL) Branches

If a branch instruction straddles the boundary between two 16-byte lines, its full encoding (and therefore its target field, if it's an unconditional or BTB-tracked branch) is not known until both lines have been fetched. The fix lives in `SPC_Sel_Logic`:

- The XCL flag from the BTB tells the front-end the branch crosses lines.
- SPC_Sel_Logic latches the partial branch info, holds SPC for one cycle (selecting `SPC_P16` to fetch the second half), and only **then** applies the redirect.

This costs one cycle per XCL-taken branch, but avoids the alternative — having the BTB / IDM understand cross-line state, which would complicate every other path through the stage.

### 5.5 Exception / Interrupt Injection

Exceptions and interrupts don't wait for the I-cache. `EXP_Ctrl_ROMS` looks up the handler entry-point for the relevant fault type (GP fault, page fault, DMA interrupt, etc.) and hands it to the IDM directly as a synthetic line. From Decode's perspective, it just looks like another IDM slot. `EXP_Set_Logic` decides which event actually wins arbitration — back-end (DC) faults take priority over fetch-side faults, since the back-end ones are older instructions.

## 6. IDM Slot Layout

```
   IDM (NUM_IDM_SLOTS = 4, indexed by spc[5:4])
   ┌──────┬──────────────────────────────────────────────────────┐
   │ slot │  per-slot fields                                     │
   ├──────┼──────────────────────────────────────────────────────┤
   │  0   │  valid                                               │
   │  1   │  data[16]      (16-byte instruction line)            │
   │  2   │  br_valid                                            │
   │  3   │  br_eip        (offset of branch within the line)    │
   │      │  br_target     (predicted target, from BTB)          │
   │      │  xcl           (branch crosses cache-line boundary)  │
   │      │  uncond        (unconditional branch)                │
   └──────┴──────────────────────────────────────────────────────┘
```

The same struct is read by Decode (for instruction bytes) and by Execute (for resolve-time prediction checks).

## 7. Critical Path / Timing

The dominant timing arc in the Fetch stage runs from the SPC register, through `SegmentTranslation`, into the I-cache tag and data arrays, through the tag compare, and into the IDM write port — i.e. the cache-line read **and** the branch-annotated IDM slot update happen in the same cycle.

Measured on synthesis: **__ ns** *(to be filled in once STA is run on this branch — no estimate is given here.)*

Two secondary arcs to keep an eye on:

- **BTB read → SPC mux → next-cycle SPC** — affects how aggressively the front-end can redirect after a predicted-taken branch.
- **GShare PHT read → IDM `br_valid` update** — runs in parallel with the cache path but feeds the same IDM write port, so the slowest of the two sets the cycle.

## 8. Design Considerations and Trade-offs

- **Per-cache-line prediction** keeps the IDM and BTB indexing aligned (one entry per line) and one-port, at the cost of accuracy on lines with more than one branch.
- **Direct-mapped VIPT** (16 entries, 16-byte lines) was chosen over set-associative for a clean single-cycle path. Capacity is small, but the bigger goal is single-cycle hit.
- **Two-BHR speculative/architectural split** in GShare gives cheap rollback on mispredict, at the cost of a second history register and a one-cycle update on resolve.
- **4-slot IDM** is sized to absorb typical back-end stall windows without making per-slot invalidation logic complicated.
- **Segmentation (no paging on the fetch side)** is what makes the "VIPT without aliasing" argument hold — each segment has a unique base, so the virtual tag is sufficient.

## 9. Conclusions

The Fetch stage delivers, on a steady-state cache hit, one branch-annotated 16-byte cache line per cycle into the IDM, with cache-line-granularity branch prediction and recoverable speculative history. Exceptions and interrupts are injected directly into the IDM, bypassing the I-cache entirely. The two soft spots in the design are (a) prediction accuracy on lines containing more than one branch, and (b) capacity in the small direct-mapped I-cache.

A natural next design would (1) add a return-address stack for call/return prediction, (2) move to a small set-associative I-cache to reduce conflict misses without giving up the single-cycle hit path, and (3) extend the BTB / IDM to track more than one branch per line for tighter prediction on dense code.
