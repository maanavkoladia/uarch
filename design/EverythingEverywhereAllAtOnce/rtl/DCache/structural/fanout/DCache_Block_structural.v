// Pure Verilog 2005 port of DCache_Block.
// Reference: rtl/DCache/structural/DCache_Block.sv
// Flat-port shell over DCache_Bank, VCache, EvictionBuf (all .v structural).
// All connections between children are flat wires (no structs).
// Cache lines packed LSB-first (byte i in bits [8i+7:8i]).


module DCache_Block (
    input wire clk_i,
    input wire rst_i,                                  // active-low

    // unpacked from block_req_t block_req_i
    input wire        blockReq_oe_i,
    input wire        blockReq_we_i,
    input wire [14:0] blockReq_paddr_i,
    input wire [15:0] blockReq_vec_i,
    input wire [127:0] blockReq_stq_data_i,            // cache line, LSB-first

    // DTE flat inputs
    input wire        mem_Valid_FromDte_i,
    input wire        evictionBuf_clr_FromDTE_i,
    input wire        evictionBuf_setCommiting_FromDTE_i,
    input wire [3:0]  permissionToDriveDataBus_evictionBuf_i,
    input wire        permissionToDriveAddrBus_Ld_i,
    input wire        permissionToDriveAddrBus_eb_i,

    input wire        st_override_for_sch_req_i,

    inout wire [`DATA_BUS_WIDTH_BITS - 1 : 0]    dataBus,
    inout wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,

    // unpacked from dcache_block_outputs_t outputs_o
    output wire [127:0] outputs_dataLineOut_o,         // cache line, LSB-first
    output wire        outputs_hit_o,
    output wire [14:0] outputs_eb_addr_o,
    output wire [3:0]  outputs_req_2_sch_o
);

    // ---------------------------------------------------------------
    // Flat nets carrying child outputs (replaces struct locals)
    // ---------------------------------------------------------------
    wire        bank_hit_flat;
    wire        bank_swapBuf_valid_flat;
    wire        bank_swapBuf_dirty_flat;
    wire [14:0] bank_swapBuf_addr_flat;
    wire [127:0] bank_swapBuf_line_flat;
    wire        bank_VCache_swapBuf_valid_clr_flat;
    wire        bank_D_will_evict_flat;
    wire        bank_busy_flat;
    wire [127:0] bank_data_lineOut_flat;
    wire        bank_MakeReq_flat;
    wire        bank_eb_stalling_flat;

    wire        vcache_hit_flat;
    wire        vcache_miss_flat;
    wire        vcache_swapBuf_valid_flat;
    wire        vcache_swapBuf_dirty_flat;
    wire [14:0] vcache_swapBuf_lineAddr_flat;
    wire [127:0] vcache_swapBuf_line_flat;
    wire        vcache_D_Cache_swapBuf_valid_clr_flat;
    wire        vcache_LD_EB_flat;
    wire        vcache_busy_flat;
    wire        vcache_beingBlocked_flat;
    wire [127:0] vcache_lineOut_flat;
    wire [14:0] vcache_addrOut_flat;

    wire         eb_valid_flat;
    wire         eb_commit_flat;
    wire [14:0]  eb_addr_flat;
    wire [127:0] eb_line_flat;
    wire         eb_reqHit_flat;

    // ---------------------------------------------------------------
    // block_busy = bank.busy | vcache.busy
    // u_block_busy external fanout 162 -> bufferH256$.
    // ---------------------------------------------------------------
    wire block_busy, block_busy_pre;
    `OR_2(u_block_busy, 1, block_busy_pre, bank_busy_flat, vcache_busy_flat)
    bufferH256$ u_block_busy_buf (.out(block_busy), .in(block_busy_pre));

    // ---------------------------------------------------------------
    // DCache_Bank instance
    // ---------------------------------------------------------------
    DCache_Bank dcache_bank_unit (
        .clk(clk_i),
        .rst(rst_i),

        .vcache_miss_i                    (vcache_miss_flat),
        .vcache_DCache_swapBuf_valid_clr_i(vcache_D_Cache_swapBuf_valid_clr_flat),
        .vcache_swapBuf_dirty_i           (vcache_swapBuf_dirty_flat),
        .vcache_swapBuf_line_i            (vcache_swapBuf_line_flat),

        .eb_reqHit_i                      (eb_reqHit_flat),

        .mem_Valid_FromDte_i              (mem_Valid_FromDte_i),

        .blockReq_oe_i                    (blockReq_oe_i),
        .blockReq_we_i                    (blockReq_we_i),
        .blockReq_paddr_i                 (blockReq_paddr_i),
        .blockReq_stq_data_i              (blockReq_stq_data_i),
        .blockReq_vec_i                   (blockReq_vec_i),

        .block_busy_i                     (block_busy),
        .dataBus                          (dataBus),

        .dcacheBankOut_hit_o                      (bank_hit_flat),
        .dcacheBankOut_swapBuf_valid_o            (bank_swapBuf_valid_flat),
        .dcacheBankOut_swapBuf_dirty_o            (bank_swapBuf_dirty_flat),
        .dcacheBankOut_swapBuf_addr_o             (bank_swapBuf_addr_flat),
        .dcacheBankOut_swapBuf_line_o             (bank_swapBuf_line_flat),
        .dcacheBankOut_VCache_swapBuf_valid_clr_o (bank_VCache_swapBuf_valid_clr_flat),
        .dcacheBankOut_D_will_evict_o             (bank_D_will_evict_flat),
        .dcacheBankOut_busy_o                     (bank_busy_flat),
        .dcacheBankOut_data_lineOut_o             (bank_data_lineOut_flat),
        .dcacheBankOut_MakeReq_o                  (bank_MakeReq_flat),
        .dcacheBankOut_eb_stalling_o              (bank_eb_stalling_flat)
    );

    // ---------------------------------------------------------------
    // VCache instance
    // ---------------------------------------------------------------
    VCache vcache_unit (
        .clk(clk_i),
        .rst(rst_i),

        .blockReq_oe_i      (blockReq_oe_i),
        .blockReq_we_i      (blockReq_we_i),
        .blockReq_paddr_i   (blockReq_paddr_i),
        .blockReq_stq_data_i(blockReq_stq_data_i),
        .blockReq_vec_i     (blockReq_vec_i),

        .eb_valid_i         (eb_valid_flat),
        .eb_reqHit_i        (eb_reqHit_flat),

        .dcache_D_will_evict_i             (bank_D_will_evict_flat),
        .dcache_V_Cache_swapBuf_valid_clr_i(bank_VCache_swapBuf_valid_clr_flat),
        .dcache_swapBuf_dirty_i            (bank_swapBuf_dirty_flat),
        .dcache_swapBuf_lineAddr_i         (bank_swapBuf_addr_flat),
        .dcache_swapBuf_line_i             (bank_swapBuf_line_flat),

        .block_busy_i       (block_busy),

        .outputs_hit_o                      (vcache_hit_flat),
        .outputs_miss_o                     (vcache_miss_flat),
        .outputs_swapBuf_valid_o            (vcache_swapBuf_valid_flat),
        .outputs_swapBuf_dirty_o            (vcache_swapBuf_dirty_flat),
        .outputs_swapBuf_lineAddr_o         (vcache_swapBuf_lineAddr_flat),
        .outputs_swapBuf_line_o             (vcache_swapBuf_line_flat),
        .outputs_D_Cache_swapBuf_valid_clr_o(vcache_D_Cache_swapBuf_valid_clr_flat),
        .outputs_LD_EB_o                    (vcache_LD_EB_flat),
        .outputs_busy_o                     (vcache_busy_flat),
        .outputs_beingBlocked_o             (vcache_beingBlocked_flat),
        .outputs_lineOut_o                  (vcache_lineOut_flat),
        .outputs_addrOut_o                  (vcache_addrOut_flat)
    );

    // ---------------------------------------------------------------
    // EvictionBuf instance
    // ---------------------------------------------------------------
    EvictionBuf evictionBuf_unit (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .eb_clr_i(evictionBuf_clr_FromDTE_i),
        .set_commiting_i(evictionBuf_setCommiting_FromDTE_i),
        .blockReq_oe_i(blockReq_oe_i),
        .blockReq_we_i(blockReq_we_i),
        .blockReq_paddr_i(blockReq_paddr_i),
        .vcache_LD_EB_i(vcache_LD_EB_flat),
        .vcache_addrOut_i(vcache_addrOut_flat),
        .vcache_lineOut_i(vcache_lineOut_flat),
        .ebOut_valid_o(eb_valid_flat),
        .ebOut_commiting_o(eb_commit_flat),
        .ebOut_addr_o(eb_addr_flat),
        .ebOut_lineOut_o(eb_line_flat),
        .ebOut_reqHit_o(eb_reqHit_flat)
    );

    // ---------------------------------------------------------------
    // dataLineOut: 4:1 mux on {bank_hit, vcache_hit}
    // sel=00: bank, sel=01: vcache, sel=10: bank, sel=11: 0
    // ---------------------------------------------------------------
    wire [1:0]   datasel;
    assign datasel = {bank_hit_flat, vcache_hit_flat};
    wire [127:0] dataLineOut_flat;

    `MUX_4(u_dataLineOut_mux, 128, dataLineOut_flat,
        bank_data_lineOut_flat,
        vcache_lineOut_flat,
        bank_data_lineOut_flat,
        128'b0,
        datasel)

    assign outputs_dataLineOut_o = dataLineOut_flat;

    // ---------------------------------------------------------------
    // hit_o = bank.hit | vcache.hit
    // ---------------------------------------------------------------
    wire hit_o_w;
    `OR_2(u_hit_o, 1, hit_o_w, bank_hit_flat, vcache_hit_flat)
    assign outputs_hit_o = hit_o_w;

    assign outputs_eb_addr_o = eb_addr_flat;

    // ---------------------------------------------------------------
    // req_2_sch priority encoder
    //   Top priority: EB_BLOCKING_BANK > vcache-blocking subreq
    //                > fill subreq > EB_WR.
    // ---------------------------------------------------------------
    wire makeBlockReq, eb_blockingVCache, eb_V, eb_curr_commiting, eb_blocking_Bank;
    assign makeBlockReq      = bank_MakeReq_flat;
    assign eb_blockingVCache = vcache_beingBlocked_flat;
    assign eb_V              = eb_valid_flat;
    assign eb_curr_commiting = eb_commit_flat;
    assign eb_blocking_Bank  = bank_eb_stalling_flat;

    wire not_committing;
    `INV_N(u_not_committing, 1, eb_curr_commiting, not_committing)

    wire cond_blocking_bank;
    wire cond_blocking_vcache;
    wire cond_eb_wr;
    `AND_2(u_cond_block_bank,   1, cond_blocking_bank,   eb_blocking_Bank,   not_committing)
    `AND_2(u_cond_block_vcache, 1, cond_blocking_vcache, eb_blockingVCache,  not_committing)
    `AND_2(u_cond_eb_wr,        1, cond_eb_wr,           eb_V,               not_committing)

    // Inner-A: vcache-blocking subreq
    wire [3:0] innerA_we_or_zero;
    wire [3:0] innerA_oe_we_zero;
    wire [3:0] innerA_full;
    `MUX_2(u_innerA_a, 4, innerA_we_or_zero,
        `NO_REQ, `DCACHE_EB_BLOCK_ST, blockReq_we_i)
    `MUX_2(u_innerA_b, 4, innerA_oe_we_zero,
        innerA_we_or_zero, `DCACHE_EB_BLOCKING_LD, blockReq_oe_i)
    `MUX_2(u_innerA_c, 4, innerA_full,
        innerA_oe_we_zero, `DCACHE_EB_BLOCKING_ST_OVERRIDE, st_override_for_sch_req_i)

    // Inner-B: fill subreq
    wire [3:0] innerB_we_or_zero;
    wire [3:0] innerB_oe_we_zero;
    wire [3:0] innerB_full;
    `MUX_2(u_innerB_a, 4, innerB_we_or_zero,
        `NO_REQ, `DCACHE_FILL_ST, blockReq_we_i)
    `MUX_2(u_innerB_b, 4, innerB_oe_we_zero,
        innerB_we_or_zero, `DCACHE_FILL_LD, blockReq_oe_i)
    `MUX_2(u_innerB_c, 4, innerB_full,
        innerB_oe_we_zero, `DCACHE_FILL_ST_OVERRIDE, st_override_for_sch_req_i)

    // Top-level priority chain
    wire [3:0] req_step1;
    wire [3:0] req_step2;
    wire [3:0] req_step3;
    wire [3:0] req_2_sch_w;
    `MUX_2(u_top_step1, 4, req_step1,    `NO_REQ,    `DCACHE_EB_WR,            cond_eb_wr)
    `MUX_2(u_top_step2, 4, req_step2,    req_step1, innerB_full,               makeBlockReq)
    `MUX_2(u_top_step3, 4, req_step3,    req_step2, innerA_full,               cond_blocking_vcache)
    `MUX_2(u_top_step4, 4, req_2_sch_w,  req_step3, `DCACHE_EB_BLOCKING_BANK,  cond_blocking_bank)

    assign outputs_req_2_sch_o = req_2_sch_w;

    // ---------------------------------------------------------------
    // Address bus driver
    // 15-bit address mux: Ld=1 -> blockReq.p_addr, else -> eb.addr.
    // ---------------------------------------------------------------
    wire [14:0] addr_bus_fake15;
    `MUX_2(u_addr_bus_mux, 15, addr_bus_fake15,
        eb_addr_flat,
        blockReq_paddr_i,
        permissionToDriveAddrBus_Ld_i)

    wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake;
    assign address_bus_fake = {17'b0, addr_bus_fake15};

    // u_addr_drive_en external fanout 32 -> bufferH64$.
    wire addr_drive_enbar, addr_drive_enbar_pre;
    `NOR_2(u_addr_drive_en, 1, addr_drive_enbar_pre,
        permissionToDriveAddrBus_Ld_i, permissionToDriveAddrBus_eb_i)
    bufferH64$ u_addr_drive_en_buf (.out(addr_drive_enbar), .in(addr_drive_enbar_pre));

    `BUS_TRISTATE(u_addr_bus_tri, `ADDRESS_BUS_WIDTH_BITS,
        addr_drive_enbar, address_bus_fake, address_bus)

    // ---------------------------------------------------------------
    // Data bus driver: per-32-bit-word eviction-buf line slices
    // ---------------------------------------------------------------
    // u_perm_inv external fanout 32 per bit -> bufferH64$ per bit.
    wire [3:0] perm2DriveDataBus_bar;
    wire [3:0] perm2DriveDataBus_bar_pre;
    `INV_N(u_perm_inv, 4, permissionToDriveDataBus_evictionBuf_i, perm2DriveDataBus_bar_pre)
    bufferH64$ u_perm_bar_buf_0 (.out(perm2DriveDataBus_bar[0]), .in(perm2DriveDataBus_bar_pre[0]));
    bufferH64$ u_perm_bar_buf_1 (.out(perm2DriveDataBus_bar[1]), .in(perm2DriveDataBus_bar_pre[1]));
    bufferH64$ u_perm_bar_buf_2 (.out(perm2DriveDataBus_bar[2]), .in(perm2DriveDataBus_bar_pre[2]));
    bufferH64$ u_perm_bar_buf_3 (.out(perm2DriveDataBus_bar[3]), .in(perm2DriveDataBus_bar_pre[3]));

    `BUS_TRISTATE(memBus_tri_0, 32, perm2DriveDataBus_bar[0], eb_line_flat[31:0],   dataBus)
    `BUS_TRISTATE(memBus_tri_1, 32, perm2DriveDataBus_bar[1], eb_line_flat[63:32],  dataBus)
    `BUS_TRISTATE(memBus_tri_2, 32, perm2DriveDataBus_bar[2], eb_line_flat[95:64],  dataBus)
    `BUS_TRISTATE(memBus_tri_3, 32, perm2DriveDataBus_bar[3], eb_line_flat[127:96], dataBus)

endmodule
