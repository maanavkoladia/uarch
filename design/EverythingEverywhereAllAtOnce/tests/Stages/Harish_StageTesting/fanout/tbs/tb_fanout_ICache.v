module tb_fanout_ICache ();

    // ---------------------------------------------------------------
    // Clock / reset
    // ---------------------------------------------------------------
    reg clk;
    reg rst;

    initial clk = 0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------
    // ICache inputs
    // ---------------------------------------------------------------
    reg        icache_icache_en_i;
    reg [14:0] icache_p_addr_i;
    reg [31:0] icache_v_addr_i;
    reg [2:0]  icache_num_valid_IDM_slots_i;

    // ---------------------------------------------------------------
    // ICache outputs
    // ---------------------------------------------------------------
    wire        icache_hit_o;
    wire [127:0] icache_instruction_line_o;

    // ---------------------------------------------------------------
    // DCache load inputs
    // ---------------------------------------------------------------
    reg        core_ld_addr_0_V_i;
    reg [14:0] core_ld_addr_0_i;
    reg        core_ld_addr_1_V_i;
    reg [14:0] core_ld_addr_1_i;

    // ---------------------------------------------------------------
    // DCache store queue inputs
    // ---------------------------------------------------------------
    reg        core_stq_full_0_i;
    reg        core_stq_full_1_i;
    reg        core_stq_full_2_i;
    reg        core_stq_full_3_i;
    reg        core_stq_empty_0_i;
    reg        core_stq_empty_1_i;
    reg        core_stq_empty_2_i;
    reg        core_stq_empty_3_i;
    reg [14:0] core_stq_addr_0_i;
    reg [14:0] core_stq_addr_1_i;
    reg [14:0] core_stq_addr_2_i;
    reg [14:0] core_stq_addr_3_i;
    reg [15:0] core_stq_bitvec_0_i;
    reg [15:0] core_stq_bitvec_1_i;
    reg [15:0] core_stq_bitvec_2_i;
    reg [15:0] core_stq_bitvec_3_i;
    reg [127:0] core_stq_data_0_i;
    reg [127:0] core_stq_data_1_i;
    reg [127:0] core_stq_data_2_i;
    reg [127:0] core_stq_data_3_i;

    // ---------------------------------------------------------------
    // DCache MIO inputs
    // ---------------------------------------------------------------
    reg        core_ld_addr_MIO_V_i;
    reg [14:0] core_ld_addr_MIO_i;
    reg        core_stq_info_mio_empty_i;
    reg [14:0] core_stq_info_mio_addr_i;
    reg [127:0] core_stq_info_mio_data_i;

    // ---------------------------------------------------------------
    // Mem stage clear requests
    // ---------------------------------------------------------------
    reg core_memStage_CLR_REQ_0_i;
    reg core_memStage_CLR_REQ_1_i;
    reg core_memStage_CLR_REQ_2_i;
    reg core_memStage_CLR_REQ_3_i;
    reg core_memStage_CLR_REQ_MIO_i;

    // ---------------------------------------------------------------
    // DCache outputs
    // ---------------------------------------------------------------
    wire        out2Core_reqServed_0_o;
    wire        out2Core_reqServed_1_o;
    wire        out2Core_hit_0_o;
    wire        out2Core_hit_1_o;
    wire        out2Core_hit_2_o;
    wire        out2Core_hit_3_o;
    wire [127:0] out2Core_cacheline_0_o;
    wire [127:0] out2Core_cacheline_1_o;
    wire [127:0] out2Core_cacheline_2_o;
    wire [127:0] out2Core_cacheline_3_o;
    wire        out2Core_writeSuccess_0_o;
    wire        out2Core_writeSuccess_1_o;
    wire        out2Core_writeSuccess_2_o;
    wire        out2Core_writeSuccess_3_o;
    wire        out2Core_writeSuccess_MIO_o;
    wire        out2Core_hit_MIO_o;
    wire        out2Core_reqServed_MIO_o;
    wire [127:0] out2Core_line_MIO_o;

    // ---------------------------------------------------------------
    // DMA output
    // ---------------------------------------------------------------
    wire dma_intOut_o;

    // ---------------------------------------------------------------
    // DUT
    // ---------------------------------------------------------------
    Everywhere_TOP dut (
        .clk(clk),
        .rst(rst),

        .icache_icache_en_i          (icache_icache_en_i),
        .icache_p_addr_i             (icache_p_addr_i),
        .icache_v_addr_i             (icache_v_addr_i),
        .icache_num_valid_IDM_slots_i(icache_num_valid_IDM_slots_i),
        .icache_hit_o                (icache_hit_o),
        .icache_instruction_line_o   (icache_instruction_line_o),

        .core_ld_addr_0_V_i(core_ld_addr_0_V_i),
        .core_ld_addr_0_i  (core_ld_addr_0_i),
        .core_ld_addr_1_V_i(core_ld_addr_1_V_i),
        .core_ld_addr_1_i  (core_ld_addr_1_i),

        .core_stq_full_0_i  (core_stq_full_0_i),
        .core_stq_full_1_i  (core_stq_full_1_i),
        .core_stq_full_2_i  (core_stq_full_2_i),
        .core_stq_full_3_i  (core_stq_full_3_i),
        .core_stq_empty_0_i (core_stq_empty_0_i),
        .core_stq_empty_1_i (core_stq_empty_1_i),
        .core_stq_empty_2_i (core_stq_empty_2_i),
        .core_stq_empty_3_i (core_stq_empty_3_i),
        .core_stq_addr_0_i  (core_stq_addr_0_i),
        .core_stq_addr_1_i  (core_stq_addr_1_i),
        .core_stq_addr_2_i  (core_stq_addr_2_i),
        .core_stq_addr_3_i  (core_stq_addr_3_i),
        .core_stq_bitvec_0_i(core_stq_bitvec_0_i),
        .core_stq_bitvec_1_i(core_stq_bitvec_1_i),
        .core_stq_bitvec_2_i(core_stq_bitvec_2_i),
        .core_stq_bitvec_3_i(core_stq_bitvec_3_i),
        .core_stq_data_0_i  (core_stq_data_0_i),
        .core_stq_data_1_i  (core_stq_data_1_i),
        .core_stq_data_2_i  (core_stq_data_2_i),
        .core_stq_data_3_i  (core_stq_data_3_i),

        .core_ld_addr_MIO_V_i     (core_ld_addr_MIO_V_i),
        .core_ld_addr_MIO_i       (core_ld_addr_MIO_i),
        .core_stq_info_mio_empty_i(core_stq_info_mio_empty_i),
        .core_stq_info_mio_addr_i (core_stq_info_mio_addr_i),
        .core_stq_info_mio_data_i (core_stq_info_mio_data_i),

        .core_memStage_CLR_REQ_0_i  (core_memStage_CLR_REQ_0_i),
        .core_memStage_CLR_REQ_1_i  (core_memStage_CLR_REQ_1_i),
        .core_memStage_CLR_REQ_2_i  (core_memStage_CLR_REQ_2_i),
        .core_memStage_CLR_REQ_3_i  (core_memStage_CLR_REQ_3_i),
        .core_memStage_CLR_REQ_MIO_i(core_memStage_CLR_REQ_MIO_i),

        .out2Core_reqServed_0_o    (out2Core_reqServed_0_o),
        .out2Core_reqServed_1_o    (out2Core_reqServed_1_o),
        .out2Core_hit_0_o          (out2Core_hit_0_o),
        .out2Core_hit_1_o          (out2Core_hit_1_o),
        .out2Core_hit_2_o          (out2Core_hit_2_o),
        .out2Core_hit_3_o          (out2Core_hit_3_o),
        .out2Core_cacheline_0_o    (out2Core_cacheline_0_o),
        .out2Core_cacheline_1_o    (out2Core_cacheline_1_o),
        .out2Core_cacheline_2_o    (out2Core_cacheline_2_o),
        .out2Core_cacheline_3_o    (out2Core_cacheline_3_o),
        .out2Core_writeSuccess_0_o (out2Core_writeSuccess_0_o),
        .out2Core_writeSuccess_1_o (out2Core_writeSuccess_1_o),
        .out2Core_writeSuccess_2_o (out2Core_writeSuccess_2_o),
        .out2Core_writeSuccess_3_o (out2Core_writeSuccess_3_o),
        .out2Core_writeSuccess_MIO_o(out2Core_writeSuccess_MIO_o),
        .out2Core_hit_MIO_o         (out2Core_hit_MIO_o),
        .out2Core_reqServed_MIO_o   (out2Core_reqServed_MIO_o),
        .out2Core_line_MIO_o        (out2Core_line_MIO_o),

        .dma_intOut_o(dma_intOut_o)
    );

    // ---------------------------------------------------------------
    // Stimulus: drive all inputs to 0, assert reset, then release
    // ---------------------------------------------------------------
    initial begin
        rst = 1;
        icache_icache_en_i           = 0;
        icache_p_addr_i              = 0;
        icache_v_addr_i              = 0;
        icache_num_valid_IDM_slots_i = 0;
        core_ld_addr_0_V_i           = 0;
        core_ld_addr_0_i             = 0;
        core_ld_addr_1_V_i           = 0;
        core_ld_addr_1_i             = 0;
        core_stq_full_0_i            = 0;
        core_stq_full_1_i            = 0;
        core_stq_full_2_i            = 0;
        core_stq_full_3_i            = 0;
        core_stq_empty_0_i           = 1;
        core_stq_empty_1_i           = 1;
        core_stq_empty_2_i           = 1;
        core_stq_empty_3_i           = 1;
        core_stq_addr_0_i            = 0;
        core_stq_addr_1_i            = 0;
        core_stq_addr_2_i            = 0;
        core_stq_addr_3_i            = 0;
        core_stq_bitvec_0_i          = 0;
        core_stq_bitvec_1_i          = 0;
        core_stq_bitvec_2_i          = 0;
        core_stq_bitvec_3_i          = 0;
        core_stq_data_0_i            = 0;
        core_stq_data_1_i            = 0;
        core_stq_data_2_i            = 0;
        core_stq_data_3_i            = 0;
        core_ld_addr_MIO_V_i         = 0;
        core_ld_addr_MIO_i           = 0;
        core_stq_info_mio_empty_i    = 1;
        core_stq_info_mio_addr_i     = 0;
        core_stq_info_mio_data_i     = 0;
        core_memStage_CLR_REQ_0_i    = 0;
        core_memStage_CLR_REQ_1_i    = 0;
        core_memStage_CLR_REQ_2_i    = 0;
        core_memStage_CLR_REQ_3_i    = 0;
        core_memStage_CLR_REQ_MIO_i  = 0;

        repeat(4) @(posedge clk);
        rst = 0;

        repeat(20) @(posedge clk);
        $finish;
    end

endmodule
