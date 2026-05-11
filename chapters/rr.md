# Register Read Stage — Design Report

> **TODO (placeholder chapter):** This chapter is a skeleton. Reference material exists at `design/EverythingEverywhereAllAtOnce/rtl/core/RR/structural/REGISTERREAD.md` (porting-guide style — pull design facts from it as you fill in this chapter, but write in the same tone as the per-stage REPORT_*.md files).

## 1. Overview

> **TODO:** One short paragraph. RR sits between Decode and the Dependency Check (DC) stage. Its job: read source operands from the architectural register file, run the address-generation half of the addressing-mode resolution, drive operands forward, and interact with the data-forwarding network so that back-to-back dependent instructions don't bubble.

![Register Read stage block diagram.](figures/fig_rr.png){#fig:rr width=85%}

## 2. Interesting Features

> **TODO:** Bullet list of the design choices worth calling out. Likely candidates based on the existing REGISTERREAD.md:
>
> - The register file organization (number of ports, segment register file vs. general-purpose register file)
> - The register scoreboard (`RegSB`) and how it interacts with in-flight writes
> - The address-generation unit (`npu_node1`) running in this stage
> - **Data forwarding** — one of the headline features of the design — covers values being forwarded from EXE's writeback ports back into RR's operand path

## 3. Stage Organization

> **TODO:** ASCII dataflow showing operand-id → register file read → forwarded data mux → out to DC, alongside the segment / base / index → address-generation path.

## 4. Per-Block Walkthrough

> **TODO:** One bullet per `.sv` file in the RR folder.

## 5. Interesting Features — In Depth

> **TODO:** Subsections per feature. The data-forwarding subsection should clearly explain the forwarding network — which sources are forwarded (EXE writeback ports), which destinations (RR's operand muxes), and the priority order when multiple sources are valid.

## 6. Critical Path / Timing

This arc contributes to the overall 11.2 ns clock period but was not the binding stage — the Decode stage set the cycle time.

## 7. Design Considerations and Trade-offs

> **TODO:** Bullets on the trade-offs: forwarding network depth vs. timing, register-file port count vs. area, scoreboard granularity, segment vs. GPR split.

## 8. Conclusions

> **TODO:** One paragraph wrapping up what RR delivers and recommendations for the next design.
