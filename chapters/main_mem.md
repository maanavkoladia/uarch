# Main Memory — Design Report

## 1. Overview

Main memory is the back end of the storage hierarchy. It services DCache line fills, ICache line fills, DCache writebacks, and DMA writes — all four arrive at `mem_TOP` uniformly as a `ld_req` or `st_req` on the DTE interface. The subsystem talks to the DTE (`ld_req` / `st_req` in, `mem_Ready` out) and to the scheduler (`writeBuf_V[NUM_BANK_GROUPS]` back-pressure). The address bus arrives from the DTE; the data bus is driven under DTE permission.

The subsystem is **highly banked**: 64 banks total, sliced two different ways so loads and stores naturally fan out across the topology.

![Main memory block diagram.](figures/fig_main_mem.png){#fig:main_mem width=85%}

## 2. Interesting Features

- **DDR5-style chip / bank-group / bank topology** — models real DRAM organization. The 64 banks are arranged as 8 bank-groups × 8 banks/group (write routing) and 16 chips × 4 banks/chip (load routing and open-row tracking). Two orthogonal slicings of the same address.
- **Open-row chipTable** — per-chip scoreboard of "which row is currently open, is it ready". A second load to the same row is a one-cycle hit decision in the controller FSM. Streaming and stride-1 patterns within a chip's 32 rows pay the row-opening cost once.
- **Bank-level pseudo-precharge FSM** — each bank has its own FSM that walks through LD_WAIT states after a row change, modelling row-access latency. Once "row ready" is reached, the bank stays ready until the row changes. Banks across different chips can be opening different rows in parallel.
- **Per-bank-group write buffer** — the scheduler can issue a 16-byte write to a bank group even while the actual SRAM commit is still in progress. The controller absorbs the bus payload in 4 beats, hands it to the targeted bank, and immediately returns to IDLE. The bank's long internal commit doesn't tie up the controller or the bus.
- **Layered bus permission** — three independent permission gates compose to drive the external data bus: the controller picks which internal bank may drive the internal `mem_bus`; the bank's FSM owns its OE; the DTE owns the per-slice data-bus permission. No internal arbitration logic is needed inside main memory.

## 3. Geometry

Total memory: 32 KiB, 15-bit physical address. The address layout reflects the dual slicing:

```
   physical address (15 bits)
   ┌────────┬─────┬─────┬──────┐
   │ [14:10]│[9:6]│[5:4]│[3:0] │
   │  row   │chip │bank │offset│
   │ in chip│ no. │/chip│16 B  │
   │ 32 rows│16   │ 4   │      │
   └────────┴─────┴─────┴──────┘

   bank group = address[6:4]  (a different slicing of the same address)
```

- 32 rows per chip × 16 bytes per row = 512 B per chip.
- 16 chips × 512 B = 8 KiB per slicing × 4 (banks per chip) = 32 KiB total.
- Each bank: 4 × `sram32x32$` cells = 32 rows of 16 bytes. One row is exactly one cache line.

## 4. Subsystem Organization

```
                  ld_req / st_req from DTE
                              │
                              ▼
                ┌───────────────────────────────┐
                │       mem_controller          │
                │   - chipTable (open-row)      │
                │   - bankGroupTable (writes)   │
                │   - top-level FSM             │
                └──────────┬────────────────────┘
                           │ row-open / commit
                           ▼
                ┌───────────────────────────────┐
                │  mem_bank × 64                │   (8 bank-groups × 8 banks)
                │  each owns its own FSM        │   (16 chips × 4 banks)
                │  + 4× sram32x32$              │
                └──────────┬────────────────────┘
                           │ 128-bit internal mem_bus
                           ▼
                  marshalled onto the 32-bit
                  external data bus over 4 beats
                  (under DTE permission)
```

The 128-bit internal `mem_bus` carries a full 16-byte line out of one bank; `mem_TOP` marshals it onto the 32-bit external data bus over four beats under DTE permission.

## 5. Interesting Features — In Depth

### 5.1 DDR5-Style Chip / Bank-Group / Bank Topology

The 64 banks are organized to mirror real DRAM. Two orthogonal slicings of the address:

- **Chip-major slicing** (loads, open-row tracking) — `addr[9:6]` picks one of 16 chips, `addr[5:4]` picks one of 4 banks within that chip. This is the slicing the open-row table sees.
- **Bank-group-major slicing** (stores, write routing) — `bank_group = addr[6:4]`, picking one of 8 bank groups. Each bank group has its own write buffer.

Because the two slicings are different, concurrent loads and stores naturally fan out across different physical structures even when they touch related addresses — they don't fight over the same write buffer or the same open-row entry.

### 5.2 Open-Row chipTable

DRAM-style timing: opening a row is expensive; once open, accessing words from that row is cheap. The controller keeps a per-chip table of which row is currently open and whether it's ready. The arc through the controller on a load:

```
  if (chipTable[chip].open_row == request.row && bank.row_ready)
      → 1-cycle IDLE decision, then 4-beat drive   (5 cycles total)
  else
      → walk LD_WAIT states until the bank settles, then drive
```

Stride-1 and streaming patterns within a chip's 32 rows pay the row-opening cost exactly once.

### 5.3 Bank-Level Pseudo-Precharge FSM

Each bank's FSM walks through LD_WAIT states after a row change, modelling row-access latency. Once it reaches "row ready", the bank stays ready until the row changes. Because every bank has its own FSM clocking through these states independently, **banks in different chips can be opening different rows in parallel** with no centralized scheduling — the cost of one row miss is paid by one chip's banks, not by the whole memory.

### 5.4 Per-Bank-Group Write Buffer

A 16-byte write to a bank group lands in the per-group write buffer:

1. Controller absorbs the bus payload — 4 beats over the 32-bit data bus.
2. Controller hands the buffer to the targeted bank.
3. Controller returns to IDLE; bus is free.
4. Bank does the long internal `ST_ADDR_WAIT` + `ST_WRITE_WAIT` sequence privately — not visible to the bus.

`writeBuf_V` to the scheduler is the back-pressure that prevents a second write to the same group before the first commits. With 8 bank groups, up to 8 stores can be in flight simultaneously without bus contention.

### 5.5 Layered Bus Permission

Three independent permission gates compose to drive the external data bus:

- The **controller** decides which internal bank may drive `mem_bus`.
- The **bank's FSM** owns its OE for its own contribution to `mem_bus`.
- The **DTE** owns the per-slice external-data-bus permission.

Composition: a bank only drives `mem_bus` when its FSM AND the controller say so; the external data bus only sees `mem_bus`'s contents when the DTE also says so. The same set of buses is shared across the whole memory subsystem and the rest of the chip with no internal arbitration logic.

### 5.6 Read / Write Mutual Exclusion Enforced by FSM

`ld_req` and `st_req` in the same cycle drops the controller into its synthesised `ERROR` state. The scheduler is responsible for never asserting both. The check is intentionally aggressive: any illegal traffic shows up immediately in simulation as the controller going to ERROR, instead of being silently absorbed.

## 6. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 7. Design Considerations and Trade-offs

- **64 banks** sliced two ways gives a lot of address-level concurrency for relatively little overhead — each bank is only 4 SRAM cells plus a small FSM.
- **DDR5-style organization** matches what a real memory hierarchy will see, so the simulation's timing characteristics are not optimistic by accident.
- **Per-bank-group write buffers** decouple the bus from the long internal write commit — the controller returns to IDLE quickly and lets the bus serve the next transaction.
- **Open-row tracking per chip** rewards locality without adding global arbitration — each chip independently tracks one open row.
- **No central precharge scheduler** — the bank-level FSMs precharge independently. Simpler design, at the cost of not being able to pipeline a precharge of one bank under an access to another.

## 8. Conclusions

Main memory delivers single-line responses in 5 cycles for open-row hits (1 IDLE decision + 4 bus beats), absorbs writes into per-bank-group buffers and immediately returns the controller to IDLE, and provides enough banking parallelism (8 bank groups, 16 chips) that the workloads which fan out across address space rarely contend.

A natural next design would (1) widen the data bus to cut burst length below 4, (2) add a precharge scheduler so a bank in one chip can be precharging while another in the same chip serves an access, and (3) introduce a small last-level write-combining buffer so multiple writes to the same line within a short window collapse into one bank commit.
