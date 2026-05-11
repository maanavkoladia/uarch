---
title: "EverythingEverywhereAllAtOnce — CPU Final Design Report"
author: "Jacob"
date: "2026-05-XX"
documentclass: report
geometry: margin=1in
toc: true
numbersections: true
---

# Abstract

This report describes the design of a 7-stage in-order CPU and its accompanying memory subsystem. The pipeline runs Fetch → Decode → Register Read → Dependency Check → MEM → Execute → Writeback, and the memory subsystem comprises an ICache, a 4-way bank-interleaved DCache, a bus-arbitration layer, a DDR5-style banked main memory, an MMIO temperature/power-gate peripheral, and a DMA controller. The design's six headline features are: (1) a **4-way banked DCache** in which each bank is backed by a **4-way set-associative victim cache**; (2) a **highly banked main memory** (64 banks across 16 chips and 8 bank groups); (3) a **VIPT ICache** with a **4-way set-associative victim cache**; (4) **GShare-driven speculative fetch** at cache-line granularity; (5) **data forwarding** in the back-end; and (6) **early writeback in execute** — register writeback ports are dispatched out of EXE so the WB stage only handles stores. The whole design runs at an overall clock period of **11.2 ns**, with the **Decode stage** as the binding critical-path arc.

# Introduction

The headline features of this CPU, in equal weight across the pipeline and memory subsystem:

1. **4-way banked DCache, each bank backed by a 4-way set-associative victim cache.** The L1 stays direct-mapped and single-cycle on hit, while the per-bank victim cache absorbs conflict misses without going to main memory.
2. **Highly banked main memory.** 64 banks total, organized as 16 chips × 4 banks/chip for load fan-out and 8 bank-groups × 8 banks/group for write routing. Two orthogonal slicings of the same address.
3. **VIPT ICache with a 4-way set-associative victim cache.** Single-cycle hit; the segment-translated address indexes the cache combinationally so the tag check and the array read overlap with the TLB.
4. **GShare-driven speculative fetch.** An 8-bit global history register XORed with PC bits indexes a 256-entry PHT; cache-line-granularity branch prediction lets the IDM buffer hold one prediction per 16 B line.
5. **Data forwarding** in the back-end so back-to-back dependent instructions don't bubble. The forwarding network reads results out of EXE's writeback ports and routes them back into Register Read's operand mux.
6. **Early writeback in execute.** The register-file write-back ports are driven directly from EXE; the WB stage only handles the store queue. This keeps the register-update latency to one cycle from EXE.

The overall design approach is **short single-cycle pipeline stages with deliberate cross-stage offloading**: EXE handles load-data alignment that MEM deliberately skips; EXE drives the register write-back ports so WB can be a queue stage rather than a compute stage. The result is a 7-stage in-order pipeline whose interesting design choices live in *how* the work is divided across the stages, not in any one stage's complexity.

![Top-level pipeline and memory subsystem.](figures/fig_overall.png){#fig:overall width=90%}

# Pipeline Overview

An instruction flows through seven stages:

1. **Fetch** — speculatively fetches 16-byte cache lines through the ICache, annotates them with branch-prediction metadata from the BTB and GShare predictor, and parks them in the IDM buffer for downstream consumption.
2. **Decode** — turns the bytes from a cache line into a per-instruction set of control signals, register IDs, immediates, and addressing-mode info. *Decode is the critical path of the design — the binding arc that sets the 11.2 ns cycle.*
3. **Register Read** — reads architectural register operands and runs the address-generation half of addressing-mode resolution. Owns the data-forwarding network that catches back-to-back register dependencies.
4. **Dependency Check (DC)** — translates the partially-logical address through segment translation and the TLB, then checks the resulting physical address against in-flight stores (both still in the pipeline and waiting in the WB store queues). Stalls the load if a dependency is detected. Drives the cache request to the DCache arbiter when clear.
5. **MEM** — receives DCache hit signals and lines back from the four bank ports plus the MIO port. Buffers them per-port so cache-delivery timing decouples from MEM consumption. Assembles 32-byte XCL load windows into a forward buffer for EXE.
6. **Execute (EXE)** — every functional unit runs every cycle on the same operand pair. Result selection uses tristate-driven shared buses gated by op-type. EXE does the load-data alignment that MEM deliberately skipped, packs store data into the WB store-buffer format, resolves branches, and drives the register-file write-back ports.
7. **Writeback (WB)** — handles stores only. Pushes store entries into one of four bank-interleaved store queues (or the single-entry MIO queue). Drains them to the DCache asynchronously. The register file was already written from EXE.

Two stages without their own chapter:

- **IDM** — the 4-slot buffer between Fetch and Decode. Holds cache lines plus their branch-prediction metadata. Covered in detail in the Fetch chapter.
- **StageLatches** — the inter-stage flop infrastructure. Plain registers carrying the structs declared in each stage's package. No chapter-level design content.

The back-pressure model is uniform: each stage signals stall back to the previous stage, and stalls propagate to the front of the pipe. There is **no store-to-load forwarding**; the DC stage detects load-store conflicts and stalls the load until the older store retires into the DCache. The trade-off is some load latency in exchange for much simpler scoreboard hardware.
