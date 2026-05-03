`ifndef DCACHE_REQ_2_SCH_DEFINE_VH
`define DCACHE_REQ_2_SCH_DEFINE_VH

// Backtick mirrors of the req_2_sch_t enum in rtl/pkgs/interconnect_pkg.sv.
// Width matches the SV enum: logic [3:0] (4 bits).
//
// Only the values referenced by the DCache structural logic are listed
// here. Keep encodings byte-identical with the SV enum.

`define REQ_2_SCH_WIDTH               (4)

// ICACHE
`define ICACHE_HIGH_PRI                (4'd14)
`define ICACHE_LOW_PRI_REQ             (4'd2)

// DCACHE
`define DCACHE_EB_BLOCKING_BANK        (4'd13)
`define DCACHE_EB_BLOCKING_ST_OVERRIDE (4'd12)
`define DCACHE_EB_BLOCKING_LD          (4'd11)
`define DCACHE_EB_BLOCK_ST             (4'd10)
`define DCACHE_FILL_ST_OVERRIDE        (4'd9)
`define DCACHE_FILL_LD                 (4'd8)
`define DCACHE_FILL_ST                 (4'd7)
`define DCACHE_EB_WR                   (4'd6)

// MIO / IO
`define DCACHE_MIO_LD_FROM_SIMPLE      (4'd5)
`define DCACHE_MIO_WR_COMPLEX          (4'd4)
`define DCACHE_MIO_WR_SIMPLE           (4'd3)

// DMA
`define DMA_WRITE_REQ                  (4'd1)

// No request
`define NO_REQ                         (4'd0)

`endif
