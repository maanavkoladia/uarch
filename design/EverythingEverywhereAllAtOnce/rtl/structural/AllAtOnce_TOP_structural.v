import common_pkg::*;
import interconnect_pkg::*;

module AllAtOnce_TOP (
    input wire clk,
    input wire rst
);

    // ================================================================
    // Struct wires for the core (EveryThing_TOP) — the core still uses
    // the SystemVerilog struct interface. Everywhere_TOP_structural is
    // pure Verilog 2005 with flat ports; this file is the boundary that
    // unpacks structs going into it and repacks structs coming out.
    // ================================================================
    icache_2_core_t                 icache2core;
    //core_2_icache_t                 core2icache;

    wire core2icache_icache_en;
    wire [14:0] core2icache_p_addr;
    wire [31:0] core2icache_v_addr_i;
    wire [1:0] core2icache_num_valid_IDM_slots;

    st_q_2_dcache_t                 stq2dcache;  // unused at this scope
    core_2_dcache_t                 core2dcache;
    dcache_2_core_t                 dcache2core;

    dma_controller_2_core_t         dma2core;

    // ================================================================
    // Adapter wires for the flat-port Everywhere_TOP boundary.
    // Naming mirrors the Everywhere_TOP_structural port names.
    // ================================================================

    // ---- core_2_dcache_t inputs need byte-array → 128-bit packing ----
    wire                    [127:0] core_stq_data_flat                  [4];
    wire                    [127:0] core_stq_info_mio_data_flat;

    // ---- dte_2_dcache_t.permissionToDriveDataBus_evictionBuf is bool[4][4]
    //      — pack the inner 4-element array into a 4-bit wire per outer idx.
    //      The struct field is driven inside Everywhere_TOP from BusArbitration,
    //      so this packing is only relevant for the struct-shaped neighbours
    //      that don't exist at this scope. (Comment retained for symmetry.)

    // ---- dcache_2_core_t outputs need 128-bit → byte-array unpacking ----
    wire                    [127:0] dcache_out2Core_cacheline_w         [4];
    wire                    [127:0] dcache_out2Core_line_MIO_w;

    // ---- icache_2_core_t.instruction_line: 128-bit flat → byte[16] ----
    wire                    [127:0] icache_instruction_line_w;

    // Flat outputs from Everywhere_TOP that drive struct fields below
    wire                            dcache_out2Core_reqServed_0_w;
    wire                            dcache_out2Core_reqServed_1_w;
    wire                            dcache_out2Core_hit_w               [4];
    wire                            dcache_out2Core_writeSuccess_w      [4];
    wire                            dcache_out2Core_writeSuccess_MIO_w;
    wire                            dcache_out2Core_hit_MIO_w;
    wire                            dcache_out2Core_reqServed_MIO_w;

    wire                            icache_hit_w;
    wire                            dma_intOut_w;

    // ---------------------------------------------------------------
    // Pack core_2_dcache_t.stq_heads[i].data[16] (byte_t) → 128-bit flat
    // and core_2_dcache_t.stq_info_mio.data[16] → 128-bit flat.
    // LSB-first: byte 0 in [7:0], byte 15 in [127:120].
    // ---------------------------------------------------------------
    genvar gp_i, gp_b;
    generate
        for (gp_i = 0; gp_i < 4; gp_i = gp_i + 1) begin : g_core_stq_data_pack
            for (gp_b = 0; gp_b < CACHE_LINES_SIZE_B; gp_b = gp_b + 1) begin : g_byte
                assign core_stq_data_flat[gp_i][gp_b*8+:8] = core2dcache.stq_heads[gp_i].data[gp_b];
            end
        end
        for (gp_b = 0; gp_b < CACHE_LINES_SIZE_B; gp_b = gp_b + 1) begin : g_core_stq_mio_pack
            assign core_stq_info_mio_data_flat[gp_b*8+:8] = core2dcache.stq_info_mio.data[gp_b];
        end
    endgenerate

    // ================================================================
    // core
    // ================================================================

    EveryThing_TOP core_unit (
        .clk(clk),
        .rst(rst),
        .ICacheIn_i_hit(icache_hit_w),
        .ICacheIn_i_instruction_line(icache_instruction_line_w),
        .DCache_i_DCachereqServed_0(dcache_out2Core_reqServed_0_w),
        .DCache_i_reqServed_1(dcache_out2Core_reqServed_1_w),
        .DCache_i_hit_0(dcache_out2Core_hit_w[0]),
        .DCache_i_hit_1(dcache_out2Core_hit_w[1]),
        .DCache_i_hit_2(dcache_out2Core_hit_w[2]),
        .DCache_i_hit_3(dcache_out2Core_hit_w[3]),
        .DCache_i_cacheline_0(dcache_out2Core_cacheline_w[0]),
        .DCache_i_cacheline_1(dcache_out2Core_cacheline_w[1]),
        .DCache_i_cacheline_2(dcache_out2Core_cacheline_w[2]),
        .DCache_i_cacheline_3(dcache_out2Core_cacheline_w[3]),
        .DCache_i_writeSuccess_0(dcache_out2Core_writeSuccess_w[0]),
        .DCache_i_writeSuccess_1(dcache_out2Core_writeSuccess_w[1]),
        .DCache_i_writeSuccess_2(dcache_out2Core_writeSuccess_w[2]),
        .DCache_i_writeSuccess_3(dcache_out2Core_writeSuccess_w[3]),
        .DCache_i_writeSuccess_MIO(dcache_out2Core_writeSuccess_MIO_w),  //for pop MIO
        .DCache_i_hit_MIO(dcache_out2Core_hit_MIO_w),  //for ld_mem stage
        .DCache_i_reqServed_MIO(dcache_out2Core_reqServed_MIO_w),  //for dc stage
        .DCache_i_line_MIO(dcache_out2Core_line_MIO_w),
        .inFromDMA_i_intOut(dma_intOut_w),
        .out2ICache_o_icache_en(core2icache_icache_en),
        .out2ICache_o_p_addr(core2icache_p_addr),
        .out2ICache_o_v_addr_i(core2icache_v_addr_i),
        .out2ICache_o_num_valid_IDM_slots(core2icache_num_valid_IDM_slots),
        .out2DCache_o(core2dcache)
    );

    // ---------------------------------------------------------------
    // Everywhere_TOP — flat-port instantiation
    // ---------------------------------------------------------------
    Everywhere_TOP mem_sys_unit (
        .clk(clk),
        .rst(rst),

        // core_2_icache_t inputs (unpacked)
        .icache_icache_en_i          (core2icache_icache_en),
        .icache_p_addr_i             (core2icache_p_addr),
        .icache_v_addr_i             (core2icache_v_addr_i),
        .icache_num_valid_IDM_slots_i(core2icache_num_valid_IDM_slots),

        // icache_2_core_t outputs (unpacked)
        .icache_hit_o             (icache_hit_w),
        .icache_instruction_line_o(icache_instruction_line_w),

        // core_2_dcache_t inputs (unpacked)
        .core_ld_addr_0_V_i(core2dcache.ld_addr_0_V),
        .core_ld_addr_0_i  (core2dcache.ld_addr_0),
        .core_ld_addr_1_V_i(core2dcache.ld_addr_1_V),
        .core_ld_addr_1_i  (core2dcache.ld_addr_1),

        .core_stq_full_0_i  (core2dcache.stq_heads[0].full),
        .core_stq_full_1_i  (core2dcache.stq_heads[1].full),
        .core_stq_full_2_i  (core2dcache.stq_heads[2].full),
        .core_stq_full_3_i  (core2dcache.stq_heads[3].full),
        .core_stq_empty_0_i (core2dcache.stq_heads[0].empty),
        .core_stq_empty_1_i (core2dcache.stq_heads[1].empty),
        .core_stq_empty_2_i (core2dcache.stq_heads[2].empty),
        .core_stq_empty_3_i (core2dcache.stq_heads[3].empty),
        .core_stq_addr_0_i  (core2dcache.stq_heads[0].address),
        .core_stq_addr_1_i  (core2dcache.stq_heads[1].address),
        .core_stq_addr_2_i  (core2dcache.stq_heads[2].address),
        .core_stq_addr_3_i  (core2dcache.stq_heads[3].address),
        .core_stq_bitvec_0_i(core2dcache.stq_heads[0].bit_vec),
        .core_stq_bitvec_1_i(core2dcache.stq_heads[1].bit_vec),
        .core_stq_bitvec_2_i(core2dcache.stq_heads[2].bit_vec),
        .core_stq_bitvec_3_i(core2dcache.stq_heads[3].bit_vec),
        .core_stq_data_0_i  (core_stq_data_flat[0]),
        .core_stq_data_1_i  (core_stq_data_flat[1]),
        .core_stq_data_2_i  (core_stq_data_flat[2]),
        .core_stq_data_3_i  (core_stq_data_flat[3]),

        .core_ld_addr_MIO_V_i(core2dcache.ld_addr_MIO_V),
        .core_ld_addr_MIO_i  (core2dcache.ld_addr_MIO),

        .core_stq_info_mio_empty_i(core2dcache.stq_info_mio.empty),
        .core_stq_info_mio_addr_i (core2dcache.stq_info_mio.address),
        .core_stq_info_mio_data_i (core_stq_info_mio_data_flat),

        .core_memStage_CLR_REQ_0_i  (core2dcache.memStage_CLR_REQ[0]),
        .core_memStage_CLR_REQ_1_i  (core2dcache.memStage_CLR_REQ[1]),
        .core_memStage_CLR_REQ_2_i  (core2dcache.memStage_CLR_REQ[2]),
        .core_memStage_CLR_REQ_3_i  (core2dcache.memStage_CLR_REQ[3]),
        .core_memStage_CLR_REQ_MIO_i(core2dcache.memStage_CLR_REQ_MIO),

        // dcache_2_core_t outputs (unpacked)
        .out2Core_reqServed_0_o     (dcache_out2Core_reqServed_0_w),
        .out2Core_reqServed_1_o     (dcache_out2Core_reqServed_1_w),
        .out2Core_hit_0_o           (dcache_out2Core_hit_w[0]),
        .out2Core_hit_1_o           (dcache_out2Core_hit_w[1]),
        .out2Core_hit_2_o           (dcache_out2Core_hit_w[2]),
        .out2Core_hit_3_o           (dcache_out2Core_hit_w[3]),
        .out2Core_cacheline_0_o     (dcache_out2Core_cacheline_w[0]),
        .out2Core_cacheline_1_o     (dcache_out2Core_cacheline_w[1]),
        .out2Core_cacheline_2_o     (dcache_out2Core_cacheline_w[2]),
        .out2Core_cacheline_3_o     (dcache_out2Core_cacheline_w[3]),
        .out2Core_writeSuccess_0_o  (dcache_out2Core_writeSuccess_w[0]),
        .out2Core_writeSuccess_1_o  (dcache_out2Core_writeSuccess_w[1]),
        .out2Core_writeSuccess_2_o  (dcache_out2Core_writeSuccess_w[2]),
        .out2Core_writeSuccess_3_o  (dcache_out2Core_writeSuccess_w[3]),
        .out2Core_writeSuccess_MIO_o(dcache_out2Core_writeSuccess_MIO_w),
        .out2Core_hit_MIO_o         (dcache_out2Core_hit_MIO_w),
        .out2Core_reqServed_MIO_o   (dcache_out2Core_reqServed_MIO_w),
        .out2Core_line_MIO_o        (dcache_out2Core_line_MIO_w),

        // dma_controller_2_core_t outputs (unpacked)
        .dma_intOut_o(dma_intOut_w)
    );

    // ---------------------------------------------------------------
    // Repack flat outputs from Everywhere_TOP into the core-facing structs.
    // ---------------------------------------------------------------

    // icache_2_core_t
    assign icache2core.hit = icache_hit_w;
    generate
        for (gp_b = 0; gp_b < CACHE_LINES_SIZE_B; gp_b = gp_b + 1) begin : g_icache_line_unpack
            assign icache2core.instruction_line[gp_b] = icache_instruction_line_w[gp_b*8+:8];
        end
    endgenerate

    // dcache_2_core_t scalar fields
    assign dcache2core.reqServed_0      = dcache_out2Core_reqServed_0_w;
    assign dcache2core.reqServed_1      = dcache_out2Core_reqServed_1_w;
    assign dcache2core.writeSuccess_MIO = dcache_out2Core_writeSuccess_MIO_w;
    assign dcache2core.hit_MIO          = dcache_out2Core_hit_MIO_w;
    assign dcache2core.reqServed_MIO    = dcache_out2Core_reqServed_MIO_w;

    // dcache_2_core_t per-bank fields + cacheline byte unpack
    generate
        for (gp_i = 0; gp_i < 4; gp_i = gp_i + 1) begin : g_dcache_unpack
            assign dcache2core.hit[gp_i]          = dcache_out2Core_hit_w[gp_i];
            assign dcache2core.writeSuccess[gp_i] = dcache_out2Core_writeSuccess_w[gp_i];
            for (gp_b = 0; gp_b < CACHE_LINES_SIZE_B; gp_b = gp_b + 1) begin : g_byte
                assign dcache2core.cacheline[gp_i][gp_b] =
                    dcache_out2Core_cacheline_w[gp_i][gp_b*8 +: 8];
            end
        end
        for (gp_b = 0; gp_b < CACHE_LINES_SIZE_B; gp_b = gp_b + 1) begin : g_dcache_mio_line_unpack
            assign dcache2core.line_MIO[gp_b] = dcache_out2Core_line_MIO_w[gp_b*8+:8];
        end
    endgenerate

    // dma_controller_2_core_t
    assign dma2core.intOut = dma_intOut_w;

    initial begin
        //for init rituals
    end
endmodule
