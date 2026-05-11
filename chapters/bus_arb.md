# Bus Arbitration — Design Report

## 1. Overview

The bus-arbitration subsystem is the central traffic controller for the shared address and data buses. Every on-chip entity that needs the bus — the ICache for line fills, each of the four DCache banks for fills and writebacks, the DMA controller for memory writes, and MMIO paths to the DDR5 temperature sensor and the DMA controller's registers — sends a request here. Each cycle, one winner is picked and the arbitration logic drives every bus permission, `mem_valid`, eviction-buffer commit, and MIO acknowledgement needed to carry that transaction to completion.

There are seven distinct transaction classes: ICache fill, DCache fill (per bank), DCache writeback (per bank), DMA write to memory, MIO load from a DDR5 register, MIO write to a DDR5 register, and MIO write routed through the DMA controller.

![Bus arbitration block diagram.](figures/fig_bus_arb.png){#fig:bus_arb width=85%}

## 2. Interesting Features

- **Priority encoded directly into the request enum** — `req_2_sch_t` values are assigned so that "higher priority" maps to "larger unsigned integer". Every tournament reduces to a single `>=` ternary. No priority tables, no shifters, no per-type comparator.
- **Two-cycle Scheduler pipeline** — incoming requests are registered on entry, the tournament runs combinationally on the latched bundle, the winner is registered again on exit. Keeps the priority tree off every requester's critical path.
- **Hazard cleaning before the tournament** — requests that the back-end can't accept yet (eviction-related requests, DMA writes whose target main-memory bank group's write buffer is already valid) are squashed to `NO_REQ` before the tournament runs. The Scheduler never picks a winner that the downstream can't honor.
- **One small FSM per transaction class, all running in parallel** — 13 FSMs (1 ICache fill + 4 DCache fill + 4 DCache writeback + 1 DMA write + 1 MIO load + 1 MIO write + 1 MIO-via-DMA). Each owns a narrow set of bus signals for one traffic class.
- **Single shared `DTE_Busy`** — each FSM exposes a `busy_o`; they OR-reduce into `DTE_Busy` which feeds back as `others_busy_i` to every FSM. An IDLE FSM only commits to leaving IDLE if no other FSM is busy. Bus mutex enforced without a centralized arbiter or per-FSM handshakes.
- **Per-bank DCache fan-out keyed by `bestPick_bk_id`** — when the Scheduler picks a DCache request as the winner, the per-bank DTE FSMs gate their own activation on `bank_hit_i = (bestPick_bk_id == i)`. One bank can do a writeback while another does a fill in consecutive cycles, with no shared state inside the DTE.

## 3. Subsystem Organization

```
   requests from
   { ICache, 4× DCache banks, DMA controller, MIO path }
                              │
                              ▼
                ┌───────────────────────────────┐
                │       Scheduler               │
                │   ┌────────────────────────┐  │
                │   │ input latch (per req)  │  │ cycle 1
                │   └──────────┬─────────────┘  │
                │              │ hazard clean   │
                │              ▼                │
                │   ┌────────────────────────┐  │
                │   │  Scheduler_DCachePicking│ │   per-bank tournament
                │   │  + top-level tournament│  │   (priority via enum >=)
                │   └──────────┬─────────────┘  │
                │              │                │
                │   ┌──────────▼─────────────┐  │
                │   │ output latch (winner + │  │ cycle 2
                │   │  bestPick_bk_id)       │  │
                │   └──────────┬─────────────┘  │
                └──────────────┼────────────────┘
                               ▼
                ┌───────────────────────────────┐
                │           DTE                 │
                │   13 transaction FSMs in      │
                │   parallel, serialized by a   │
                │   shared DTE_Busy signal      │
                └──────────────┬────────────────┘
                               │
                               ▼
              bus drives, mem_valid, permission grants,
                       MIO acks, EB commits
```

The Scheduler's two latches break any combinational tournament timing arc — a DCache bank firing a request never sees the priority tree as a feedback loop back to itself; it just sees a register on the way out and another on the way back. The DTE then has one busy cycle of headroom to leave IDLE before its decision is committed.

## 4. Per-Block Walkthrough

- **Scheduler** — input-latch, hazard-clean, tournament, output-latch. Holds no architectural state of its own; the tournament is pure combinational over the registered bundle. Emits both the winning request type and the bank id (used by the per-bank DCache FSMs in the DTE).
  - **Scheduler_DCachePicking** — the per-bank tournament that picks one DCache request across the four banks before that result feeds into the top-level tournament. Same `>=` enum-based priority.
- **DTE** — host of the 13 FSMs:
  - 1× ICache fill
  - 4× DCache fill (one per bank)
  - 4× DCache writeback (one per bank)
  - 1× DMA write to main memory
  - 1× MIO load from DDR5
  - 1× MIO write to DDR5
  - 1× MIO write routed through the DMA controller
  - Each FSM owns its own bus-permission signals (address-bus drive, per-beat data-bus drive, mem_valid, etc.). FSMs OR-reduce their `busy_o` into the shared `DTE_Busy`. An IDLE FSM gates its own activation on `!others_busy_i`. `busy_o` only fires from non-IDLE states, so the gating cannot form a Mealy loop.

