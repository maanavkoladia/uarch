# WB Stage — Design Report

## 1. Overview

The WB (Write-Back) stage is where committed instructions actually deposit their results. It does two things in parallel: (1) writes the destination and source registers back to the register file via two independent write-back ports, and (2) enqueues any pending store into the appropriate store-queue bank — *not* into the data cache directly. The store queues drain into the cache asynchronously over the following cycles, so WB itself does not wait for the cache.

WB is intentionally simple. There is no computation here, no alignment, no flag handling, no branch resolution — all of that already happened in EXE. By the time data arrives, the result is already aligned in `dr_next`/`sr_next`, the store payload is already packed into `res_buf` (a 2-cache-line buffer), and the per-byte valid mask is already in `bit_vec`. WB is mostly a *queue stage*.

The interesting organizational choices are: a **4-bank store queue** keyed by address, a **single-entry MIO queue** that enforces strict ordering for memory-mapped I/O, and the fact that **back-pressure comes from queues filling up, not from the D-cache being slow**.

## 2. Interesting Features

- **4-bank, 4-deep store queue** — 16 total slots organized as 4 independent FIFOs, indexed by store-address bits [5:4]. Loads in DC do their dependency check by picking the bank from the load address and scanning only those 4 entries.
- **Single-entry MIO queue** — non-cacheable I/O stores go through a separate one-entry queue. The queue is intentionally not a FIFO: at most one MIO store is in flight at a time, which gives strict ordering for device writes without any extra arbitration.
- **Bit-vector per-byte masking, no alignment hardware** — partial / unaligned / cache-line-crossing stores are represented by a 16-bit `bit_vec` (one bit per byte). WB stores data + mask verbatim; the cache uses the mask when writing. No barrel-shifter exists in WB.
- **Two-port register write-back** — `DR_0` for the destination register, `DR_1` for the source register or the EAX result on `WB_EAX` (e.g. CMPXCHG). Combinational, never stalls on its own.
- **Store-queue heads exported as the dependency view** — all 16 slots are flattened and broadcast to DC every cycle so [wb_stq_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/wb_stq_sb_logic.sv) can check loads against them. This is what closes the load-store ordering loop with the front-half stages.
- **Back-pressure from queue-full only** — the D-cache being slow does not stall WB. WB only stalls when *its own* queues can't accept a new push (the MIO queue can hold one entry; each STQ bank can hold four). This decouples WB's pipeline view from the cache's drain timing.

## 3. Stage Organization

```
   from EXE: dr_next, dr_id, sr_next, sr_id, EAX result,
             ST_OP, ST_XCL, ST_PADDR_0/1, res_buf[32 B],
             ST_BIT_VEC_0/1, MIO flag
                  │
                  ▼
   ┌─────────────────────────────────────────────────────┐
   │                    WB stage (1 cycle)               │
   │                                                     │
   │  ┌──────────────────┐         ┌────────────────┐    │
   │  │ reg_wb_logic     │         │ ST_Q_MIO_logic │    │
   │  │  DR_0 → reg_file │         │   (only when   │    │
   │  │  DR_1 → reg_file │         │    MIO == 1)   │    │
   │  │  (combinational) │         └───────┬────────┘    │
   │  └──────────────────┘                 │             │
   │                                       ▼             │
   │                                  ┌──────────┐       │
   │                                  │ MIO_Q    │       │
   │                                  │ (1 slot) │       │
   │                                  └────┬─────┘       │
   │                                       │ head        │
   │  ┌──────────────────┐                 │             │
   │  │ ST_Q_logic       │                 │             │
   │  │  pick bank by    │                 │             │
   │  │  ST_PADDR[5:4]   │                 │             │
   │  └────────┬─────────┘                 │             │
   │           │ entry0/entry1             │             │
   │           ▼                           │             │
   │  ┌─────────────────────────┐          │             │
   │  │  ST_Q  (4 banks × 4)    │          │             │
   │  │   bank0 bank1 bank2 bank3│         │             │
   │  └────────────┬────────────┘          │             │
   │               │ heads (4)             │             │
   │               │   ┌───── all 16 entries ────► to DC │
   │               │   │       (dependency view)         │
   │               ▼   ▼                                 │
   │     to D-cache write ports (4) + MIO write port     │
   │                                                     │
   │     stall = OR( bank_full_no_pop[4],                │
   │                 mio_full_no_pop )                   │
   │             ──────────► back to EXE                 │
   └─────────────────────────────────────────────────────┘
```

