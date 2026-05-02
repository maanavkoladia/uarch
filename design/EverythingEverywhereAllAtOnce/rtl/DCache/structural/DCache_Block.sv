import common_pkg::*;
import interconnect_pkg::*;
import DCache_common_pkg::*;

`define USE_STRUCTURAL_EB
`define USE_STRUCTURAL_BANK
`define USE_STRUCTURAL_VCACHE
module DCache_Block (
    input wire clk_i,
    input wire rst_i,  //active low

    //from dcahce arb
    input block_req_t block_req_i,

    //DTE input
    input wire mem_Valid_FromDte_i,
    input wire evictionBuf_clr_FromDTE_i,
    input wire evictionBuf_setCommiting_FromDTE_i,
    input wire permissionToDriveDataBus_evictionBuf[CACHE_LINES_SIZE_BITS/DATA_BUS_WIDTH_BITS],
    input wire permissionToDriveAddrBus_Ld,
    input wire permissionToDriveAddrBus_eb,

    //for sceduling
    input wire st_override_for_sch_req,

    //
    inout wire [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus,
    inout wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus,

    // output byte_t dataLineOut[CACHE_LINES_SIZE_B],
    // output bool   hit_o,
    // i dont think miss is needed, bc its not going to sch, dte, or MEM/wb
    // output bool miss,

    // output byte_t eb_V_o,
    // output p_address_t eb_addr,
    // output byte_t eb_line_O[CACHE_LINES_SIZE_B],

    // output dcache_req_types_2_scheduler_e req_2_sch,

    output dcache_block_outputs_t outputs_o

);


    d_cache_bank_outputs_t dcache_bank_outputs;
    v_cache_outputs_t vcache_outputs;
    eb_outputs_t eb_outputs;

    wire block_busy;
    // SV line 51: block_busy = bank.busy || vcache.busy
    `OR_2(u_block_busy, 1, block_busy, dcache_bank_outputs.busy, vcache_outputs.busy);

    // ---------------------------------------------------------------
    // DCache_Bank instance — swappable between SV reference and
    // structural Verilog 2005 port via `ifdef USE_STRUCTURAL_BANK.
    // Define the flag in structural/DCache_TOP.sv to enable the
    // structural path. Default (flag undefined) preserves SV behavior.
    // ---------------------------------------------------------------
