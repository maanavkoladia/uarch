# DC Stage — Design Report

## 1. Overview

The DC (Dependency Check) stage sits between the back-end's address calculation and the data-cache subsystem. Its job each cycle is to: (1) translate the partially-logical address coming out of the previous stage into a physical address (segment translation + TLB), (2) decide whether the load it is about to issue is **safe** to issue — i.e. that no older store with the same address is still in flight or waiting in the store queue, and (3) drive a request to the data-cache arbiter on one of three load ports. The actual data-cache subsystem is described in its own chapter; this stage is the *pipeline* logic that prepares and gates the request. Stores are not written here; they are forwarded to the WB-stage store queues and drained from there. Exceptions (page faults, GP faults from segment limit checks) are also raised in this stage.

The whole stage is timing-critical. The dependency-checking logic is the dominant arc — every cycle the front of the stage has to compare an in-flight load address against several pending stores (in MEM, EXE, and WB) **and** all 16 entries of the WB store queue, in time to decide whether to fire the cache request this cycle. Most of the interesting design choices in DC are aimed at squeezing that arc.

## 2. Interesting Features

- **Dual-TLB cross-page translation** — [npu_node2.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/npu_node2.sv) instantiates two TLBs (`tlb0`, `tlb1`) and translates two adjacent virtual pages in parallel, so a load/store that crosses a 4 KB page boundary still resolves in one cycle.
- **Address-split dependency checking** — the in-flight scoreboard splits the physical address into an 8-bit page offset and a 3-bit PFN. The page-offset compare runs **before** the TLB returns; the PFN compare runs **after**. The two halves AND together at the end, so the critical path through dependency checking is shorter than waiting for the full TLB output.
- **Two-tier load-store hazard detection** — [in_flight_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/in_flight_sb_logic.sv) checks against in-pipeline stores (MEM/EXE/WB), [wb_stq_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/wb_stq_sb_logic.sv) checks against the 16 entries of the WB store queue. A load only fires when both clear.
- **Strict ordering, no store-to-load forwarding** — when a load matches a pending store, it stalls. The trade-off is simpler scoreboard logic in exchange for some load latency.
- **Three independent cache request ports** — [req_gen_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/req_gen_logic.sv) drives `addr0`, `addr1`, and `addr_MIO` to the cache arbiter, with per-port stall/served handshaking so a request that hasn't been granted is held until it is.
- **Stack-aware push address generation** — [push_address_gen.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/push_address_gen.sv) recomputes store addresses for `PUSH` / `CALL` / `FAR_CALL` / `EXP_CALL` because the decoded address is the *high* end of the operand and the stack grows down.
- **Segment-limit check in parallel with TLB** — [segx.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/segx.sv) raises a GP fault when the logical address exceeds the segment limit, runs in parallel with translation, and skips the check on stack accesses (which have inverted limit semantics).

## 3. Top-Level Dataflow

```
                  logical addr from previous stage
                              │
                ┌─────────────┴──────────────┐
                ▼                            ▼
       ┌─────────────────┐        ┌──────────────────┐
       │ SegmentTrans    │        │     segx         │
       │  (base+limit)   │        │ (limit / GP chk) │
       └────────┬────────┘        └────────┬─────────┘
                │ v_addr                   │ gp_fault
                ▼
       ┌─────────────────────────────┐
       │       npu_node2             │
       │  ┌─────────┐   ┌─────────┐  │
       │  │  tlb0   │   │  tlb1   │  │   ← cross-page
       │  └────┬────┘   └────┬────┘  │     dual lookup
       │       └──────┬──────┘       │
       └──────────────┼──────────────┘
                      │ PADDR0, PADDR1, xcl, PF/GP
                      ▼
       ┌─────────────────────────────────────────┐
       │  in_flight_sb_logic   wb_stq_sb_logic   │
       │   (MEM / EXE / WB)    (16-entry STQ)    │
       └────────────────────┬────────────────────┘
                            │ dep_stall
                            ▼
                  ┌──────────────────┐
                  │   req_gen_logic  │ ────► to D-cache arbiter
                  │ (addr0/1/MIO)    │       (3 load ports)
                  └──────────────────┘
                            │
                            ▼
                next-stage latches (MEM)
            with paddr, xcl, exception flags
```

