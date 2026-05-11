# Critical Path Analysis

The overall clock period of the design is **11.2 ns**.

The **Decode stage is the critical path** — the binding arc that sets the 11.2 ns cycle. Every other stage in the pipeline fits comfortably under the clock period and contributes to the design but was not the limiting factor. The Decode chapter (Chapter 4) discusses the long arc that makes that stage binding; the per-stage chapters for Fetch, RR, DC, MEM, EXE, and WB each include a short note in their Critical Path / Timing sections pointing back to the 11.2 ns overall number and confirming that they were not the binding stage.

No per-stage timing numbers are claimed beyond the overall clock period. Per-stage breakdowns were not separately measured, and inventing numbers would mislead the reader. The Decode chapter is where the actual gate-level reasoning for the binding arc lives; the rest of the report defers to that.

# Conclusions

Returning to the six headline features the report opened with:

1. The **4-way banked DCache with per-bank 4-way set-associative victim caches** delivers single-cycle L1 hits on the common path, absorbs conflict misses locally, and gives the arbitration layer enough independence between banks to service up to six concurrent requests (two loads + four store-queue heads) in the same cycle when addresses cooperate.
2. The **highly banked main memory** (64 banks, 16 chips × 4 banks/chip for loads, 8 bank-groups × 8 banks/group for writes) keeps concurrent loads and stores out of each other's way and rewards locality through per-chip open-row tracking.
3. The **VIPT ICache with a 4-way set-associative victim cache** keeps the front-end's hit path single-cycle by overlapping segment translation with the cache index, while the victim cache absorbs the conflict-miss tail of a direct-mapped L1.
4. **GShare-driven speculative fetch** with cache-line-granularity prediction and a two-history-register rollback scheme keeps the front end fed without giving up the ability to roll back cleanly on a misprediction.
5. **Data forwarding** in the back-end lets back-to-back dependent instructions execute without bubbles by routing values out of EXE's writeback ports back into the Register Read operand mux.
6. **Early writeback in execute** means WB only handles stores. The register-file write happens one cycle out of EXE, not two — and the WB stage stays a pure queue stage with no compute on the critical path.

The cross-stage trade-offs that fall out of those choices: no store-to-load forwarding (so dependency conflicts always stall the load, but the scoreboard hardware stays simple); load-data alignment deferred from MEM to EXE (so MEM is a queue stage too); parallel-FU dispatch in EXE with shared-bus result selection (so the wide selector mux never sits on the cycle); banked organization throughout (so concurrent traffic spreads naturally).

On the critical path: **Decode set the cycle at 11.2 ns**. The natural next-design recommendation is to split Decode into two pipeline stages, which would let the clock target drop substantially. Other "next design" suggestions from the per-chapter conclusions: add bypass-style store-to-load forwarding to remove the load-stall on common-case RAW conflicts; widen the data bus from 32 bits to halve the 4-beat burst length; move branch resolution earlier in the pipe to reduce the misprediction penalty; increase L1 cache associativity to reduce the rate at which lines flow through the victim caches.