`ifdef USE_STRUCTURAL_BANK
        initial $display("using STRUCTURAL bank");
        // ---- struct -> flat: pack byte arrays into 128-bit buses ----
        wire [127:0] bank_blockReq_stq_data_flat;
        wire [127:0] bank_vcache_swapBuf_line_flat;
        assign bank_blockReq_stq_data_flat = {
            block_req_i.st_q_data[15], block_req_i.st_q_data[14],
            block_req_i.st_q_data[13], block_req_i.st_q_data[12],
            block_req_i.st_q_data[11], block_req_i.st_q_data[10],
            block_req_i.st_q_data[9],  block_req_i.st_q_data[8],
            block_req_i.st_q_data[7],  block_req_i.st_q_data[6],
            block_req_i.st_q_data[5],  block_req_i.st_q_data[4],
            block_req_i.st_q_data[3],  block_req_i.st_q_data[2],
            block_req_i.st_q_data[1],  block_req_i.st_q_data[0]
        };
        assign bank_vcache_swapBuf_line_flat = {
            vcache_outputs.vcache_swapBuf.line[15], vcache_outputs.vcache_swapBuf.line[14],
            vcache_outputs.vcache_swapBuf.line[13], vcache_outputs.vcache_swapBuf.line[12],
            vcache_outputs.vcache_swapBuf.line[11], vcache_outputs.vcache_swapBuf.line[10],
            vcache_outputs.vcache_swapBuf.line[9],  vcache_outputs.vcache_swapBuf.line[8],
            vcache_outputs.vcache_swapBuf.line[7],  vcache_outputs.vcache_swapBuf.line[6],
            vcache_outputs.vcache_swapBuf.line[5],  vcache_outputs.vcache_swapBuf.line[4],
            vcache_outputs.vcache_swapBuf.line[3],  vcache_outputs.vcache_swapBuf.line[2],
            vcache_outputs.vcache_swapBuf.line[1],  vcache_outputs.vcache_swapBuf.line[0]
        };

        // ---- flat output nets from the structural bank ----
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

        DCache_Bank dcache_bank_unit (
            .clk(clk_i),
            .rst(rst_i),                                              // active-low

            .vcache_miss_i                    (vcache_outputs.miss),
            .vcache_DCache_swapBuf_valid_clr_i(vcache_outputs.D_Cache_swapBuf_valid_clr),
            .vcache_swapBuf_dirty_i           (vcache_outputs.vcache_swapBuf.dirty),
            .vcache_swapBuf_line_i            (bank_vcache_swapBuf_line_flat),

            .eb_reqHit_i                      (eb_outputs.reqHit),

            .mem_Valid_FromDte_i              (mem_Valid_FromDte_i),

            .blockReq_oe_i                    (block_req_i.oe),
            .blockReq_we_i                    (block_req_i.we),
            .blockReq_paddr_i                 (block_req_i.p_addr),
            .blockReq_stq_data_i              (bank_blockReq_stq_data_flat),
            .blockReq_vec_i                   (block_req_i.vec),

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

        // ---- flat -> struct: repack into dcache_bank_outputs ----
        assign dcache_bank_outputs.hit                      = bank_hit_flat;
        assign dcache_bank_outputs.dcache_swapBuf.valid     = bank_swapBuf_valid_flat;
        assign dcache_bank_outputs.dcache_swapBuf.dirty     = bank_swapBuf_dirty_flat;
        assign dcache_bank_outputs.dcache_swapBuf.lineAddr  = bank_swapBuf_addr_flat;
        assign dcache_bank_outputs.V_Cache_swapBuf_valid_clr= bank_VCache_swapBuf_valid_clr_flat;
        assign dcache_bank_outputs.D_will_evict             = bank_D_will_evict_flat;
        assign dcache_bank_outputs.busy                     = bank_busy_flat;
        assign dcache_bank_outputs.MakeReq                  = bank_MakeReq_flat;
        assign dcache_bank_outputs.eb_stalling              = bank_eb_stalling_flat;
        genvar gi_bank;
        generate
            for (gi_bank = 0; gi_bank < CACHE_LINES_SIZE_B; gi_bank++) begin : g_bank_line_unpack
                assign dcache_bank_outputs.data_lineOut[gi_bank] =
                    bank_data_lineOut_flat[8*gi_bank +: 8];
                assign dcache_bank_outputs.dcache_swapBuf.line[gi_bank] =
                    bank_swapBuf_line_flat[8*gi_bank +: 8];
            end
        endgenerate
`else
        initial $display("using SYSTEM bank");

        DCache_Bank dcache_bank_unit (
            .clk(clk_i),
            .rst(rst_i),
            .V_Cache_i(vcache_outputs),
            .eb_i(eb_outputs),
            .mem_Valid_FromDte_i(mem_Valid_FromDte_i),
            .blockReq_i(block_req_i),
            .block_busy_i(block_busy),
            .dataBus(dataBus),
            .outputs_o(dcache_bank_outputs)
        );
`endif

    // ---------------------------------------------------------------
    // VCache instance — swappable between SV reference and structural
    // Verilog 2005 port via `ifdef USE_STRUCTURAL_VCACHE.
    // Default (flag undefined) preserves SV behavior.
    // ---------------------------------------------------------------