## 5. Interesting Features — In Depth

### 5.1 Priority Encoded into the Request Enum

The most common shape of a priority-arbiter has a table of `(request_type → priority_level)` plus a wide comparator across all input priority levels. This design avoids both: the integer value of `req_2_sch_t` *is* the priority. To pick a winner between two requests, the arbiter does:

```
winner = (a >= b) ? a : b;
```

No table, no per-type comparator, no priority encoder. The whole tournament across N inputs is a tree of two-input `max` operations that synthesises to a tree of small comparators. ICache fill maps to the largest enum value so it sits above everything else — the front end is protected from starvation by construction.

### 5.2 Two-Cycle Scheduler Pipeline

The Scheduler runs in three pieces: a register on the input bundle, a combinational tournament, and a register on the output. Each requester sees one cycle of latency to get into the Scheduler and one cycle of latency to get its result out, with no combinational path from the requester back to itself through the tournament. The downside is two cycles of decision latency, which is acceptable because:

- Most transactions are 4-beat bus sequences anyway (cache-line size / data-bus width = 128 / 32 = 4), so the 2-cycle Scheduler pipeline is a small fraction of total transaction time.
- The alternative — a single-cycle Scheduler — would put a wide tournament on the timing path of every requester.

### 5.3 Hazard Cleaning Before the Tournament

If a DCache eviction-related request or a DMA write request targets a main-memory bank group whose write buffer is already valid, that request is squashed to `NO_REQ` before the tournament. The downstream FSMs never see "you picked this transaction but the memory can't accept it." This eliminates a whole class of stall arcs in the DTE FSMs — they don't have to handle the "I was told to start, but the back-end says wait" case. Any pick the Scheduler emits is guaranteed to be acceptable.

### 5.4 One FSM Per Transaction Class

Rather than a single FSM with a wide opcode selector, the DTE has 13 small parallel FSMs. Each owns a narrow set of bus signals for one traffic class:

- Per-bank DCache FSMs (8 of them: 4 fills + 4 writebacks) mean a bank-2 fill and a bank-0 writeback never share state — the DTE doesn't need to multiplex bank ids inside a single FSM.
- The MIO load FSM, the MIO write FSM, and the MIO-via-DMA FSM are independent — they don't have to share an MIO-shaped state machine.
- The DMA-write FSM and the DCache-writeback FSMs both write to main memory but through completely separate logic, because the data sources are different.

The trade-off is more total FSM state. The win is local reasoning — each transaction class is its own small piece of logic.

### 5.5 Single Shared `DTE_Busy` for Bus Mutex

The bus is a shared resource; exactly one FSM may own it at any time. This is enforced without a centralized arbiter. Every FSM exposes `busy_o`, which is high while it is mid-transaction. All of them OR-reduce into `DTE_Busy`, which is fed back to every FSM as `others_busy_i`. An IDLE FSM checks `others_busy_i` before transitioning out of IDLE. The combination is a distributed mutex: nobody else is doing a transaction → you may start.

Importantly, `busy_o` is asserted only from non-IDLE states, so an IDLE FSM cannot gate itself via the feedback loop. The mutex is Mealy-safe by construction.

### 5.6 Per-Bank DCache Fan-Out

The Scheduler emits the winning request *and* its bank id. The per-bank DCache fill and writeback FSMs in the DTE gate their own activation on `bank_hit_i = (bestPick_bk_id == i)`. The mechanism is trivial — one comparator per FSM — but it lets the DTE serve a bank-0 writeback in one cycle and a bank-2 fill in the next without any shared state inside the per-bank logic.

## 6. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 7. Design Considerations and Trade-offs

- **Two-cycle Scheduler latency** versus single-cycle: chose two-cycle to keep the priority tree off every requester's critical path. Most transactions are 4-beat anyway, so the latency overhead is small relative to the total transaction time.
- **Priority via enum value** versus a priority table: enum-based saves the comparator-network area and gives a faster tree. Cost is that the enum ordering is now load-bearing — adding a new request type requires picking the right priority slot.
- **13 FSMs** versus a single multiplexed FSM: more total state but each FSM is small and locally reasonable. The bus-mutex argument stays clean.
- **Distributed mutex via OR-reduced `DTE_Busy`** versus a central arbiter: no extra arbiter block to design, no extra critical path through it. The Mealy-safety constraint (`busy_o` only from non-IDLE) is the cost.
- **Hazard cleaning before the tournament**: lets the downstream FSMs assume that any pick is acceptable, simplifying every FSM's IDLE transition logic.

## 8. Conclusions

The bus-arbitration subsystem delivers one winning transaction per cycle into the DTE, with two-cycle decision latency, hazard-pre-cleaned tournament inputs, and per-transaction-class FSMs that share the bus via a distributed mutex. The 4-beat bus burst length matches the 128-bit cache line over the 32-bit data bus exactly, so no bus cycle is wasted on rounding.

A natural next design would (1) widen the data bus to halve the burst length and free Scheduler-decision overhead per transaction, (2) add a small reservation channel so a starving requester can guarantee forward progress against a tight high-priority requester, and (3) consider folding the per-bank DCache writeback and fill FSMs into a single FSM per bank to reduce total FSM count without losing parallelism.