The logical address goes into segment translation and the segment-limit check (`segx`) in parallel. The translated virtual address goes into `npu_node2`, which fires both TLBs simultaneously — `tlb0` for the primary page, `tlb1` for the next page — so a cross-page access is still single-cycle. While translation is happening, the dependency scoreboards are already comparing the **page-offset** half of the address against pending stores. Once the TLB returns, the **PFN** half of the comparison completes, the two halves AND together, and `req_gen_logic` either fires the request to the cache arbiter or holds it until any stall clears.

## 4. Per-Block Walkthrough

The blocks are presented roughly in the order an access flows through them.

- **[DC.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/DC.sv)** — top-level wiring. Instantiates `segx`, `npu_node2`, the two scoreboards, `req_gen_logic`, `data_size_vec_logic`, and `push_address_gen`; takes stage latches in (logical address, MEM/EXE/WB store info, arbiter feedback); produces the next-stage latch (paddr, xcl, exception flags, valid).

- **[segx.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/segx.sv)** — combinational segment-limit check. Raises `segx_gp` when the logical address exceeds the limit register for the active segment. The limit is pre-stored in two forms (with and without data-size offset) to keep the compare to a single subtract. Skipped on stack accesses, where the limit semantics are inverted (stack grows down).

- **[npu_node2.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/npu_node2.sv)** — dual-TLB translator. Despite the name, it has nothing to do with neural processing — it instantiates `tlb0` and `tlb1` (the second only used when `cross_page_access` is asserted) and emits `PADDR0`, `PADDR1`, the `xcl` (cross-cache-line) flag, MIO bit, and translation exceptions (PF, GP). On a single-page access `tlb1`'s outputs are masked.

- **[in_flight_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/in_flight_sb_logic.sv)** — checks the load against stores currently in MEM, EXE, and WB (two store slots per stage). The load address is split into an 8-bit offset (`paddr[11:4]`) and a 3-bit PFN bank index (`paddr[14:12]`); the offset compare can fire pre-TLB while the PFN compare waits for translation. Output is a single `in_flight_mem_stall` signal.

- **[wb_stq_sb_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/wb_stq_sb_logic.sv)** — checks the load against the WB-stage store queues (`NUM_WB_ST_QS = 4` queues × `ST_Q_DEPTH = 4` entries = 16 entries). The load's lower address bits select which bank to scan; all entries in that bank are compared in parallel on `paddr[14:4]`. No data forwarding — match → `stq_stall`.

- **[req_gen_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/req_gen_logic.sv)** — drives three independent load ports to the data-cache arbiter (`addr0`, `addr1`, `addr_MIO`). Per-port valid is held until the arbiter signals `req_served_*`. Requests are aligned to 16-byte cache-line boundaries (`& 32'hFFFF_FFF0`). Asserts `arb_stall` if any port hasn't been served, so no request is dropped.

- **[push_address_gen.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/push_address_gen.sv)** — recomputes store addresses for stack pushes. The decoded operand address is the high end of the bytes being written; this module subtracts `num_bytes` to get the actual low address, and sets `ST_XCL_o` if the resulting range crosses a cache line. Pass-through for non-push operations.

- **[data_size_vec_logic.sv](design/EverythingEverywhereAllAtOnce/rtl/core/DC/data_size_vec_logic.sv)** — expands the 2-bit `data_size` from Decode into a 4-bit byte-enable vector for the destination/source registers. Also produces `shift_sr_up` / `shift_sr_down` for 8-bit operations targeting the *high* byte of a 16-bit register (e.g. `AH`), so that data is realigned correctly on the return path.

- **[gen/mem_valid_logic.v](design/EverythingEverywhereAllAtOnce/rtl/core/DC/gen/mem_valid_logic.v)** — auto-generated combinational block (from a truth table) that decides when the MEM-stage latch advances and what the next valid bit is, based on DC stall, MEM stall, and WB stall. Pre-verified across all 64 input combinations so it doesn't need separate validation.

