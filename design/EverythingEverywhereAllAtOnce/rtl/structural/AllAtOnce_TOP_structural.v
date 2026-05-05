// AllAtOnce_TOP_structural.v
//
// Pure Verilog-2005 top: stitches the flat-port core (EveryThing_TOP) to
// the flat-port memory subsystem (Everywhere_TOP) without any SV struct
// types or package imports. Every wire below is a packed `wire`; per-slot
// byte arrays are 128-bit packed buses (LSB-first byte ordering).

module AllAtOnce_TOP (
    input wire clk,
    input wire rst
);

    // ================================================================
    // Wires bridging EveryThing_TOP <-> Everywhere_TOP.
    // Each wire has exactly one driver (one module's output) and one
    // reader (the other module's input). Names track the EveryThing_TOP
    // port names, since those define the core's view of the boundary.
    // ================================================================

    // --- icache_2_core_t (Everywhere -> Core) ---
    wire         ICacheIn_hit;
    wire [127:0] ICacheIn_instruction_line;

    // --- core_2_icache_t (Core -> Everywhere) ---
    wire         out2ICache_icache_en;
    wire [14:0]  out2ICache_p_addr;
    wire [31:0]  out2ICache_v_addr_i;
    wire [2:0]   out2ICache_num_valid_IDM_slots;

    // --- dcache_2_core_t (Everywhere -> Core) ---
    wire         DCacheIn_reqServed_0;
    wire         DCacheIn_reqServed_1;
    wire         DCacheIn_hit_0;
    wire         DCacheIn_hit_1;
    wire         DCacheIn_hit_2;
    wire         DCacheIn_hit_3;
    wire [127:0] DCacheIn_cacheline_0;
    wire [127:0] DCacheIn_cacheline_1;
    wire [127:0] DCacheIn_cacheline_2;
    wire [127:0] DCacheIn_cacheline_3;
    wire         DCacheIn_writeSuccess_0;
    wire         DCacheIn_writeSuccess_1;
    wire         DCacheIn_writeSuccess_2;
    wire         DCacheIn_writeSuccess_3;
    wire         DCacheIn_writeSuccess_MIO;
    wire         DCacheIn_hit_MIO;
    wire         DCacheIn_reqServed_MIO;
    wire [127:0] DCacheIn_line_MIO;

    // --- core_2_dcache_t (Core -> Everywhere) ---
    wire         out2DCache_ld_addr_0_V;
    wire [14:0]  out2DCache_ld_addr_0;
    wire         out2DCache_ld_addr_1_V;
    wire [14:0]  out2DCache_ld_addr_1;
    wire         out2DCache_ld_addr_MIO_V;
    wire [14:0]  out2DCache_ld_addr_MIO;

    wire         out2DCache_stq_heads_0_full;
    wire         out2DCache_stq_heads_0_empty;
    wire [14:0]  out2DCache_stq_heads_0_address;
    wire [15:0]  out2DCache_stq_heads_0_bit_vec;
    wire [127:0] out2DCache_stq_heads_0_data;
    wire         out2DCache_stq_heads_1_full;
    wire         out2DCache_stq_heads_1_empty;
    wire [14:0]  out2DCache_stq_heads_1_address;
    wire [15:0]  out2DCache_stq_heads_1_bit_vec;
    wire [127:0] out2DCache_stq_heads_1_data;
    wire         out2DCache_stq_heads_2_full;
    wire         out2DCache_stq_heads_2_empty;
    wire [14:0]  out2DCache_stq_heads_2_address;
    wire [15:0]  out2DCache_stq_heads_2_bit_vec;
    wire [127:0] out2DCache_stq_heads_2_data;
    wire         out2DCache_stq_heads_3_full;
    wire         out2DCache_stq_heads_3_empty;
    wire [14:0]  out2DCache_stq_heads_3_address;
    wire [15:0]  out2DCache_stq_heads_3_bit_vec;
    wire [127:0] out2DCache_stq_heads_3_data;

    wire         out2DCache_stq_info_mio_full;
    wire         out2DCache_stq_info_mio_empty;
    wire [14:0]  out2DCache_stq_info_mio_address;
    wire [15:0]  out2DCache_stq_info_mio_bit_vec;
    wire [127:0] out2DCache_stq_info_mio_data;

    wire         out2DCache_memStage_CLR_REQ_0;
    wire         out2DCache_memStage_CLR_REQ_1;
    wire         out2DCache_memStage_CLR_REQ_2;
    wire         out2DCache_memStage_CLR_REQ_3;
    wire         out2DCache_memStage_CLR_REQ_MIO;

    // --- dma_controller_2_core_t (DMA -> Core) ---
    wire         inFromDMA_intOut;

    // ================================================================
    // Core (EveryThing_TOP -- now fully flat-port).
    // ================================================================
    EveryThing_TOP core_unit (
        .clk(clk),
        .rst(rst),

        // icache_2_core_t inputs
        .ICacheIn_hit              (ICacheIn_hit),
        .ICacheIn_instruction_line (ICacheIn_instruction_line),

        // core_2_icache_t outputs
        .out2ICache_icache_en           (out2ICache_icache_en),
        .out2ICache_p_addr              (out2ICache_p_addr),
        .out2ICache_v_addr_i            (out2ICache_v_addr_i),
        .out2ICache_num_valid_IDM_slots (out2ICache_num_valid_IDM_slots),

        // dcache_2_core_t inputs
        .DCacheIn_reqServed_0      (DCacheIn_reqServed_0),
        .DCacheIn_reqServed_1      (DCacheIn_reqServed_1),
        .DCacheIn_hit_0            (DCacheIn_hit_0),
        .DCacheIn_hit_1            (DCacheIn_hit_1),
        .DCacheIn_hit_2            (DCacheIn_hit_2),
        .DCacheIn_hit_3            (DCacheIn_hit_3),
        .DCacheIn_cacheline_0      (DCacheIn_cacheline_0),
        .DCacheIn_cacheline_1      (DCacheIn_cacheline_1),
        .DCacheIn_cacheline_2      (DCacheIn_cacheline_2),
        .DCacheIn_cacheline_3      (DCacheIn_cacheline_3),
        .DCacheIn_writeSuccess_0   (DCacheIn_writeSuccess_0),
        .DCacheIn_writeSuccess_1   (DCacheIn_writeSuccess_1),
        .DCacheIn_writeSuccess_2   (DCacheIn_writeSuccess_2),
        .DCacheIn_writeSuccess_3   (DCacheIn_writeSuccess_3),
        .DCacheIn_writeSuccess_MIO (DCacheIn_writeSuccess_MIO),
        .DCacheIn_hit_MIO          (DCacheIn_hit_MIO),
        .DCacheIn_reqServed_MIO    (DCacheIn_reqServed_MIO),
        .DCacheIn_line_MIO         (DCacheIn_line_MIO),

        // core_2_dcache_t outputs
        .out2DCache_ld_addr_0_V         (out2DCache_ld_addr_0_V),
        .out2DCache_ld_addr_0           (out2DCache_ld_addr_0),
        .out2DCache_ld_addr_1_V         (out2DCache_ld_addr_1_V),
        .out2DCache_ld_addr_1           (out2DCache_ld_addr_1),
        .out2DCache_ld_addr_MIO_V       (out2DCache_ld_addr_MIO_V),
        .out2DCache_ld_addr_MIO         (out2DCache_ld_addr_MIO),

        .out2DCache_stq_heads_0_full    (out2DCache_stq_heads_0_full),
        .out2DCache_stq_heads_0_empty   (out2DCache_stq_heads_0_empty),
        .out2DCache_stq_heads_0_address (out2DCache_stq_heads_0_address),
        .out2DCache_stq_heads_0_bit_vec (out2DCache_stq_heads_0_bit_vec),
        .out2DCache_stq_heads_0_data    (out2DCache_stq_heads_0_data),
        .out2DCache_stq_heads_1_full    (out2DCache_stq_heads_1_full),
        .out2DCache_stq_heads_1_empty   (out2DCache_stq_heads_1_empty),
        .out2DCache_stq_heads_1_address (out2DCache_stq_heads_1_address),
        .out2DCache_stq_heads_1_bit_vec (out2DCache_stq_heads_1_bit_vec),
        .out2DCache_stq_heads_1_data    (out2DCache_stq_heads_1_data),
        .out2DCache_stq_heads_2_full    (out2DCache_stq_heads_2_full),
        .out2DCache_stq_heads_2_empty   (out2DCache_stq_heads_2_empty),
        .out2DCache_stq_heads_2_address (out2DCache_stq_heads_2_address),
        .out2DCache_stq_heads_2_bit_vec (out2DCache_stq_heads_2_bit_vec),
        .out2DCache_stq_heads_2_data    (out2DCache_stq_heads_2_data),
        .out2DCache_stq_heads_3_full    (out2DCache_stq_heads_3_full),
        .out2DCache_stq_heads_3_empty   (out2DCache_stq_heads_3_empty),
        .out2DCache_stq_heads_3_address (out2DCache_stq_heads_3_address),
        .out2DCache_stq_heads_3_bit_vec (out2DCache_stq_heads_3_bit_vec),
        .out2DCache_stq_heads_3_data    (out2DCache_stq_heads_3_data),

        .out2DCache_stq_info_mio_full    (out2DCache_stq_info_mio_full),
        .out2DCache_stq_info_mio_empty   (out2DCache_stq_info_mio_empty),
        .out2DCache_stq_info_mio_address (out2DCache_stq_info_mio_address),
        .out2DCache_stq_info_mio_bit_vec (out2DCache_stq_info_mio_bit_vec),
        .out2DCache_stq_info_mio_data    (out2DCache_stq_info_mio_data),

        .out2DCache_memStage_CLR_REQ_0   (out2DCache_memStage_CLR_REQ_0),
        .out2DCache_memStage_CLR_REQ_1   (out2DCache_memStage_CLR_REQ_1),
        .out2DCache_memStage_CLR_REQ_2   (out2DCache_memStage_CLR_REQ_2),
        .out2DCache_memStage_CLR_REQ_3   (out2DCache_memStage_CLR_REQ_3),
        .out2DCache_memStage_CLR_REQ_MIO (out2DCache_memStage_CLR_REQ_MIO),

        // dma_controller_2_core_t inputs
        .inFromDMA_intOut          (inFromDMA_intOut)
    );

    // ================================================================
    // Memory subsystem (Everywhere_TOP) -- already flat-port.
    // ================================================================
    Everywhere_TOP mem_sys_unit (
        .clk(clk),
        .rst(rst),

        // core_2_icache_t inputs (driven by core)
        .icache_icache_en_i           (out2ICache_icache_en),
        .icache_p_addr_i              (out2ICache_p_addr),
        .icache_v_addr_i              (out2ICache_v_addr_i),
        .icache_num_valid_IDM_slots_i (out2ICache_num_valid_IDM_slots),

        // icache_2_core_t outputs (consumed by core)
        .icache_hit_o                 (ICacheIn_hit),
        .icache_instruction_line_o    (ICacheIn_instruction_line),

        // core_2_dcache_t inputs (driven by core)
        .core_ld_addr_0_V_i (out2DCache_ld_addr_0_V),
        .core_ld_addr_0_i   (out2DCache_ld_addr_0),
        .core_ld_addr_1_V_i (out2DCache_ld_addr_1_V),
        .core_ld_addr_1_i   (out2DCache_ld_addr_1),

        .core_stq_full_0_i  (out2DCache_stq_heads_0_full),
        .core_stq_full_1_i  (out2DCache_stq_heads_1_full),
        .core_stq_full_2_i  (out2DCache_stq_heads_2_full),
        .core_stq_full_3_i  (out2DCache_stq_heads_3_full),
        .core_stq_empty_0_i (out2DCache_stq_heads_0_empty),
        .core_stq_empty_1_i (out2DCache_stq_heads_1_empty),
        .core_stq_empty_2_i (out2DCache_stq_heads_2_empty),
        .core_stq_empty_3_i (out2DCache_stq_heads_3_empty),
        .core_stq_addr_0_i  (out2DCache_stq_heads_0_address),
        .core_stq_addr_1_i  (out2DCache_stq_heads_1_address),
        .core_stq_addr_2_i  (out2DCache_stq_heads_2_address),
        .core_stq_addr_3_i  (out2DCache_stq_heads_3_address),
        .core_stq_bitvec_0_i(out2DCache_stq_heads_0_bit_vec),
        .core_stq_bitvec_1_i(out2DCache_stq_heads_1_bit_vec),
        .core_stq_bitvec_2_i(out2DCache_stq_heads_2_bit_vec),
        .core_stq_bitvec_3_i(out2DCache_stq_heads_3_bit_vec),
        .core_stq_data_0_i  (out2DCache_stq_heads_0_data),
        .core_stq_data_1_i  (out2DCache_stq_heads_1_data),
        .core_stq_data_2_i  (out2DCache_stq_heads_2_data),
        .core_stq_data_3_i  (out2DCache_stq_heads_3_data),

        .core_ld_addr_MIO_V_i(out2DCache_ld_addr_MIO_V),
        .core_ld_addr_MIO_i  (out2DCache_ld_addr_MIO),

        .core_stq_info_mio_empty_i(out2DCache_stq_info_mio_empty),
        .core_stq_info_mio_addr_i (out2DCache_stq_info_mio_address),
        .core_stq_info_mio_data_i (out2DCache_stq_info_mio_data),

        .core_memStage_CLR_REQ_0_i  (out2DCache_memStage_CLR_REQ_0),
        .core_memStage_CLR_REQ_1_i  (out2DCache_memStage_CLR_REQ_1),
        .core_memStage_CLR_REQ_2_i  (out2DCache_memStage_CLR_REQ_2),
        .core_memStage_CLR_REQ_3_i  (out2DCache_memStage_CLR_REQ_3),
        .core_memStage_CLR_REQ_MIO_i(out2DCache_memStage_CLR_REQ_MIO),

        // dcache_2_core_t outputs (consumed by core)
        .out2Core_reqServed_0_o    (DCacheIn_reqServed_0),
        .out2Core_reqServed_1_o    (DCacheIn_reqServed_1),
        .out2Core_hit_0_o          (DCacheIn_hit_0),
        .out2Core_hit_1_o          (DCacheIn_hit_1),
        .out2Core_hit_2_o          (DCacheIn_hit_2),
        .out2Core_hit_3_o          (DCacheIn_hit_3),
        .out2Core_cacheline_0_o    (DCacheIn_cacheline_0),
        .out2Core_cacheline_1_o    (DCacheIn_cacheline_1),
        .out2Core_cacheline_2_o    (DCacheIn_cacheline_2),
        .out2Core_cacheline_3_o    (DCacheIn_cacheline_3),
        .out2Core_writeSuccess_0_o (DCacheIn_writeSuccess_0),
        .out2Core_writeSuccess_1_o (DCacheIn_writeSuccess_1),
        .out2Core_writeSuccess_2_o (DCacheIn_writeSuccess_2),
        .out2Core_writeSuccess_3_o (DCacheIn_writeSuccess_3),
        .out2Core_writeSuccess_MIO_o(DCacheIn_writeSuccess_MIO),
        .out2Core_hit_MIO_o         (DCacheIn_hit_MIO),
        .out2Core_reqServed_MIO_o   (DCacheIn_reqServed_MIO),
        .out2Core_line_MIO_o        (DCacheIn_line_MIO),

        // dma_controller_2_core_t outputs (consumed by core)
        .dma_intOut_o(inFromDMA_intOut)
    );

endmodule
