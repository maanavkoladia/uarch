// ----------------------------------------------------------------
// npu_node2 -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/npu_node2.sv
//
// Drives two TLB lookups (start address + next-page address) and
// produces the load/store physical addresses + cross-page / xcl flags.
//
// Constants used (hardcoded with a comment to avoid SV imports):
//   VPN_LB              = 12   ($clog2(PAGE_SIZE=4096))
//   PHY_MEM_SIZE_LOG2   = 15   (p_address_t is 15 bits)
//   DCACHE_BANK_INDEX_*: [8:6]  (3-bit cache-line index)
//   DCACHE_BANK_BANK_*:  [5:4]  (2-bit cache-line bank)
//
// vaddy_end = vaddy_start + offset(datasize)
//   datasize  offset
//     2'b00     0
//     2'b01     1
//     2'b10     3
//     2'b11     7
//   -> single MUX_4 + ADD_N (avoids 4 separate adders).
//
// cross_page = vaddy_start[12] ^ vaddy_end[12]
// bank_hi    = (vaddy_start[8:6] != vaddy_end[8:6])           // index_eq inverted
// xcl        = (vaddy_start[4]   ^ vaddy_end[4]) & mem_op
//
// PADDR0 = tlb0.physical_addr
// PADDR1 = cross_page ? {tlb1.physical_addr[14:4], 4'b0}
//                     : {tlb0.physical_addr[14:12], vaddy_end[11:0]}
//
// DC_PF       = (tlb0.pageFault | (cross_page & tlb1.pageFault)) & ~stack_access
// DC_GP       = (tlb0.gp_exp    | (cross_page & tlb1.gp_exp))    & ~stack_access
// valid_mem_op = tlb0.physical_addr_valid
//                & (cross_page ? tlb1.physical_addr_valid : tlb0.physical_addr_valid)
//                & mem_op
// mio         = tlb0.MIO
//
// TLB instances use the new TLB_structural.v interface (flat ports).
// ----------------------------------------------------------------