The [pkg/](design/EverythingEverywhereAllAtOnce/rtl/core/DC/pkg/) folder defines the structs that cross these blocks (notably `npu_node2_outputs_t`: `PADDR0`, `PADDR1`, `xcl`, `bank_hi`, `DC_PF`, `DC_GP`). The [structural/](design/EverythingEverywhereAllAtOnce/rtl/core/DC/structural/) folder holds synthesis-targeted versions of each block.

## 5. Interesting Features — In Depth

### 5.1 Dual-TLB Cross-Page Translation

A single load or store can straddle a 4 KB page boundary — the bytes on either side may map to different physical frames, so one TLB lookup isn't enough. `npu_node2` solves this by instantiating two TLBs and firing both every cycle:

- **`tlb0`** translates the primary virtual page (the page containing the start of the access).
- **`tlb1`** translates the *next* page; its outputs are only honored when `cross_page_access` is asserted.
- Both lookups happen in parallel, so a cross-page access is **not** a multi-cycle event — the cost is just the second TLB instance.
- Each TLB is 8 entries, 4 KB page size, with permission bits driving GP faults and an MIO bit for memory-mapped I/O.

The combined output (`PADDR0`, `PADDR1`, `xcl`) feeds the rest of the stage. Page faults and GP faults from either TLB suppress the cache request.

### 5.2 Address-Split Dependency Checking

This is the central optimization in the stage. The load address being checked is split:

- **Page offset** = `paddr[11:4]` — 8 bits, identical to bits in the *virtual* address (since pages are 4 KB-aligned). **Available before the TLB returns.**
- **PFN bank** = `paddr[14:12]` — 3 bits, only known **after** translation.

The page-offset comparison against every pending store starts as soon as the virtual address is available; the PFN comparison runs in series with the TLB; the two halves AND together at the very end. A naive design would wait for the full physical address before comparing anything, which would put translation **and** the address compare in series on the critical path.

The serial portion of the dependency-check path is reduced to a small post-TLB compare instead of a full-address compare, which is the win.

### 5.3 Two-Tier Load-Store Hazard Detection

A load can conflict with a store that is either still in the pipeline (issued but not retired) or already retired into the WB store queue (waiting to drain into the data cache). Each tier has its own checker:

- **`in_flight_sb_logic`** — compares against the MEM, EXE, and WB stage stores (two store slots per stage). Uses the address-split scheme above.
- **`wb_stq_sb_logic`** — compares against all 16 WB store-queue entries (`NUM_WB_ST_QS = 4`, `ST_Q_DEPTH = 4`). The load's low address bits pick a bank; all 4 entries of that bank are compared in parallel.

If either checker hits, the load stalls in DC. The stage holds the request through `req_gen_logic`'s per-port valid latch, so no request is lost while waiting.

The deliberately conservative choice here is **no store-to-load forwarding**. The stage is allowed to stall the load and let the older store retire into the cache first. The win is that the scoreboards don't need to track store *data* or do any byte-mask intersection — they only need to detect address conflicts. Given how tight the critical path already is, this trade-off is the right call.

### 5.4 Three Cache Request Ports

`req_gen_logic` exposes three independent load request channels — `addr0`, `addr1`, and `addr_MIO` — to the data-cache arbiter:

