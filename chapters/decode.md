# Decode Stage — Design Report

> **TODO (placeholder chapter):** This chapter is a skeleton. Fill in the body using the structure below. Source material lives in `design/EverythingEverywhereAllAtOnce/rtl/core/Decode/` once those reports/notes exist. Use the per-stage REPORT_*.md files (Fetch, DC, EXE, WB) as a tone reference.

## 1. Overview

> **TODO:** One short paragraph. What the Decode stage receives from Fetch / IDM, what it produces for Register Read, whether it is single-cycle. Note that **Decode is the critical path** of the design — the binding arc that set the 11.2 ns clock.

![Decode stage block diagram.](figures/fig_decode.png){#fig:decode width=85%}

## 2. Interesting Features

> **TODO:** Bullet list (3–6 items) of the design choices worth calling out — instruction-decode tables, prefix handling, immediate extraction, microcoded vs. directly-decoded paths, exception/interrupt decode interaction, etc. Match the bullet style used in the Fetch / DC / EXE chapters.

## 3. Stage Organization

> **TODO:** ASCII block diagram showing how a fetched cache line slice flows through Decode: instruction-bytes-in → length decode / prefix decode → opcode / modrm / sib / displacement / immediate extraction → control-signal generation → operand-id generation → out to Register Read. Mirror the layout used in the EXE and DC chapter dataflow diagrams.

## 4. Per-Block Walkthrough

> **TODO:** One bullet per `.sv` file in the Decode folder, with 2–4 sentences each. Order: top-level wrapper, then individual decoders in the order data flows through them.

## 5. Interesting Features — In Depth

> **TODO:** A subsection per headline feature from §2. Each ~1 short paragraph. Match the depth used in the Fetch chapter's §5.

## 6. Critical Path / Timing

**Decode is the binding stage of the design — the critical path that sets the overall 11.2 ns clock period.**

> **TODO:** Identify and describe the long arc that makes Decode the critical stage. Likely candidates: prefix-then-opcode chained decode, deep modrm/sib resolution, immediate-size selection feeding the operand bus. Once STA results are in, replace this TODO with the actual gate-level explanation.

## 7. Design Considerations and Trade-offs

> **TODO:** 4–6 bullets on the trade-offs taken in the Decode design (decode-table size vs. flexibility, single-cycle vs. two-cycle, structural-port approach, etc.).

## 8. Conclusions

> **TODO:** One short paragraph wrapping up what Decode delivers, the fact that it was the binding arc, and one or two "next design" recommendations (e.g. splitting Decode into two stages to relax the cycle).
