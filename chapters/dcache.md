# DCache Subsystem — Design Report

## 1. Overview

The data-cache subsystem services load requests from the MEM stage, store requests from the WB store queues, and non-cacheable MMIO traffic (DMA control, temperature sensor, power-gate). It sits between the core's request ports and the shared address / data bus, talking to the DTE / scheduler on the back side. Cacheable storage totals 832 B spread across four bank-interleaved blocks; each block has its own L1 bank, victim cache, and eviction buffer.

The subsystem is **highly banked**. Two independent core load addresses plus four store-queue heads can all be serviced in the same cycle when they map to distinct banks. A miss in one bank does not stall accesses to the other three — the cache is non-blocking at bank granularity.

![DCache subsystem block diagram.](figures/fig_dcache.png){#fig:dcache width=85%}

## 2. Interesting Features

- **4-way bank-interleaved L1** — four independent cache blocks, picked by `p_addr[5:4]`. Each block has its own tag store, data store, and FSM. Bank-level non-blocking.
- **Per-bank 4-way set-associative victim cache** — every L1 bank is backed by a small fully-associative victim cache (4 entries; equivalent to 4-way set-associative with one set) that absorbs conflict misses without going to main memory.
- **Swap buffers** between the bank and its victim cache, so the bank can eject a line and resume sequencing while the victim cache installs it.
- **Single-entry eviction buffer** per block, with a "blocking" path on address collisions, so writebacks to main memory don't stall fresh fills.
- **Sticky store-priority override** in the arbitration logic — once a store queue fills, that block prefers its store-queue head over fresh loads to the same bank until the queue drains. Prevents store starvation under load-heavy workloads.
- **Single-cycle write-hit** thanks to a phase-shifted write clock — reads and writes to the same SRAM happen in the same cycle without contention, so a write hit commits without an extra pipeline stage.
- **Latched per-bank requests (`savedReq`)** so the arbiter is free to clear or reissue its holding latch while a multi-cycle fill or swap is in progress; the bank keeps the original request internally.
- **Bus tristate, permission-gated by the DTE** — the cache never spontaneously drives the shared buses; the DTE schedules every drive cycle.

## 3. Subsystem Organization

```
                       requests from core           requests from WB store queues
                     (2 load + MIO load/store)              (4 store-queue heads)
                              │                                   │
                              └──────────────┬────────────────────┘
                                             ▼
                                  ┌─────────────────────────┐
                                  │   DCache_Arbitration    │
                                  │   - per-bank routing    │
                                  │   - store-priority      │
                                  │     sticky override     │
                                  └─────────┬───────────────┘
                                            │ one request per block per cycle
                ┌───────────────┬───────────┴────────────┬───────────────┐
                ▼               ▼                        ▼               ▼
        ┌─────────────┐  ┌─────────────┐         ┌─────────────┐ ┌─────────────┐
        │ DCache_Block│  │ DCache_Block│   …     │ DCache_Block│ │  MIO_Block  │
        │  (bank 0)   │  │  (bank 1)   │         │  (bank 3)   │ │ (no storage)│
        │  ┌────────┐ │  │  ┌────────┐ │         │  ┌────────┐ │ └──────┬──────┘
        │  │ L1 bank│ │  │  │ L1 bank│ │         │  │ L1 bank│ │        │
        │  │ 8 lines│ │  │  │   …    │ │         │  │   …    │ │        │
        │  └────────┘ │  │  └────────┘ │         │  └────────┘ │        │
        │  ┌────────┐ │  │             │         │             │        │
        │  │ VCache │ │  │             │         │             │        │
        │  │ 4 ways │ │  │             │         │             │        │
        │  └────────┘ │  │             │         │             │        │
        │  ┌────────┐ │  │             │         │             │        │
        │  │ EvictB │ │  │             │         │             │        │
        │  └────────┘ │  │             │         │             │        │
        └──────┬──────┘  └──────┬──────┘         └──────┬──────┘        │
               └────────────────┴───────────────────────┴───────────────┘
                                            │
                                            ▼
                           DTE / scheduler / shared bus
```

A line is in at most one of {bank, victim cache, eviction buffer} per block. The bank and victim cache exchange hit / miss / dirty / swap-valid signals through their two FSMs so they can sequence multi-cycle operations (fill, swap, evict) without handshaking through the arbiter or the scheduler.

## 4. Per-Block Walkthrough

The subsystem is organized as one top-level wrapper plus four block instances plus a separate MIO block.

- **DCache_TOP** — instantiates the arbitration, four `DCache_Block` instances, and the `MIO_Block`. Pure wiring; no logic of its own beyond bus-permission gating from the DTE.
- **DCache_Arbitration** — single combinational arbiter. Routes the two core load ports and the four store-queue heads to their target banks by address bits `[5:4]`, one request per block per cycle. Owns the store-priority sticky override per block.
- **DCache_Block** (×4, bank-interleaved):
  - **DCache_Bank** — 8 cache lines, direct-mapped, 16-byte lines. Single tag-compare. Owns the bank-side FSM that sequences hit / miss / fill / swap.
  - **VCache** — 4 entries, fully associative (equivalent to a one-set 4-way set-associative cache). Tag store, data store, tree-PLRU replacement, and its own FSM that handles install-from-bank and lookup-on-miss.
  - **EvictionBuf** — single-entry buffer that holds a dirty line awaiting writeback to main memory.
  - Swap buffers between the bank and the victim cache that decouple the bank's eviction from the victim cache's install.
- **MIO_Block** — single in-flight non-cacheable request shaper. No tag/data storage. Loads take precedence over stores when both are pending. Address-mask decoding distinguishes "simple" MMIO writes (e.g. DDR5 power gating) from "complex" ones (e.g. DMA setup); the scheduler uses that to pick the right external sequence.

## 5. Interesting Features — In Depth

### 5.1 4-Way Bank Interleaving

The 4-bit-aligned chunk of physical address `[5:4]` selects one of four independent blocks. Each block owns its own tag store, data store, FSM, victim cache, and eviction buffer. Two consequences:

- **Concurrent service**: two load addresses plus four store-queue heads — six requests total — can all be serviced in the same cycle when they map to distinct banks. The arbiter handles the routing combinationally.
- **Non-blocking at bank granularity**: a miss in bank 0 doesn't stall accesses to banks 1, 2, or 3. The blocked bank's FSM walks through fill states while the others continue to hit.

### 5.2 Per-Bank Victim Cache

Each bank's direct-mapped L1 is backed by a 4-way fully-associative victim cache. The reasoning:

- **L1 stays cheap and fast** — single tag-compare, single SRAM lookup, single-cycle hit. The cost of associativity is paid at the rare miss, not at every access.
- **Conflict misses don't escalate**: a line evicted from the L1 lands in the victim cache. When that line is touched again, it's swapped back into the L1 over a few cycles via the swap buffers — no main-memory traffic.
- **Tree pseudo-LRU** (three bits per victim cache) picks the victim entry. Cheap to maintain, near-LRU quality for four ways.

### 5.3 Swap Buffers Between Bank and Victim Cache

A direct path from "bank evicts a line" to "victim cache installs it" would form a long combinational chain spanning bank-tag-read, victim-cache-tag-compare, and a writeback into the bank — all in one cycle. The swap buffers split that. The bank posts its outgoing line into the buffer and resumes sequencing; the victim cache consumes the buffer when it's ready. Two sides, no long arc, no shared cycle.

### 5.4 Single-Entry Eviction Buffer with a Blocking Path

Writebacks to main memory are decoupled from new fills via the eviction buffer. The bank takes a new miss while a dirty victim is still in the buffer, *provided the new miss doesn't collide with the buffer's address*. On a collision, the bank parks in its EB-blocking state and surfaces a distinct request type to the scheduler, telling the DTE to prioritize draining the buffer.

### 5.5 Store-Priority Override

A sticky `st_override` bit goes high when a store queue fills, and stays high until the queue empties. While set, the arbiter prefers that block's store-queue head over fresh loads to the same bank. This prevents store starvation under load-heavy workloads without giving up steady-state load throughput when the store queue is healthy.

### 5.6 Phase-Shifted Write Clock

The SRAM cells are written through a delayed clock edge so reads and writes can occur in the same cycle without contention. A write hit is detected combinationally and committed the same cycle — no extra pipeline stage to commit a store.

### 5.7 FSM-Driven Bank / Victim-Cache Interaction

The bank and victim cache each own one side of the multi-cycle operations (fill, swap, evict). They exchange hit / miss / dirty / swap-valid signals through their FSMs without handshaking through the arbiter or scheduler. Each FSM only has to reason about its own state, and the composition stays clean.

## 6. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 7. Design Considerations and Trade-offs

- **Four banks (not eight)** keeps the arbiter combinationally simple while still allowing six concurrent requests to be serviced in distinct banks. Eight banks would push the arbiter routing harder for diminishing returns at this workload.
- **Direct-mapped L1 + 4-way victim** instead of a 2-way L1 — the L1's single-tag-compare hit path is fast, and the victim catches the conflict-miss tail that a direct-mapped L1 would otherwise suffer.
- **Swap-buffer-decoupled bank/VCache interaction** trades a few cycles of latency on a swap for a clean cycle-time argument on the common-case hit path.
- **One eviction buffer per block, not a queue** — cost / complexity trade. The buffer absorbs the typical case; collisions stall, but they're rare.
- **Bus tristate + DTE permission** means the cache adds no internal bus arbitration logic. The DTE owns the schedule; the cache just respects it.

## 8. Conclusions

The DCache subsystem delivers single-cycle hits on the common path, banked throughput up to six concurrent requests per cycle when addresses cooperate, and a victim cache that hides most conflict misses from main memory. The arbitration story keeps loads and stores from starving each other under sustained pressure, and the FSM-per-side composition keeps the multi-cycle operations local.

A natural next design would (1) increase L1 associativity from direct-mapped to 2-way to reduce the rate at which lines flow through the victim cache, (2) add a small writeback FIFO so multiple dirty victims can drain in parallel, and (3) consider stride-based prefetching to fill the bank ahead of likely miss patterns.