- `addr0` / `addr1` are normal loads (the dual ports allow servicing a cross-cache-line access without serializing).
- `addr_MIO` is for memory-mapped I/O (TLB's MIO bit routes the request here).
- Each port has its own valid / served handshake. A port asserts `valid` and holds it until the arbiter responds with `req_served`.
- If any port has an unserved request, `arb_stall` is asserted and DC does not advance — preventing newly issued loads from clobbering held requests.

Addresses sent to the arbiter are masked to 16-byte cache-line alignment.

### 5.5 Stack Push Address Generation

The Decode stage produces store operands with the address pointing at the *high* end of the bytes being written (because that's where the operand naturally lives). For stack `PUSH` / `CALL` / `FAR_CALL` / `EXP_CALL`, the actual store needs to start at the *low* address (stack grows downward). `push_address_gen` does:

```
start_address = ST_PADDR_0 - num_bytes
ST_XCL_o      = start_address[4] != end_address[4]   // crosses cache line
```

For all non-push operations the address passes through unchanged.

## 6. In-Flight Scoreboard Address Split (Diagram)

```
                Physical Address (32 bits, paddr)
       ┌──────┬──────┬──────────┬──────────┬─────────┐
   bit │ 31 .. │  15  │  14:12   │  11:4    │  3:0    │
       │       │      │          │          │         │
   use │ tag   │  ─   │   PFN    │  offset  │ within  │
       │       │      │ (3 bits) │ (8 bits) │  line   │
       └──────┴──────┴────┬─────┴────┬─────┴─────────┘
                          │           │
              wait on TLB │           │ pre-TLB available
                          ▼           ▼
                    ┌─────────┐  ┌─────────┐
                    │ PFN cmp │  │ off cmp │   (parallel for every
                    └────┬────┘  └────┬────┘    candidate store)
                         └─────┬─────┘
                               ▼ AND
                          per-store match
                               │
                               ▼ OR across all candidates
                       in_flight_mem_stall
```

The `offset cmp` block fires as soon as the virtual address is available — it does **not** wait for `npu_node2`. The `PFN cmp` block waits for the TLB output, but it's the smaller of the two compares (3 bits vs. 8). The serial portion of the path is therefore TLB-then-3-bit-compare, instead of TLB-then-full-address-compare.

## 7. Critical Path / Timing

The dominant arc in DC runs from the previous-stage latch outputs, through segment translation and the dual TLBs in `npu_node2`, into the post-TLB half of `in_flight_sb_logic` and `wb_stq_sb_logic`, into `req_gen_logic`'s valid generation, and out to the cache arbiter — i.e. translate, dependency-check, and request-fire all in the same cycle.

This arc contributes to the overall **11.2 ns** clock period but was not the binding stage — the Decode stage set the cycle time.

Two secondary arcs to watch:

- **Pre-TLB offset compare** — the `paddr[11:4]` half of the in-flight scoreboard. This is intentionally *off* the critical path, but if it ever became the long arc the address-split optimization is no longer buying anything.
- **Segment-limit check (segx) → exception → req_gen valid** — runs in parallel with the dependency path; whichever is slower decides cycle time.

## 8. Design Considerations and Trade-offs

- **Two TLBs (`npu_node2`) over single-TLB-with-replay**: cheaper area, more expensive timing — but a replay would have cost a cycle on every cross-page access, which is not rare.
- **Address-split scoreboard** trades a small amount of comparator area for a meaningfully shorter critical path — the right trade for the timing-critical arc.
- **No store-to-load forwarding**: simplifies the scoreboards (no data path, no byte-mask intersection) at the cost of stalling some loads. Acceptable because the WB store queue drains quickly.
- **Strict in-order semantics** — loads are not allowed to bypass earlier unresolved stores. Conservative, but it means correctness arguments about ordering are local to DC.
- **Three cache ports vs. one wider port**: keeps the arbiter simpler at the cost of needing per-port valid/served handshaking and stall feedback.
- **Push address generation kept off the critical path** — handled in its own combinational block that feeds the next-stage latch, not the cache request.

## 9. Conclusions

The DC stage delivers, in one cycle on a clean path, a translated and dependency-cleared physical address into the data-cache arbiter. The dependency check is the dominant cost, and the design squeezes it through three concrete ideas: dual-TLB cross-page translation, address-split pre/post-TLB comparison, and two-tier scoreboarding (in-pipeline plus store-queue). Stores are intentionally pushed into the WB store queue rather than written here, and load-store forwarding is intentionally absent, both to keep this stage's logic shallow.

A natural next design would (1) add bypass-style store-to-load forwarding for the common matching-line case (saves load stalls at the cost of a data path through the scoreboard), (2) widen the TLB beyond 8 entries to reduce TLB-miss rate, and (3) consider a small load-address predictor so that some dependency stalls could be speculated past instead of waiting.
