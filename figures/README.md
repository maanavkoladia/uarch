# Figures

Drop PNG / JPG images into this folder. Each chapter references one figure by filename. Missing images render as a missing-image marker but do not break `make report`.

| Chapter                       | Filename             |
|-------------------------------|----------------------|
| Introduction / Pipeline Overview (the one overall) | `fig_overall.png`    |
| Fetch                         | `fig_fetch.png`      |
| Decode                        | `fig_decode.png`     |
| Register Read                 | `fig_rr.png`         |
| Dependency Check (DC)         | `fig_dc.png`         |
| Memory (MEM)                  | `fig_mem.png`        |
| Execute (EXE)                 | `fig_exe.png`        |
| Write-Back (WB)               | `fig_wb.png`         |
| ICache                        | `fig_icache.png`     |
| DCache                        | `fig_dcache.png`     |
| Bus Arbitration               | `fig_bus_arb.png`    |
| Main Memory                   | `fig_main_mem.png`   |
| DDR5                          | `fig_ddr5.png`       |
| DMA Controller                | `fig_dma.png`        |

Recommended width: 80–90% of the text width. The figure markdown lines in each chapter already set `width=85%` — change per-figure if a particular diagram looks better wider or narrower.