`ifdef USE_STRUCTURAL_VCACHE
        initial $display("using STRUCTURAL VCACHE");

        // ---- struct -> flat: pack byte arrays into 128-bit buses ----
        wire [127:0] vcache_blockReq_stq_data_flat;
        wire [127:0] vcache_dcache_swapBuf_line_flat;
        assign vcache_blockReq_stq_data_flat = {
            block_req_i.st_q_data[15], block_req_i.st_q_data[14],
            block_req_i.st_q_data[13], block_req_i.st_q_data[12],
            block_req_i.st_q_data[11], block_req_i.st_q_data[10],
            block_req_i.st_q_data[9],  block_req_i.st_q_data[8],
            block_req_i.st_q_data[7],  block_req_i.st_q_data[6],
            block_req_i.st_q_data[5],  block_req_i.st_q_data[4],
            block_req_i.st_q_data[3],  block_req_i.st_q_data[2],
            block_req_i.st_q_data[1],  block_req_i.st_q_data[0]
        };
        assign vcache_dcache_swapBuf_line_flat = {
            dcache_bank_outputs.dcache_swapBuf.line[15],
            dcache_bank_outputs.dcache_swapBuf.line[14],
            dcache_bank_outputs.dcache_swapBuf.line[13],
            dcache_bank_outputs.dcache_swapBuf.line[12],
            dcache_bank_outputs.dcache_swapBuf.line[11],
            dcache_bank_outputs.dcache_swapBuf.line[10],
            dcache_bank_outputs.dcache_swapBuf.line[9],
            dcache_bank_outputs.dcache_swapBuf.line[8],
            dcache_bank_outputs.dcache_swapBuf.line[7],
            dcache_bank_outputs.dcache_swapBuf.line[6],
            dcache_bank_outputs.dcache_swapBuf.line[5],
            dcache_bank_outputs.dcache_swapBuf.line[4],
            dcache_bank_outputs.dcache_swapBuf.line[3],
            dcache_bank_outputs.dcache_swapBuf.line[2],
            dcache_bank_outputs.dcache_swapBuf.line[1],
            dcache_bank_outputs.dcache_swapBuf.line[0]
        };

        // ---- flat output nets from the structural VCache ----
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

        VCache vcache_unit (
            .clk(clk_i),
            .rst(rst_i),                                              // active-low

            .blockReq_oe_i      (block_req_i.oe),
            .blockReq_we_i      (block_req_i.we),
            .blockReq_paddr_i   (block_req_i.p_addr),
            .blockReq_stq_data_i(vcache_blockReq_stq_data_flat),
            .blockReq_vec_i     (block_req_i.vec),

            .eb_valid_i         (eb_outputs.valid),
            .eb_reqHit_i        (eb_outputs.reqHit),

            .dcache_D_will_evict_i             (dcache_bank_outputs.D_will_evict),
            .dcache_V_Cache_swapBuf_valid_clr_i(dcache_bank_outputs.V_Cache_swapBuf_valid_clr),
            .dcache_swapBuf_dirty_i            (dcache_bank_outputs.dcache_swapBuf.dirty),
            .dcache_swapBuf_lineAddr_i         (dcache_bank_outputs.dcache_swapBuf.lineAddr),
            .dcache_swapBuf_line_i             (vcache_dcache_swapBuf_line_flat),

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

        // ---- flat -> struct: repack into vcache_outputs ----
        assign vcache_outputs.hit                       = vcache_hit_flat;
        assign vcache_outputs.miss                      = vcache_miss_flat;
        assign vcache_outputs.vcache_swapBuf.valid      = vcache_swapBuf_valid_flat;
        assign vcache_outputs.vcache_swapBuf.dirty      = vcache_swapBuf_dirty_flat;
        assign vcache_outputs.vcache_swapBuf.lineAddr   = vcache_swapBuf_lineAddr_flat;
        assign vcache_outputs.D_Cache_swapBuf_valid_clr = vcache_D_Cache_swapBuf_valid_clr_flat;
        assign vcache_outputs.LD_EB                     = vcache_LD_EB_flat;
        assign vcache_outputs.busy                      = vcache_busy_flat;
        assign vcache_outputs.beingBlocked              = vcache_beingBlocked_flat;
        assign vcache_outputs.addrOut                   = vcache_addrOut_flat;
        genvar gi_vc;
        generate
            for (gi_vc = 0; gi_vc < CACHE_LINES_SIZE_B; gi_vc++) begin : g_vcache_line_unpack
                assign vcache_outputs.lineOut[gi_vc] =
                    vcache_lineOut_flat[8*gi_vc +: 8];
                assign vcache_outputs.vcache_swapBuf.line[gi_vc] =
                    vcache_swapBuf_line_flat[8*gi_vc +: 8];
            end
        endgenerate
`else
        initial $display("using SYSTEM vcache");

        VCache vcache_unit (
            .clk(clk_i),
            .rst(rst_i),  //active low
            .blockReq_i(block_req_i),
            .block_busy_i(block_busy),
            .eb_outs_i(eb_outputs),
            .dcache_outs_i(dcache_bank_outputs),
            .outputs_o(vcache_outputs)
        );