module npu_node2 (
    input  wire [31:0] vaddy_start,
    input  wire [1:0]  datasize,
    input  wire        write_intent,
    input  wire        mem_op,
    input  wire [31:0] next_page_vaddy,
    input  wire        stack_access,

    output wire        DC_PF,
    output wire        DC_GP,
    output wire        valid_mem_op,
    output wire [14:0] PADDR1,
    output wire        bank_hi,
    output wire        xcl,
    output wire [14:0] PADDR0,
    output wire        mio
);

    // ----------------------------------------------------------------
    // vaddy_end = vaddy_start + offset (offset depends on datasize)
    //   datasize  offset
    //     00       0
    //     01       1
    //     10       3
    //     11       7
    //
    // Only vaddy_end[12:0] is consumed (cross_page bit 12, index_eq
    // bits [8:6], bank0_xor bit 4, paddr1_same[11:0]).  Bits [13:31]
    // were dead in the 32-bit ADD_N -- shrunk to 13 bits to drop one
    // Kogge-Stone stage (log2(13)=4 vs log2(32)=5) on the CP path
    // through cross_page -> u_paddr1 -> PADDR1 -> dep_check -> req_gen.
    // ----------------------------------------------------------------
    wire [12:0] end_offset;
    `MUX_4(u_end_offset, 13, end_offset,
           13'd0, 13'd1, 13'd3, 13'd7, datasize)

    wire [12:0] vaddy_end;
    wire        vaddy_end_cout;          // unused
    `ADD_N(u_vaddy_end, 13, vaddy_end, vaddy_end_cout,
           vaddy_start[12:0], end_offset, 1'b0)

    // ----------------------------------------------------------------
    // cross_page = vaddy_start[12] ^ vaddy_end[12]
    //
    // Logic-duplicated into a CP copy (drives the 15-bit u_paddr1 MUX_2
    // select on the PADDR1 -> req_gen path) and an aux copy (drives the
    // 3 off-CP loads: tlb1 PF/GP gates and the valid_mem_op tlb-select
    // mux). Both XOR_2 cells take identical inputs, so the CP wire sees
    // fanout 15 (under bufferH16$ threshold) and the aux wire sees
    // fanout 3 -- both within rated load. Zero added CP delay.
    // ----------------------------------------------------------------
    // cross_page_cp drives the 15-bit u_paddr1 MUX_2 select line (15 loads).
    // xor2$ rated load is well under that, so we buffer through bufferH16$.
    // ~0.24 ns added on the PADDR1 path; absorbed by the B+D upstream slack.
    wire cross_page_cp_raw;
    wire cross_page_cp;
    wire cross_page_aux;
    `XOR_2(u_cross_page_cp,  1, cross_page_cp_raw,
           vaddy_start[12], vaddy_end[12])
    bufferH16$ u_cross_page_cp_buf (.out(cross_page_cp),
                                    .in(cross_page_cp_raw));
    `XOR_2(u_cross_page_aux, 1, cross_page_aux,
           vaddy_start[12], vaddy_end[12])

    // ----------------------------------------------------------------
    // bank_hi = (vaddy_start[8:6] != vaddy_end[8:6])
    // ----------------------------------------------------------------
    wire index_eq;
    `CMP_N(u_index_eq, 3, index_eq,
           vaddy_start[`DCACHE_BANK_INDEX_UB:`DCACHE_BANK_INDEX_LB],
           vaddy_end  [`DCACHE_BANK_INDEX_UB:`DCACHE_BANK_INDEX_LB])
    `INV_N(u_bank_hi, 1, index_eq, bank_hi)

    // ----------------------------------------------------------------
    // xcl = (vaddy_start[4] ^ vaddy_end[4]) & mem_op
    // ----------------------------------------------------------------
    wire bank0_xor;
    `XOR_2(u_bank0_xor, 1, bank0_xor,
           vaddy_start[`DCACHE_BANK_BANK_LB], vaddy_end[`DCACHE_BANK_BANK_LB])
    // fanout: redirect u_xcl AND_2 output to staging wire, attach bufferH16$
    wire xcl_pre_buf;
    `AND_2(u_xcl, 1, xcl_pre_buf, bank0_xor, mem_op)
    bufferH16$ u_attach_xcl (.out(xcl), .in(xcl_pre_buf));

    // ----------------------------------------------------------------
    // TLB instances (new flat-port TLB_structural.v interface)
    // ----------------------------------------------------------------
    wire [14:0] tlb0_physical_addr;
    wire        tlb0_physical_addr_valid;
    wire        tlb0_gp_exp;
    wire        tlb0_pageFault;
    wire        tlb0_MIO;

    wire [14:0] tlb1_physical_addr;
    wire        tlb1_physical_addr_valid;
    wire        tlb1_gp_exp;
    wire        tlb1_pageFault;
    wire        tlb1_MIO;

    TLB tlb0 (
        .virtual_addr        (vaddy_start),
        .write_intention     (write_intent),
        .physical_addr       (tlb0_physical_addr),
        .physical_addr_valid (tlb0_physical_addr_valid),
        .gp_exp              (tlb0_gp_exp),
        .pageFault           (tlb0_pageFault),
        .MIO                 (tlb0_MIO)
    );

    TLB tlb1 (
        .virtual_addr        (next_page_vaddy),
        .write_intention     (write_intent),
        .physical_addr       (tlb1_physical_addr),
        .physical_addr_valid (tlb1_physical_addr_valid),
        .gp_exp              (tlb1_gp_exp),
        .pageFault           (tlb1_pageFault),
        .MIO                 (tlb1_MIO)
    );

    // ----------------------------------------------------------------
    // PADDR0 / PADDR1 / mio (direct or near-direct from TLB)
    // ----------------------------------------------------------------
    assign PADDR0 = tlb0_physical_addr;
    assign mio    = tlb0_MIO;

    // PADDR1 mux:
    //   cross_page=1 : {tlb1_physical_addr[14:4], 4'b0000}
    //   cross_page=0 : {tlb0_physical_addr[14:12], vaddy_end[11:0]}
    wire [14:0] paddr1_cross;
    wire [14:0] paddr1_same;
    assign paddr1_cross = {tlb1_physical_addr[14:4], 4'b0000};
    assign paddr1_same  = {tlb0_physical_addr[14:12], vaddy_end[11:0]};
    // fanout: redirect u_paddr1 MUX_2 output to staging bus, attach per-bit buffers
    // 9 bits via bufferH16$, 2 bits ([5:4] bank-bank) via bufferH256$, 4 bits passthrough
    wire [14:0] PADDR1_pre_buf;
    `MUX_2(u_paddr1, 15, PADDR1_pre_buf, paddr1_same, paddr1_cross, cross_page_cp)
    assign PADDR1[14:12] = PADDR1_pre_buf[14:12];
    assign PADDR1[0]     = PADDR1_pre_buf[0];
    bufferH16$  u_attach_PADDR1_b11 (.out(PADDR1[11]), .in(PADDR1_pre_buf[11]));
    bufferH16$  u_attach_PADDR1_b10 (.out(PADDR1[10]), .in(PADDR1_pre_buf[10]));
    bufferH16$  u_attach_PADDR1_b9  (.out(PADDR1[9]),  .in(PADDR1_pre_buf[9]));
    bufferH16$  u_attach_PADDR1_b8  (.out(PADDR1[8]),  .in(PADDR1_pre_buf[8]));
    bufferH16$  u_attach_PADDR1_b7  (.out(PADDR1[7]),  .in(PADDR1_pre_buf[7]));
    bufferH16$  u_attach_PADDR1_b6  (.out(PADDR1[6]),  .in(PADDR1_pre_buf[6]));
    bufferH256$ u_attach_PADDR1_b5  (.out(PADDR1[5]),  .in(PADDR1_pre_buf[5]));
    bufferH256$ u_attach_PADDR1_b4  (.out(PADDR1[4]),  .in(PADDR1_pre_buf[4]));
    bufferH16$  u_attach_PADDR1_b3  (.out(PADDR1[3]),  .in(PADDR1_pre_buf[3]));
    bufferH16$  u_attach_PADDR1_b2  (.out(PADDR1[2]),  .in(PADDR1_pre_buf[2]));
    bufferH16$  u_attach_PADDR1_b1  (.out(PADDR1[1]),  .in(PADDR1_pre_buf[1]));

    // ----------------------------------------------------------------
    // DC_PF / DC_GP -- gate per-stage page-fault/gp by cross_page (for
    // tlb1) and by ~stack_access (for both), as per the .sv reference.
    // ----------------------------------------------------------------
    wire not_stack_access;
    `INV_N(u_inv_stack, 1, stack_access, not_stack_access)

    // tlb0 gates: simple AND with ~stack_access
    wire tlb0_pagefault_g;
    wire tlb0_gp_g;
    `AND_2(u_tlb0_pf_g, 1, tlb0_pagefault_g, tlb0_pageFault, not_stack_access)
    `AND_2(u_tlb0_gp_g, 1, tlb0_gp_g,        tlb0_gp_exp,    not_stack_access)

    // tlb1 gates: AND with cross_page AND ~stack_access
    wire tlb1_pagefault_g;
    wire tlb1_gp_g;
    `AND_3(u_tlb1_pf_g, 1, tlb1_pagefault_g,
           tlb1_pageFault, cross_page_aux, not_stack_access)
    `AND_3(u_tlb1_gp_g, 1, tlb1_gp_g,
           tlb1_gp_exp,    cross_page_aux, not_stack_access)

    `OR_2(u_dc_pf, 1, DC_PF, tlb0_pagefault_g, tlb1_pagefault_g)
    `OR_2(u_dc_gp, 1, DC_GP, tlb0_gp_g,        tlb1_gp_g)

    // ----------------------------------------------------------------
    // valid_mem_op = tlb0_pa_valid
    //              & (cross_page ? tlb1_pa_valid : tlb0_pa_valid)
    //              & mem_op
    // ----------------------------------------------------------------
    wire selected_tlb_valid;
    `MUX_2(u_sel_tlb_valid, 1, selected_tlb_valid,
           tlb0_physical_addr_valid, tlb1_physical_addr_valid, cross_page_aux)

    `AND_3(u_valid_mem_op, 1, valid_mem_op,
           tlb0_physical_addr_valid, selected_tlb_valid, mem_op)

endmodule
