
module AllAtOnce_TOP (
    input wire clk,
    input wire rst
);

    // =========================================================================
    // Bridge wires between EveryThing_TOP (core) and Everywhere_TOP (memory)
    // No structs -- everything is flat.
    // =========================================================================

    // ---- core -> icache ----
    wire        core2icache_icache_en;
    wire [14:0] core2icache_p_addr;
    wire [31:0] core2icache_v_addr_i;
    wire [2:0]  core2icache_num_valid_IDM_slots;

    // ---- core -> dcache : load addresses (DC stage) ----
    wire        core2dcache_ld_addr_0_V;
    wire [14:0] core2dcache_ld_addr_0;
    wire        core2dcache_ld_addr_1_V;
    wire [14:0] core2dcache_ld_addr_1;
    wire        core2dcache_ld_addr_MIO_V;
    wire [14:0] core2dcache_ld_addr_MIO;

    // ---- core -> dcache : stq_heads[0..3] (WB stage) ----
    wire        core2dcache_stq_heads_0_full;
    wire        core2dcache_stq_heads_0_empty;
    wire [14:0] core2dcache_stq_heads_0_address;
    wire [15:0] core2dcache_stq_heads_0_bit_vec;
    wire        core2dcache_stq_heads_1_full;
    wire        core2dcache_stq_heads_1_empty;
    wire [14:0] core2dcache_stq_heads_1_address;
    wire [15:0] core2dcache_stq_heads_1_bit_vec;
    wire        core2dcache_stq_heads_2_full;
    wire        core2dcache_stq_heads_2_empty;
    wire [14:0] core2dcache_stq_heads_2_address;
    wire [15:0] core2dcache_stq_heads_2_bit_vec;
    wire        core2dcache_stq_heads_3_full;
    wire        core2dcache_stq_heads_3_empty;
    wire [14:0] core2dcache_stq_heads_3_address;
    wire [15:0] core2dcache_stq_heads_3_bit_vec;

    // ---- core -> dcache : stq_info_mio (scalars; data is the 128-bit flat) ----
    wire        core2dcache_stq_info_mio_empty;
    wire [14:0] core2dcache_stq_info_mio_address;

    // ---- core -> dcache : memStage_CLR_REQ[0..3] + MIO ----
    wire        core2dcache_memStage_CLR_REQ_0;
    wire        core2dcache_memStage_CLR_REQ_1;
    wire        core2dcache_memStage_CLR_REQ_2;
    wire        core2dcache_memStage_CLR_REQ_3;
    wire        core2dcache_memStage_CLR_REQ_MIO;

    // ---- core -> dcache : 128-bit packed stq data buses ----
    wire [127:0] core_stq_data_flat [0:3];
    wire [127:0] core_stq_info_mio_data_flat;

    // ---- dcache -> core : 128-bit packed cacheline / MIO line ----
    wire [127:0] dcache_out2Core_cacheline_w [0:3];
    wire [127:0] dcache_out2Core_line_MIO_w;

    // ---- icache -> core : 128-bit packed instruction line ----
    wire [127:0] icache_instruction_line_w;

    // ---- dcache -> core : flat scalar/array outputs ----
    wire        dcache_out2Core_reqServed_0_w;
    wire        dcache_out2Core_reqServed_1_w;
    wire        dcache_out2Core_hit_w           [0:3];
    wire        dcache_out2Core_writeSuccess_w  [0:3];
    wire        dcache_out2Core_writeSuccess_MIO_w;
    wire        dcache_out2Core_hit_MIO_w;
    wire        dcache_out2Core_reqServed_MIO_w;

    wire        icache_hit_w;
    wire        dma_intOut_w;


    // ---------------------------------------------------------------
    // Everywhere_TOP — memory subsystem (consumes core->mem signals,
    // produces mem->core signals)
    // ---------------------------------------------------------------
    Everywhere_TOP mem_sys_unit (
        .clk(clk),
        .rst(rst),

        // ---- core_2_icache (inputs) ----
        .icache_icache_en_i           (core2icache_icache_en),
        .icache_p_addr_i              (core2icache_p_addr),
        .icache_v_addr_i              (core2icache_v_addr_i),
        .icache_num_valid_IDM_slots_i (core2icache_num_valid_IDM_slots),

        // ---- icache_2_core (outputs) ----
        .icache_hit_o                 (icache_hit_w),
        .icache_instruction_line_o    (icache_instruction_line_w),

        // ---- core_2_dcache (inputs) ----
        .core_ld_addr_0_V_i (core2dcache_ld_addr_0_V),
        .core_ld_addr_0_i   (core2dcache_ld_addr_0),
        .core_ld_addr_1_V_i (core2dcache_ld_addr_1_V),
        .core_ld_addr_1_i   (core2dcache_ld_addr_1),

        .core_stq_full_0_i  (core2dcache_stq_heads_0_full),
        .core_stq_full_1_i  (core2dcache_stq_heads_1_full),
        .core_stq_full_2_i  (core2dcache_stq_heads_2_full),
        .core_stq_full_3_i  (core2dcache_stq_heads_3_full),
        .core_stq_empty_0_i (core2dcache_stq_heads_0_empty),
        .core_stq_empty_1_i (core2dcache_stq_heads_1_empty),
        .core_stq_empty_2_i (core2dcache_stq_heads_2_empty),
        .core_stq_empty_3_i (core2dcache_stq_heads_3_empty),
        .core_stq_addr_0_i  (core2dcache_stq_heads_0_address),
        .core_stq_addr_1_i  (core2dcache_stq_heads_1_address),
        .core_stq_addr_2_i  (core2dcache_stq_heads_2_address),
        .core_stq_addr_3_i  (core2dcache_stq_heads_3_address),
        .core_stq_bitvec_0_i(core2dcache_stq_heads_0_bit_vec),
        .core_stq_bitvec_1_i(core2dcache_stq_heads_1_bit_vec),
        .core_stq_bitvec_2_i(core2dcache_stq_heads_2_bit_vec),
        .core_stq_bitvec_3_i(core2dcache_stq_heads_3_bit_vec),
        .core_stq_data_0_i  (core_stq_data_flat[0]),
        .core_stq_data_1_i  (core_stq_data_flat[1]),
        .core_stq_data_2_i  (core_stq_data_flat[2]),
        .core_stq_data_3_i  (core_stq_data_flat[3]),

        .core_ld_addr_MIO_V_i(core2dcache_ld_addr_MIO_V),
        .core_ld_addr_MIO_i  (core2dcache_ld_addr_MIO),

        .core_stq_info_mio_empty_i(core2dcache_stq_info_mio_empty),
        .core_stq_info_mio_addr_i (core2dcache_stq_info_mio_address),
        .core_stq_info_mio_data_i (core_stq_info_mio_data_flat),

        .core_memStage_CLR_REQ_0_i  (core2dcache_memStage_CLR_REQ_0),
        .core_memStage_CLR_REQ_1_i  (core2dcache_memStage_CLR_REQ_1),
        .core_memStage_CLR_REQ_2_i  (core2dcache_memStage_CLR_REQ_2),
        .core_memStage_CLR_REQ_3_i  (core2dcache_memStage_CLR_REQ_3),
        .core_memStage_CLR_REQ_MIO_i(core2dcache_memStage_CLR_REQ_MIO),

        // ---- dcache_2_core (outputs) ----
        .out2Core_reqServed_0_o    (dcache_out2Core_reqServed_0_w),
        .out2Core_reqServed_1_o    (dcache_out2Core_reqServed_1_w),
        .out2Core_hit_0_o          (dcache_out2Core_hit_w[0]),
        .out2Core_hit_1_o          (dcache_out2Core_hit_w[1]),
        .out2Core_hit_2_o          (dcache_out2Core_hit_w[2]),
        .out2Core_hit_3_o          (dcache_out2Core_hit_w[3]),
        .out2Core_cacheline_0_o    (dcache_out2Core_cacheline_w[0]),
        .out2Core_cacheline_1_o    (dcache_out2Core_cacheline_w[1]),
        .out2Core_cacheline_2_o    (dcache_out2Core_cacheline_w[2]),
        .out2Core_cacheline_3_o    (dcache_out2Core_cacheline_w[3]),
        .out2Core_writeSuccess_0_o (dcache_out2Core_writeSuccess_w[0]),
        .out2Core_writeSuccess_1_o (dcache_out2Core_writeSuccess_w[1]),
        .out2Core_writeSuccess_2_o (dcache_out2Core_writeSuccess_w[2]),
        .out2Core_writeSuccess_3_o (dcache_out2Core_writeSuccess_w[3]),
        .out2Core_writeSuccess_MIO_o(dcache_out2Core_writeSuccess_MIO_w),
        .out2Core_hit_MIO_o         (dcache_out2Core_hit_MIO_w),
        .out2Core_reqServed_MIO_o   (dcache_out2Core_reqServed_MIO_w),
        .out2Core_line_MIO_o        (dcache_out2Core_line_MIO_w),

        // ---- dma_controller_2_core (outputs) ----
        .dma_intOut_o(dma_intOut_w)
    );


    // ---------------------------------------------------------------
    // EveryThing_TOP — core (drives core->mem signals, consumes mem->core)
    // ---------------------------------------------------------------
    EveryThing_TOP core_unit (
        .clk(clk),
        .rst(rst),

        // ---- icache_2_core (inputs) ----
        .out_hit              (icache_hit_w),
        .out_instruction_line (icache_instruction_line_w),

        // ---- dma_controller_2_core (input) ----
        .inFromDMA_i (dma_intOut_w),

        // ---- dcache_2_core (inputs) ----
        .dcache2Core_reqServed_0_o    (dcache_out2Core_reqServed_0_w),
        .dcache2Core_reqServed_1_o    (dcache_out2Core_reqServed_1_w),
        .dcache2Core_hit_0_o          (dcache_out2Core_hit_w[0]),
        .dcache2Core_hit_1_o          (dcache_out2Core_hit_w[1]),
        .dcache2Core_hit_2_o          (dcache_out2Core_hit_w[2]),
        .dcache2Core_hit_3_o          (dcache_out2Core_hit_w[3]),
        .dcache2Core_cacheline_0_o    (dcache_out2Core_cacheline_w[0]),
        .dcache2Core_cacheline_1_o    (dcache_out2Core_cacheline_w[1]),
        .dcache2Core_cacheline_2_o    (dcache_out2Core_cacheline_w[2]),
        .dcache2Core_cacheline_3_o    (dcache_out2Core_cacheline_w[3]),
        .dcache2Core_writeSuccess_0_o (dcache_out2Core_writeSuccess_w[0]),
        .dcache2Core_writeSuccess_1_o (dcache_out2Core_writeSuccess_w[1]),
        .dcache2Core_writeSuccess_2_o (dcache_out2Core_writeSuccess_w[2]),
        .dcache2Core_writeSuccess_3_o (dcache_out2Core_writeSuccess_w[3]),
        .dcache2Core_writeSuccess_MIO_o(dcache_out2Core_writeSuccess_MIO_w),
        .dcache2Core_hit_MIO_o        (dcache_out2Core_hit_MIO_w),
        .dcache2Core_reqServed_MIO_o  (dcache_out2Core_reqServed_MIO_w),
        .dcache2Core_line_MIO_o       (dcache_out2Core_line_MIO_w),

        // ---- core_2_dcache (outputs) ----
        .core_ld_addr_0_V_i (core2dcache_ld_addr_0_V),
        .core_ld_addr_0_i   (core2dcache_ld_addr_0),
        .core_ld_addr_1_V_i (core2dcache_ld_addr_1_V),
        .core_ld_addr_1_i   (core2dcache_ld_addr_1),

        .core_stq_full_0_i  (core2dcache_stq_heads_0_full),
        .core_stq_full_1_i  (core2dcache_stq_heads_1_full),
        .core_stq_full_2_i  (core2dcache_stq_heads_2_full),
        .core_stq_full_3_i  (core2dcache_stq_heads_3_full),
        .core_stq_empty_0_i (core2dcache_stq_heads_0_empty),
        .core_stq_empty_1_i (core2dcache_stq_heads_1_empty),
        .core_stq_empty_2_i (core2dcache_stq_heads_2_empty),
        .core_stq_empty_3_i (core2dcache_stq_heads_3_empty),
        .core_stq_addr_0_i  (core2dcache_stq_heads_0_address),
        .core_stq_addr_1_i  (core2dcache_stq_heads_1_address),
        .core_stq_addr_2_i  (core2dcache_stq_heads_2_address),
        .core_stq_addr_3_i  (core2dcache_stq_heads_3_address),
        .core_stq_bitvec_0_i(core2dcache_stq_heads_0_bit_vec),
        .core_stq_bitvec_1_i(core2dcache_stq_heads_1_bit_vec),
        .core_stq_bitvec_2_i(core2dcache_stq_heads_2_bit_vec),
        .core_stq_bitvec_3_i(core2dcache_stq_heads_3_bit_vec),
        .core_stq_data_0_i  (core_stq_data_flat[0]),
        .core_stq_data_1_i  (core_stq_data_flat[1]),
        .core_stq_data_2_i  (core_stq_data_flat[2]),
        .core_stq_data_3_i  (core_stq_data_flat[3]),

        .core_ld_addr_MIO_V_i(core2dcache_ld_addr_MIO_V),
        .core_ld_addr_MIO_i  (core2dcache_ld_addr_MIO),

        .core_stq_info_mio_empty_i(core2dcache_stq_info_mio_empty),
        .core_stq_info_mio_addr_i (core2dcache_stq_info_mio_address),
        .core_stq_info_mio_data_i (core_stq_info_mio_data_flat),

        .core_memStage_CLR_REQ_0_i  (core2dcache_memStage_CLR_REQ_0),
        .core_memStage_CLR_REQ_1_i  (core2dcache_memStage_CLR_REQ_1),
        .core_memStage_CLR_REQ_2_i  (core2dcache_memStage_CLR_REQ_2),
        .core_memStage_CLR_REQ_3_i  (core2dcache_memStage_CLR_REQ_3),
        .core_memStage_CLR_REQ_MIO_i(core2dcache_memStage_CLR_REQ_MIO),

        // ---- core_2_icache (outputs) ----
        .icache_en           (core2icache_icache_en),
        .p_addr              (core2icache_p_addr),
        .v_addr_i            (core2icache_v_addr_i),
        .num_valid_IDM_slots (core2icache_num_valid_IDM_slots)
    );

endmodule