A store enters as `(addr, data, bit_vec)`. If the access crosses a cache line (`ST_XCL`), `ST_Q_logic` builds two entries — `entry0` for the low half, `entry1` for the high half — and routes each to the bank picked by its own address. The two halves can land in different banks, which is exactly what the 4-bank organization is for. Once in the queues, entries dequeue when the D-cache signals `write_success[i]` for that bank.

## 4. Per-Block Walkthrough

- **[WB.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/WB.sv)** — top-level wiring. Instantiates `reg_wb_logic`, `ST_Q_logic` + `ST_Q`, `ST_Q_MIO_logic` + `MIO_Q`. Combines the per-bank and MIO push-fail signals into the WB stall, gathers all 16 STQ heads + the MIO head, and exports the dependency view to DC.

- **[reg_wb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/reg_wb_logic.sv)** — two-port combinational register write-back. `DR_0` always carries `dr_next` with `dr_id`. `DR_1` carries `sr_next` with `sr_id`, except when `WB_EAX` is set (e.g. CMPXCHG), in which case it carries the EAX result. Write enables are gated by the per-port WB control bits and the WB stall.

- **[ST_Q_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/ST_Q_logic.sv)** — combinational push generator for the regular store queues. Builds `entry0` and (if `ST_XCL`) `entry1` from `res_buf`, `ST_PADDR_*`, and `ST_BIT_VEC_*`. Routes each entry to its bank by address bits [5:4]. Asserts the per-bank `push_fail` if a bank is full and isn't being popped this cycle.

- **[ST_Q.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/ST_Q.sv)** — the actual 4-bank store queue. Each bank is a 4-entry FIFO (`NUM_WB_ST_QS = 4`, `ST_Q_DEPTH = 4`). On `write_success[i]` from the D-cache, the head of bank `i` pops and the rest shift down. Push and pop can happen the same cycle.

- **[ST_Q_MIO_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/ST_Q_MIO_logic.sv)** — combinational push generator for MIO. Activates only when `MIO == 1`. Asserts `push_fail` if the MIO slot is occupied and not being popped this cycle.

- **[MIO_Q.sv](design/EverythingEverywhereAllAtOnce/rtl/core/WB/MIO_Q.sv)** — single-entry MIO holding register. Holds at most one in-flight MIO store. Pops on `write_success_mio`.

- **[pkg/](design/EverythingEverywhereAllAtOnce/rtl/core/WB/pkg/)** — type definitions: `st_q_entry_t` (valid, address, bit_vec, data[16]), `mio_entry_t` (address, data[16]), and the `wb_latches_t` / `wb_outputs_t` bundles.

- **[structural/](design/EverythingEverywhereAllAtOnce/rtl/core/WB/structural/)** — synthesis-targeted versions of each block, plus the existing `WRITEBACK.md` design notes.

## 5. Interesting Features — In Depth

### 5.1 4-Bank Store Queue

Each STQ slot stores `(valid, address[15], bit_vec[16], data[16 B])`. Banks are indexed by `ST_PADDR[5:4]` — i.e. by the cache-line-aligned bank bits used everywhere else in the design. The bank organization is doing two jobs at once:

- **Throughput**: up to 4 stores can be popped to the D-cache per cycle (one per bank port), because each bank has its own write port and its own `write_success` ack.
- **Dependency-check shape**: when DC needs to know whether a load has a hazard against a pending store, it doesn't have to scan all 16 slots — it picks the bank from the load address and scans the 4 slots in that bank only. This is why [wb_stq_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/wb_stq_sb_logic.sv) on the DC side is bank-keyed.

XCL stores (cache-line-crossing) split into two entries that may land in two different banks — handled naturally by routing each half by its own address.

### 5.2 Single-Entry MIO Queue

MIO stores go to memory-mapped I/O. The hardware needs to write them to the device in program order, with no overlap. Rather than build a small ordered FIFO with arbitration, this design just holds **one** in-flight MIO store at a time:

- If the slot is empty, push succeeds, MIO write goes to the bus next cycle.
- If the slot is full and `write_success_mio` arrives, the in-flight store pops and the new one pushes the same cycle.
- If the slot is full and the device hasn't acknowledged, push fails and WB stalls until it does.

This deliberately serializes MIO. The cost is throughput on bursty I/O sequences — but I/O is rare and its devices are slow, so the trade is the right one. The benefit is that MIO ordering is enforced by *not having a queue to reorder*, which is much easier to reason about.

### 5.3 Bit-Vector Masking, No Alignment Hardware

A 16-byte cache line can be partially written by a store as small as 1 byte, or as misaligned as a 4-byte store starting at byte 14 (which would also need a second entry for the next line). Rather than build an alignment / merging unit in WB, the data is **already** packed into `res_buf` by EXE's `res_buf_logic`, and the bytes that should actually be written are flagged in `bit_vec` — one bit per byte.

