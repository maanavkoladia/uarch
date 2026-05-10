# MEM Stage — Design Report

## 1. Overview

The MEM stage is the cycle after DC. It is the stage where data-cache replies actually arrive and where the load result is **assembled**, but it does **not** byte-align or sign-extend. Because the data cache is 4-way banked, MEM sees four independent hit/data ports back from the cache plus a separate port for memory-mapped I/O (MIO). On a hit, the relevant cache lines are picked off the right banks and packed into a 32-byte load buffer (`ld_buf`) that the next stage (EXE) consumes. On a miss, MEM stalls itself and the upstream pipeline until the data arrives.

The stage is small but has two ideas worth attention: a **per-port cache-hit buffer** that decouples cache-reply timing from downstream consumption (so a single delivered line doesn't have to be consumed the same cycle), and a **truth-table-driven** handshake block (`EXE_valid_logic`) that makes the valid/stall path between MEM, EXE, and WB short and predictable.

## 2. Interesting Features

- **Per-port cache-hit buffering** — every D-cache bank port has a one-cycle hit buffer. If the cache delivers a line while MEM is stalled (or before it's needed), the line is held in the buffer and consumed on the next non-stall cycle. This lets the cache and MEM tick on slightly decoupled rhythms without losing data.
- **32-byte XCL load assembly** — for accesses that cross a cache-line boundary (`LD_XCL`), MEM grabs the line from each of the two banks involved and packs them into a 32-byte buffer (`low_buf` + `up_buf` → `ld_buf`). EXE then extracts the right window in its own cycle.
- **Separate MIO path** — non-cacheable accesses come back on their own port (`hit_MIO` / `line_MIO`) with its own one-line buffer (`hit_buf_mio`), kept entirely separate from the cache-bank machinery.
- **Truth-table valid/stall handshake** — [gen/EXE_valid_logic.v](design/EverythingEverywhereAllAtOnce/rtl/core/MEM/gen/EXE_valid_logic.v) is auto-generated from a 4-input / 2-output truth table, so the MEM↔EXE↔WB handshake is a flat combinational lookup instead of a long behavioral path.
- **Deferred alignment** — load data is *not* byte-shifted, masked-by-data-size, or sign-extended in MEM. The 32-byte buffer is forwarded to EXE, which already has the shifter/ALU needed to extract the operand. Keeps MEM's datapath clean.

## 3. Top-Level Dataflow

```
        from DC (latches: paddr, bank_num_0/1, LD_OP, LD_XCL, MIO, etc.)
                                │
                                ▼
       ┌──────────────────────────────────────────────────┐
       │              MEM stage                           │
       │                                                  │
       │   D-cache hits[4]   ──►  hit_buf[4]  ──►  pick   │
       │   cacheline[4]      ──►  hit_buf data    by      │
       │                                          bank    │
       │   hit_MIO ─────────►  hit_buf_mio  ──►   index   │
       │   line_MIO                                       │
       │                                                  │
       │           bank_num_0 → low_buf (16B)             │
       │           bank_num_1 → up_buf  (16B)   (XCL)     │
       │                                                  │
       │              ┌────────────────────┐              │
       │              │   ld_buf [32 B]    │ ───► to EXE  │
       │              └────────────────────┘              │
       │                                                  │
       │   mem_miss_stall_logic  →  miss_stall            │
       │   EXE_valid_logic       →  EXE_we, N_EXE_V       │
       │   clr_dcache_arb_latches[4] / clr_mio  ──► to DC-arb│
       └──────────────────────────────────────────────────┘
                                │
                                ▼
                       to EXE (with ld_buf,
                       paddr offset for alignment)
```

The cache returns four `hit[]` bits and four 16-byte cache lines every cycle (one per bank). Each port has a one-cycle buffer. The load's address tells MEM which bank to read for the primary line (`bank_num_0`); for an XCL access it also reads `bank_num_1` for the second line. Both lines are assembled into the 32-byte `ld_buf` that gets forwarded to EXE. If the line for the active bank hasn't been seen yet (no hit and no buffered hit), `mem_miss_stall_logic` stalls. Once the request has been served, MEM signals the DC-arb logic to clear the held request via `clr_dcache_arb_latches`.

## 4. Per-Block Walkthrough

- **[MEM.sv](design/EverythingEverywhereAllAtOnce/rtl/core/MEM/MEM.sv)** — top-level stage. Holds the 4 per-bank hit buffers and the MIO buffer; picks the right line(s) by bank index; packs `low_buf` + `up_buf` into the 32-byte `ld_buf`; drives the cache-arbiter clear signals once the request has been served; instantiates `mem_miss_stall_logic` and `EXE_valid_logic`.

- **[mem_miss_stall_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/MEM/mem_miss_stall_logic.sv)** — single-cycle stall generator. Asserts `miss_stall` when the access is valid and any required line is still missing:
  ```
  miss_stall = (mio_miss | ld_miss | xcl_miss) & valid
  ```
  The "miss" inputs already account for the buffered hits, so a line that was delivered in a previous cycle and parked in the hit buffer counts as a hit and does *not* stall.

- **[gen/EXE_valid_logic.v](design/EverythingEverywhereAllAtOnce/rtl/core/MEM/gen/EXE_valid_logic.v)** — auto-generated combinational handshake. Inputs: `MEM_V`, `MEM_stall`, `EXE_V`, `WB_stall`. Outputs: `EXE_we` (latch enable for the EXE stage register) and `N_EXE_V` (the next-cycle valid bit forwarded into EXE). Built from a CSV truth table to keep this path short.

- **[structural/](design/EverythingEverywhereAllAtOnce/rtl/core/MEM/structural/)** — synthesis-targeted versions of `MEM` and `mem_miss_stall_logic`.

## 5. Interesting Features — In Depth

### 5.1 Per-Port Cache Hit Buffering

The data cache delivers a hit signal and a 16-byte line on each of its 4 bank ports every cycle. MEM doesn't necessarily want them "right now" — the stage might be stalled for some other reason (WB backpressure, an XCL miss on the *other* bank, etc.). To avoid throwing the line away, MEM has a one-cycle **hit buffer per port**:

```
if (hit[i] && latches_i.valid)
    hit_buf_v[i]  <= 1;
    hit_buf[i]    <= cacheline[i];
```

When the stage finally gets to consume the line, the data path picks **either** the live cache return **or** the buffered one:

```
line_in_0 = hit_buf_v[bank_num_0] ? hit_buf[bank_num_0] : cacheline[bank_num_0];
```

The MIO path has its own copy of this (`hit_buf_mio_v`, `hit_buf_mio`).

The benefit: the cache's reply timing is decoupled from MEM's consumption timing by one cycle, which is enough to absorb most of the small-grained handshake jitter between the banks, MEM, and the rest of the back-end. Without it, every DC-arb stall, WB-stall, or XCL alignment hazard could potentially drop a delivered line.

### 5.2 32-Byte XCL Load Assembly

When a load straddles a cache-line boundary, the bytes live in two cache banks. MEM puts the two relevant lines into a 32-byte buffer:

```
C0       = MIO ? line_in_mio : line_in_0_masked;
low_buf  = C0;                       // primary 16 B
up_buf   = line_in_1_masked;         // secondary 16 B (XCL)
ld_buf   = { up_buf, low_buf };      // 32 B, forwarded to EXE
```

`ld_buf` (`EXE_BUFFER_SIZE = 32`) is wide enough that EXE can extract any window of bytes for any data-size, regardless of how they straddle the cache-line boundary. MEM doesn't need to know the operand size — it just forwards both lines.

### 5.3 Separate MIO Path

Memory-mapped I/O is non-cacheable and uses its own port (`hit_MIO`, `line_MIO`). It has its own buffer (`hit_buf_mio`) and its own miss bit (`mio_miss`). On an MIO load, the data path replaces `low_buf` with `line_in_mio` instead of using the bank-indexed cache line. Keeping MIO entirely separate avoids contaminating the cache hit/miss tracking with MMIO-specific timing, which can be slow and irregular.

### 5.4 Truth-Table Handshake (`EXE_valid_logic`)

Pipeline valid/stall handshakes are easy to write as deeply nested `if`/`?:` and very hard to keep timing-clean. This stage takes a different approach: the four-input handshake is enumerated in a CSV truth table and the combinational logic is generated from it directly as `gen/EXE_valid_logic.v`.

- Inputs: `MEM_V`, `MEM_stall`, `EXE_V`, `WB_stall`
- Outputs: `EXE_we` (advance the EXE latch), `N_EXE_V` (next-cycle EXE valid)
- Both polarities of each output are produced so downstream consumers don't add an inverter delay onto whichever polarity they need.

### 5.5 Deferred Byte Alignment

This is the design choice that keeps MEM small: load data is *not* byte-shifted, sign-extended, or masked-by-data-size in MEM. The full 32-byte `ld_buf` is forwarded to EXE along with the load address. EXE already has the shifter/ALU it needs to extract a 1/2/4-byte window from any offset and sign-extend it. Doing the extraction here would add a barrel-shifter to a stage that is otherwise just hit-buffering and bank-selection, and would duplicate hardware that EXE has anyway.

## 6. Critical Path / Timing

The dominant arc in MEM runs from the cache hit/data ports, through hit-buffer mux (`hit_buf_v ? hit_buf : cacheline`), through the bank-index selection, through the load-data masking, into the EXE stage register. In parallel, the miss-stall path (`mem_miss_stall_logic` → `EXE_valid_logic` → `EXE_we`) needs to settle in time to gate that same register.

Measured on synthesis: **__ ns** *(to be filled in once STA is run on this branch — no estimate is given here.)*

A secondary arc to watch is the `clr_dcache_arb_latches[]` path back to the DC-arb logic. It's not on the cycle's worst path today, but if the cache-arbiter's hold/clear loop ever closes through it, that becomes the bottleneck.

## 7. Design Considerations and Trade-offs

- **Hit buffers per port (4 + MIO)**: small area cost in exchange for decoupling cache-delivery timing from MEM consumption — pays for itself the first time a single-cycle XCL hazard would otherwise have dropped a delivered line.
- **Forward 32 bytes, align in EXE**: avoids a barrel-shifter in MEM, reuses EXE's shifter, and removes data-size knowledge from this stage.
- **Truth-table handshake instead of behavioral logic**: more verbose to author, but the resulting flat combinational structure (with dual-polarity outputs) is exactly what timing wants on the valid/stall path.
- **MIO on its own path**: keeps the cache-bank machinery uncontaminated by I/O timing irregularity, at the cost of an extra small buffer and a few extra mux inputs.
- **Strict in-order stall propagation**: when MEM stalls, EXE doesn't advance, and back-pressure rolls upstream. No reordering, no replay queue — simplest possible model.

## 8. Conclusions

MEM is the smallest of the front-half stages, and that's by design. It does three things — buffer cache returns per port, assemble cross-line loads into a 32-byte staging buffer, and drive a tight handshake into EXE — and pushes everything else (alignment, sign-extension, eviction, store-queue draining) into stages better suited for it. The two non-trivial ideas are the per-port hit buffer (which absorbs most of the timing jitter that would otherwise lose data) and the truth-table-driven handshake (which keeps the valid/stall path off the slow path).

A natural next design would (1) extend the hit buffer to more than one cycle of depth so it could absorb longer cache-arbiter stalls, (2) add a small load-result forwarding network so that EXE can consume a load result one cycle earlier on the common case, and (3) consider doing the extraction here (with a small shifter) for narrow loads, so that EXE's shifter is freed up for ALU work.
