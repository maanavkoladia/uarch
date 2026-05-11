# ICache Subsystem — Design Report

> **TODO (placeholder chapter):** This chapter is a skeleton. The Fetch stage chapter already covers the ICache briefly from the *consumer* side; this chapter covers the cache subsystem itself.

## 1. Overview

> **TODO:** One short paragraph. The ICache services 16-byte cache-line fetches issued by the Fetch stage. Hits return the line in the same cycle the request is issued. Misses fan out to the bus arbitration / main memory path.

![ICache subsystem block diagram.](figures/fig_icache.png){#fig:icache width=85%}

## 2. Interesting Features

The two headline features of the ICache are the **VIPT (Virtually Indexed, Physically Tagged) organization** and the **4-way set-associative victim cache** that backs the L1.

> **TODO:** Expand into a full bullet list:
>
> - VIPT organization — index with virtual address bits while the tag check uses the post-TLB physical bits, so the cache index and the TLB lookup overlap and a hit is single-cycle.
> - 4-way set-associative victim cache absorbing conflict misses from the direct-mapped L1.
> - Single-cycle hit decision.
> - Miss-handling FSM (fill from bus, victim swap, etc.).
> - Any other ICache-specific features (line size, total capacity, tag/data store organization).

## 3. Subsystem Organization

> **TODO:** ASCII block diagram showing the L1 ICache (direct-mapped or set-associative — fill in), the victim cache, the eviction/swap buffers, and the miss-handling FSM. Show how a fetch request enters from Fetch and how data comes back. Mirror the layout used in the DCache chapter.

## 4. Per-Block Walkthrough

> **TODO:** One bullet per `.sv` file in the ICache subsystem folder. Look in `design/EverythingEverywhereAllAtOnce/rtl/ICache/` (if it exists) or wherever the ICache RTL lives.

## 5. Interesting Features — In Depth

### 5.1 VIPT Organization
> **TODO:** Explain why VIPT — index with the virtual bits that don't change under translation, so the cache lookup overlaps the TLB. The Fetch chapter has a short version of this; this is the place for the longer treatment with the actual index / tag / offset split, the segment-translation handoff, etc.

### 5.2 4-Way Set-Associative Victim Cache
> **TODO:** How many entries per way? Replacement policy (LRU? tree-PLRU?). How a miss flows: L1 miss → victim-cache probe → swap or memory fill. How swap buffers decouple the victim cache from the L1.

### 5.3 (other features)
> **TODO:** As needed.

## 6. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 7. Design Considerations and Trade-offs

> **TODO:** 4–6 bullets. Trade-offs for VIPT (no alias problem here thanks to the segmentation model — see Fetch chapter), trade-offs for the victim-cache associativity choice, line-size choice.

## 8. Conclusions

> **TODO:** One paragraph on what the ICache delivers, plus "next design" suggestions (set-associative L1, larger victim cache, prefetcher, etc.).