`endif

    // ---------------------------------------------------------------
    // EvictionBuf instance — swappable between SV reference and structural
    // Verilog 2005 port via `ifdef USE_STRUCTURAL_EB. Define the flag in
    // structural/DCache_TOP.sv (or pass via build) to enable the structural
    // path. Default (flag undefined) preserves the original SV behavior.
    // ---------------------------------------------------------------
`ifdef USE_STRUCTURAL_EB
        initial $display("using STRUCTURAL EB");

        // Pack vcache_outputs.lineOut[16] (byte_t array, LSB-first) into a flat 128-bit bus.
        wire [127:0] eb_vc_line_flat;
        assign eb_vc_line_flat = {
            vcache_outputs.lineOut[15],
            vcache_outputs.lineOut[14],
            vcache_outputs.lineOut[13],
            vcache_outputs.lineOut[12],
            vcache_outputs.lineOut[11],
            vcache_outputs.lineOut[10],
            vcache_outputs.lineOut[9],
            vcache_outputs.lineOut[8],
            vcache_outputs.lineOut[7],
            vcache_outputs.lineOut[6],
            vcache_outputs.lineOut[5],
            vcache_outputs.lineOut[4],
            vcache_outputs.lineOut[3],
            vcache_outputs.lineOut[2],
            vcache_outputs.lineOut[1],
            vcache_outputs.lineOut[0]
        };

        // Flat output nets from the structural EB
        wire         eb_valid_flat;
        wire         eb_commit_flat;
        wire [14:0]  eb_addr_flat;
        wire [127:0] eb_line_flat;
        wire         eb_reqHit_flat;

        EvictionBuf evictionBuf_unit (
            .clk_i(clk_i),
            .rst_i(rst_i),                                     // active-low
            .eb_clr_i(evictionBuf_clr_FromDTE_i),
            .set_commiting_i(evictionBuf_setCommiting_FromDTE_i),
            .blockReq_oe_i(block_req_i.oe),
            .blockReq_we_i(block_req_i.we),
            .blockReq_paddr_i(block_req_i.p_addr),
            .vcache_LD_EB_i(vcache_outputs.LD_EB),
            .vcache_addrOut_i(vcache_outputs.addrOut),
            .vcache_lineOut_i(eb_vc_line_flat),
            .ebOut_valid_o(eb_valid_flat),
            .ebOut_commiting_o(eb_commit_flat),
            .ebOut_addr_o(eb_addr_flat),
            .ebOut_lineOut_o(eb_line_flat),
            .ebOut_reqHit_o(eb_reqHit_flat)
        );

        // Repack flat outputs back into the eb_outputs struct so all
        // downstream consumers (VCache.eb_outs_i, DCache_Bank.eb_i,
        // tristate drivers, req_2_sch logic) keep working unchanged.
        assign eb_outputs.valid     = eb_valid_flat;
        assign eb_outputs.commiting = eb_commit_flat;
        assign eb_outputs.addr      = eb_addr_flat;
        assign eb_outputs.reqHit    = eb_reqHit_flat;
        genvar gi_eb;
        generate
            for (gi_eb = 0; gi_eb < CACHE_LINES_SIZE_B; gi_eb++) begin : g_eb_line_unpack
                assign eb_outputs.lineOut[gi_eb] = eb_line_flat[8*gi_eb +: 8];
            end
        endgenerate
`else
        initial $display("using SYSTEM EB");

        EvictionBuf evictionBuf_unit (
            .clk_i(clk_i),
            .rst_i(rst_i),  //active low
            .eb_clr_i(evictionBuf_clr_FromDTE_i),
            .set_commiting(evictionBuf_setCommiting_FromDTE_i),
            .vcache_outputs_i(vcache_outputs),
            .blockReq_i(block_req_i),
            .outputs_o(eb_outputs)
        );