WB stores both verbatim into the queue entry. When the D-cache eventually consumes the head, it uses the `bit_vec` as a per-byte write enable into the cache line. WB itself touches no shifter, no merge logic, no boundary detector.

### 5.4 Two-Port Register Write-Back

The register file accepts two writes per cycle:

- **`DR_0`** — destination register write. Always carries `dr_next` with `dr_id`. Some ops swap in the CS register on `EXP_CALL`.
- **`DR_1`** — source/secondary register write. Carries `sr_next` with `sr_id` normally; carries the EAX result on `WB_EAX` (e.g. CMPXCHG, where the architectural register being updated is EAX rather than the source register).

Write enables are per-port (`WB_DR` for `DR_0`, `WB_SR | WB_EAX` for `DR_1`). The path is purely combinational and never the cause of a WB stall — only the store queues can stall WB.

### 5.5 Store-Queue Heads as the Dependency View

The DC stage's load-store hazard detection has two halves: the in-flight scoreboard (loads vs. stores in MEM/EXE/WB latches) and the store-queue scoreboard (loads vs. anything still parked in WB's queues). For the second half to work, WB has to **export the queue contents** every cycle.

WB does this by flattening all 16 STQ slots (and the one MIO slot) into a `wb_outputs_t` field and shipping it to DC. DC's `wb_stq_sb_logic` picks the bank by the load's address and compares against the 4 slots in that bank in parallel.

The combination — DC providing the load address + bank, WB providing the queue contents + bank — is what lets the design get away with no store-to-load forwarding: every dependency is *detected* (via the bank-keyed compare) and the load just stalls until the store drains.

### 5.6 Back-Pressure From Queues, Not From the Cache

The WB stall is computed as:

```
wb_stall = OR( bank_push_fail[4], mio_push_fail )
```

A `*_push_fail` happens when the queue is full *and* no pop arrives this cycle. Crucially, **a slow D-cache does not directly stall WB** — it only delays pops. WB stalls only if pops fall far enough behind that one of the FIFOs actually fills.

This is the right shape for back-pressure: the cache is allowed to be slow for a few cycles without WB knowing, the queues absorb the bursts, and only sustained back-pressure ever propagates upstream.

## 6. Critical Path / Timing

The dominant arc in WB is short by design. The longest register-side path runs from the EXE latch outputs, through `reg_wb_logic`'s mux, into the register-file write port. The longest store-side path runs from the same latches, through `ST_Q_logic`'s bank selection and entry build, into the STQ FIFO push.

Measured on synthesis: **__ ns** *(to be filled in once STA is run on this branch — no estimate is given here.)*

A secondary arc to keep in mind: the **flattened STQ-heads → DC** path. WB doesn't time it (it's just wires out), but if the entire 16-slot view becomes too wide to route, that's a physical-design problem worth flagging.

## 7. Design Considerations and Trade-offs

- **4-bank STQ over a single big FIFO**: more storage area for the per-bank pointers, but DC's dependency check becomes a bank-keyed scan of 4 slots instead of 16, and the cache can drain 4 stores per cycle.
- **Single-entry MIO queue over a small FIFO**: gives up I/O burst throughput in exchange for trivial ordering correctness. I/O is rare; trade is right.
- **No alignment / merge hardware in WB**: depends entirely on EXE having pre-packed `res_buf` and pre-built `bit_vec`. Tightly couples the two stages, but eliminates a shifter from WB.
- **No store-to-load forwarding anywhere**: WB exposes the queue heads, DC detects the conflict, the load just stalls. Simpler at both ends; cost is some load latency on tight RAW patterns.
- **Stall only on queue-full, not on slow cache**: the queues are the elasticity buffer. The right design as long as the queues are deep enough — which is why the choice is 4 deep per bank, not 1 or 2.

## 8. Conclusions

WB is the simplest stage in the back half. The work that *would* have made it complicated — alignment, byte-mask construction, store-data packing — was deliberately pushed back into EXE so that WB can be a queue stage, not a compute stage. The two interesting organizational choices are bank-keying the store queue so DC's dependency check stays cheap, and giving MIO its own one-deep queue so I/O ordering is enforced by construction.

A natural next design would (1) add bypass forwarding from the STQ heads back through DC so common-case load-store conflicts don't actually stall, (2) widen MIO to a small ordered FIFO with a fence to recover I/O burst throughput while preserving ordering, and (3) consider per-bank `bit_vec` merging on push so two stores to the same line in the same bank can collapse into one queue entry.