`endif

    // SV lines 362-386: 4:1 mux on {bank_hit, vcache_hit}. The SV body
    // initializes dataLineOut to 0 then case-overrides for 00/01/10;
    // case 11 falls into default (only sets `fatal_coming`, dataLineOut
    // stays 0). The `fatal_coming` flop is dropped because the always_ff
    // body is fully commented out (no observable effect).
    wire [127:0] bank_lineOut_packed;
    wire [127:0] vcache_lineOut_packed;
    genvar gi_dl;
    generate
        for (gi_dl = 0; gi_dl < CACHE_LINES_SIZE_B; gi_dl++) begin : g_dataLineOut_pack
            assign bank_lineOut_packed[8*gi_dl +: 8]   = dcache_bank_outputs.data_lineOut[gi_dl];
            assign vcache_lineOut_packed[8*gi_dl +: 8] = vcache_outputs.lineOut[gi_dl];
        end
    endgenerate

    wire [1:0]   datasel;
    assign datasel = {dcache_bank_outputs.hit, vcache_outputs.hit};
    wire [127:0] dataLineOut_flat;

    // in0 (sel=00) = bank, in1 (sel=01) = vcache, in2 (sel=10) = bank,
    // in3 (sel=11) = 0 (matches SV init value when default branch hits).
    `MUX_4(u_dataLineOut_mux, 128, dataLineOut_flat,
        bank_lineOut_packed,
        vcache_lineOut_packed,
        bank_lineOut_packed,
        128'b0,
        datasel);

    generate
        for (gi_dl = 0; gi_dl < CACHE_LINES_SIZE_B; gi_dl++) begin : g_dataLineOut_unpack
            assign outputs_o.dataLineOut[gi_dl] = dataLineOut_flat[8*gi_dl +: 8];
        end
    endgenerate

    // SV line 388: hit_o = bank.hit || vcache.hit
    wire hit_o_w;
    `OR_2(u_hit_o, 1, hit_o_w, dcache_bank_outputs.hit, vcache_outputs.hit);
    assign outputs_o.hit_o = hit_o_w;

    assign outputs_o.eb_addr = eb_outputs.addr;
    //assign outputs_o.eb_V_o = eb_outputs.valid;
    //assign outputs_o.eb_line_O = eb_outputs.lineOut;

    wire makeBlockReq, eb_blockingVCache, eb_V, eb_curr_commiting,eb_blocking_Bank;
    assign makeBlockReq = dcache_bank_outputs.MakeReq;
    assign eb_blockingVCache = vcache_outputs.beingBlocked;
    assign eb_V = eb_outputs.valid;
    assign eb_curr_commiting = eb_outputs.commiting;
    assign eb_blocking_Bank = dcache_bank_outputs.eb_stalling;

    // SV lines 410-446: req_2_sch priority encoder.
    // Top priority: EB_BLOCKING_BANK > vcache-blocking subreq > fill subreq > EB_WR.
    // Each "and !eb_curr_commiting" clause folds into a precomputed condition wire.

    wire not_committing;
    `INV_N(u_not_committing, 1, eb_curr_commiting, not_committing);

    wire cond_blocking_bank;
    wire cond_blocking_vcache;
    wire cond_eb_wr;
    `AND_2(u_cond_block_bank,   1, cond_blocking_bank,   eb_blocking_Bank,   not_committing);
    `AND_2(u_cond_block_vcache, 1, cond_blocking_vcache, eb_blockingVCache,  not_committing);
    `AND_2(u_cond_eb_wr,        1, cond_eb_wr,           eb_V,               not_committing);

    // Inner-A — vcache-blocking subreq (SV lines 434-437).
    // Priority: st_override > oe > we > NO_REQ.
    wire [13:0] innerA_we_or_zero;
    wire [13:0] innerA_oe_we_zero;
    wire [13:0] innerA_full;
    `MUX_2(u_innerA_a, 14, innerA_we_or_zero,
        NO_REQ, DCACHE_EB_BLOCK_ST, block_req_i.we);
    `MUX_2(u_innerA_b, 14, innerA_oe_we_zero,
        innerA_we_or_zero, DCACHE_EB_BLOCKING_LD, block_req_i.oe);
    `MUX_2(u_innerA_c, 14, innerA_full,
        innerA_oe_we_zero, DCACHE_EB_BLOCKING_ST_OVERRIDE, st_override_for_sch_req);

    // Inner-B — fill subreq (SV lines 438-441).
    wire [13:0] innerB_we_or_zero;
    wire [13:0] innerB_oe_we_zero;
    wire [13:0] innerB_full;
    `MUX_2(u_innerB_a, 14, innerB_we_or_zero,
        NO_REQ, DCACHE_FILL_ST, block_req_i.we);
    `MUX_2(u_innerB_b, 14, innerB_oe_we_zero,
        innerB_we_or_zero, DCACHE_FILL_LD, block_req_i.oe);
    `MUX_2(u_innerB_c, 14, innerB_full,
        innerB_oe_we_zero, DCACHE_FILL_ST_OVERRIDE, st_override_for_sch_req);

    // Top-level priority chain — lowest priority bound on the right.
    wire [13:0] req_step1;
    wire [13:0] req_step2;
    wire [13:0] req_step3;
    wire [13:0] req_2_sch_w;
    `MUX_2(u_top_step1, 14, req_step1,    NO_REQ,    DCACHE_EB_WR,            cond_eb_wr);
    `MUX_2(u_top_step2, 14, req_step2,    req_step1, innerB_full,             makeBlockReq);
    `MUX_2(u_top_step3, 14, req_step3,    req_step2, innerA_full,             cond_blocking_vcache);
    `MUX_2(u_top_step4, 14, req_2_sch_w,  req_step3, DCACHE_EB_BLOCKING_BANK, cond_blocking_bank);

    assign outputs_o.req_2_sch = req_2_sch_w;

    //bus logic
    //addr bus — SV lines 450-452 ("#5 assign" with ternary).
    // 15-bit address mux: Ld=1 -> block_req.p_addr, else -> eb_outputs.addr.
    wire [14:0] addr_bus_fake15;
    `MUX_2(u_addr_bus_mux, 15, addr_bus_fake15,
        eb_outputs.addr,
        block_req_i.p_addr,
        permissionToDriveAddrBus_Ld);

    // Zero-extend the 15-bit address to the 32-bit bus width (matches SV implicit cast).
    wire [ADDRESS_BUS_WIDTH_BITS - 1 : 0] address_bus_fake;
    assign address_bus_fake = {17'b0, addr_bus_fake15};

    // Drive enable: permissionToDriveAddrBus_Ld | permissionToDriveAddrBus_eb.
    wire addr_drive_en;
    wire addr_drive_enbar;
    `NOR_2(u_addr_drive_en, 1, addr_drive_enbar,
        permissionToDriveAddrBus_Ld, permissionToDriveAddrBus_eb);
   // `INV_N(u_addr_drive_enbar, 1, addr_drive_en, addr_drive_enbar);

    // SV `assign #5` was only modeling the bus driver's intrinsic delay;
    // BUS_TRISTATE already provides that physically. No buffer chain needed.
    `BUS_TRISTATE(u_addr_bus_tri, ADDRESS_BUS_WIDTH_BITS,
        addr_drive_enbar, address_bus_fake, address_bus);
    //int startingOffset;
    //logic [DATA_BUS_WIDTH_BITS - 1 : 0] dataBus_fake;

    // assign dataBus =
    //     permissionToDriveDataBus_evictionBuf[0]
    //     || permissionToDriveDataBus_evictionBuf[1]
    //     || permissionToDriveDataBus_evictionBuf[2]
    //     || permissionToDriveDataBus_evictionBuf[3]? dataBus_fake : 'z;
    // //data bus
    // always_comb begin
    //     startingOffset = 0;
    //     for (int i = 0; i < CACHE_LINES_SIZE_BITS / DATA_BUS_WIDTH_BITS; i++) begin
    //         dataBus_fake = '0;
    //         if (permissionToDriveDataBus_evictionBuf[i]) begin
    //             startingOffset = i * CACHE_LINES_SIZE_BITS / DATA_BUS_WIDTH_BITS;
    //             dataBus_fake = {
    //                 eb_outputs.lineOut[startingOffset],
    //                 eb_outputs.lineOut[startingOffset+1],
    //                 eb_outputs.lineOut[startingOffset+2],
    //                 eb_outputs.lineOut[startingOffset+3]
    //             };
    //         end
    //     end
    // end

    // SV lines 480-485: per-bit `~` over the 4-element permission array.
    wire [3:0] perm_packed;
    assign perm_packed = {
        permissionToDriveDataBus_evictionBuf[3],
        permissionToDriveDataBus_evictionBuf[2],
        permissionToDriveDataBus_evictionBuf[1],
        permissionToDriveDataBus_evictionBuf[0]
    };
    wire [3:0] perm2DriveDataBus_bar;
    `INV_N(u_perm_inv, 4, perm_packed, perm2DriveDataBus_bar);

    logic [127:0] eb_lineOut_vec;
    assign eb_lineOut_vec = {
        eb_outputs.lineOut[15],
        eb_outputs.lineOut[14],
        eb_outputs.lineOut[13],
        eb_outputs.lineOut[12],
        eb_outputs.lineOut[11],
        eb_outputs.lineOut[10],
        eb_outputs.lineOut[9],
        eb_outputs.lineOut[8],
        eb_outputs.lineOut[7],
        eb_outputs.lineOut[6],
        eb_outputs.lineOut[5],
        eb_outputs.lineOut[4],
        eb_outputs.lineOut[3],
        eb_outputs.lineOut[2],
        eb_outputs.lineOut[1],
        eb_outputs.lineOut[0]
    };

    `BUS_TRISTATE(memBus_tri_0, 32, perm2DriveDataBus_bar[0], eb_lineOut_vec[31:0], dataBus);
    `BUS_TRISTATE(memBus_tri_1, 32, perm2DriveDataBus_bar[1], eb_lineOut_vec[63:32], dataBus);
    `BUS_TRISTATE(memBus_tri_2, 32, perm2DriveDataBus_bar[2], eb_lineOut_vec[95:64], dataBus);
    `BUS_TRISTATE(memBus_tri_3, 32, perm2DriveDataBus_bar[3], eb_lineOut_vec[127:96], dataBus);





endmodule
