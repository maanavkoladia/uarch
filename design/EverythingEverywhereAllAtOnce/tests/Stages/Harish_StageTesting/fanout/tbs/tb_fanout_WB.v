`timescale 1ns/1ps

module tb_fanout_WB ();

    // ----------------------------------------------------------------
    // Clock / reset
    // ----------------------------------------------------------------
    reg clk;
    reg rst;

    initial clk = 0;
    always #4 clk = ~clk;

    // ----------------------------------------------------------------
    // WB inputs -- wb_latches_t
    // ----------------------------------------------------------------
    reg         wb_latches_valid;
    reg         wb_latches_cs_ST_OP;
    reg         wb_latches_cs_WB_DR;
    reg         wb_latches_cs_WB_SR;
    reg         wb_latches_cs_WB_EAX;
    reg         wb_latches_ST_XCL;
    reg [14:0]  wb_latches_ST_PADDR_0;
    reg [15:0]  wb_latches_ST_BIT_VEC_0;
    reg [14:0]  wb_latches_ST_PADDR_1;
    reg [15:0]  wb_latches_ST_BIT_VEC_1;
    reg         wb_latches_MIO;
    reg [31:0]  wb_latches_EIP;
    reg [255:0] wb_latches_res_buf;
    reg [4:0]   wb_latches_sr_id;
    reg [63:0]  wb_latches_sr_data;
    reg [4:0]   wb_latches_dr_id;
    reg [63:0]  wb_latches_dr_data;
    reg [31:0]  wb_latches_EAX;

    // ----------------------------------------------------------------
    // WB inputs -- write_success
    // ----------------------------------------------------------------
    reg         write_success_0;
    reg         write_success_1;
    reg         write_success_2;
    reg         write_success_3;
    reg         write_success_mio;

    // ----------------------------------------------------------------
    // WB outputs -- scalar
    // ----------------------------------------------------------------
    wire         outputs_valid;
    wire         outputs_wb_stall;
    wire         outputs_ST_OP;
    wire         outputs_ST_XCL;
    wire [14:0]  outputs_ST_PADDR_0;
    wire [14:0]  outputs_ST_PADDR_1;

    // ----------------------------------------------------------------
    // WB outputs -- stq_heads
    // ----------------------------------------------------------------
    wire         outputs_stq_head_0_full;
    wire         outputs_stq_head_0_empty;
    wire [14:0]  outputs_stq_head_0_address;
    wire [15:0]  outputs_stq_head_0_bit_vec;
    wire [127:0] outputs_stq_head_0_data;

    wire         outputs_stq_head_1_full;
    wire         outputs_stq_head_1_empty;
    wire [14:0]  outputs_stq_head_1_address;
    wire [15:0]  outputs_stq_head_1_bit_vec;
    wire [127:0] outputs_stq_head_1_data;

    wire         outputs_stq_head_2_full;
    wire         outputs_stq_head_2_empty;
    wire [14:0]  outputs_stq_head_2_address;
    wire [15:0]  outputs_stq_head_2_bit_vec;
    wire [127:0] outputs_stq_head_2_data;

    wire         outputs_stq_head_3_full;
    wire         outputs_stq_head_3_empty;
    wire [14:0]  outputs_stq_head_3_address;
    wire [15:0]  outputs_stq_head_3_bit_vec;
    wire [127:0] outputs_stq_head_3_data;

    // ----------------------------------------------------------------
    // WB outputs -- mio_head
    // ----------------------------------------------------------------
    wire         outputs_mio_head_full;
    wire         outputs_mio_head_empty;
    wire [14:0]  outputs_mio_head_address;
    wire [15:0]  outputs_mio_head_bit_vec;
    wire [127:0] outputs_mio_head_data;

    // ----------------------------------------------------------------
    // WB outputs -- dep_check entries [0..15]
    // ----------------------------------------------------------------
    wire         outputs_dep_check_entry_0_valid;
    wire [14:0]  outputs_dep_check_entry_0_address;
    wire         outputs_dep_check_entry_1_valid;
    wire [14:0]  outputs_dep_check_entry_1_address;
    wire         outputs_dep_check_entry_2_valid;
    wire [14:0]  outputs_dep_check_entry_2_address;
    wire         outputs_dep_check_entry_3_valid;
    wire [14:0]  outputs_dep_check_entry_3_address;
    wire         outputs_dep_check_entry_4_valid;
    wire [14:0]  outputs_dep_check_entry_4_address;
    wire         outputs_dep_check_entry_5_valid;
    wire [14:0]  outputs_dep_check_entry_5_address;
    wire         outputs_dep_check_entry_6_valid;
    wire [14:0]  outputs_dep_check_entry_6_address;
    wire         outputs_dep_check_entry_7_valid;
    wire [14:0]  outputs_dep_check_entry_7_address;
    wire         outputs_dep_check_entry_8_valid;
    wire [14:0]  outputs_dep_check_entry_8_address;
    wire         outputs_dep_check_entry_9_valid;
    wire [14:0]  outputs_dep_check_entry_9_address;
    wire         outputs_dep_check_entry_10_valid;
    wire [14:0]  outputs_dep_check_entry_10_address;
    wire         outputs_dep_check_entry_11_valid;
    wire [14:0]  outputs_dep_check_entry_11_address;
    wire         outputs_dep_check_entry_12_valid;
    wire [14:0]  outputs_dep_check_entry_12_address;
    wire         outputs_dep_check_entry_13_valid;
    wire [14:0]  outputs_dep_check_entry_13_address;
    wire         outputs_dep_check_entry_14_valid;
    wire [14:0]  outputs_dep_check_entry_14_address;
    wire         outputs_dep_check_entry_15_valid;
    wire [14:0]  outputs_dep_check_entry_15_address;

    // ----------------------------------------------------------------
    // DUT instantiation
    // ----------------------------------------------------------------
    WB uut (
        .clk                              ( clk                              ),
        .rst                              ( rst                              ),

        .wb_latches_valid                 ( wb_latches_valid                 ),
        .wb_latches_cs_ST_OP              ( wb_latches_cs_ST_OP              ),
        .wb_latches_cs_WB_DR              ( wb_latches_cs_WB_DR              ),
        .wb_latches_cs_WB_SR              ( wb_latches_cs_WB_SR              ),
        .wb_latches_cs_WB_EAX             ( wb_latches_cs_WB_EAX             ),
        .wb_latches_ST_XCL                ( wb_latches_ST_XCL                ),
        .wb_latches_ST_PADDR_0            ( wb_latches_ST_PADDR_0            ),
        .wb_latches_ST_BIT_VEC_0          ( wb_latches_ST_BIT_VEC_0          ),
        .wb_latches_ST_PADDR_1            ( wb_latches_ST_PADDR_1            ),
        .wb_latches_ST_BIT_VEC_1          ( wb_latches_ST_BIT_VEC_1          ),
        .wb_latches_MIO                   ( wb_latches_MIO                   ),
        .wb_latches_EIP                   ( wb_latches_EIP                   ),
        .wb_latches_res_buf               ( wb_latches_res_buf               ),
        .wb_latches_sr_id                 ( wb_latches_sr_id                 ),
        .wb_latches_sr_data               ( wb_latches_sr_data               ),
        .wb_latches_dr_id                 ( wb_latches_dr_id                 ),
        .wb_latches_dr_data               ( wb_latches_dr_data               ),
        .wb_latches_EAX                   ( wb_latches_EAX                   ),

        .write_success_0                  ( write_success_0                  ),
        .write_success_1                  ( write_success_1                  ),
        .write_success_2                  ( write_success_2                  ),
        .write_success_3                  ( write_success_3                  ),
        .write_success_mio                ( write_success_mio                ),

        .outputs_valid                    ( outputs_valid                    ),
        .outputs_wb_stall                 ( outputs_wb_stall                 ),
        .outputs_ST_OP                    ( outputs_ST_OP                    ),
        .outputs_ST_XCL                   ( outputs_ST_XCL                   ),
        .outputs_ST_PADDR_0               ( outputs_ST_PADDR_0               ),
        .outputs_ST_PADDR_1               ( outputs_ST_PADDR_1               ),

        .outputs_stq_head_0_full          ( outputs_stq_head_0_full          ),
        .outputs_stq_head_0_empty         ( outputs_stq_head_0_empty         ),
        .outputs_stq_head_0_address       ( outputs_stq_head_0_address       ),
        .outputs_stq_head_0_bit_vec       ( outputs_stq_head_0_bit_vec       ),
        .outputs_stq_head_0_data          ( outputs_stq_head_0_data          ),

        .outputs_stq_head_1_full          ( outputs_stq_head_1_full          ),
        .outputs_stq_head_1_empty         ( outputs_stq_head_1_empty         ),
        .outputs_stq_head_1_address       ( outputs_stq_head_1_address       ),
        .outputs_stq_head_1_bit_vec       ( outputs_stq_head_1_bit_vec       ),
        .outputs_stq_head_1_data          ( outputs_stq_head_1_data          ),

        .outputs_stq_head_2_full          ( outputs_stq_head_2_full          ),
        .outputs_stq_head_2_empty         ( outputs_stq_head_2_empty         ),
        .outputs_stq_head_2_address       ( outputs_stq_head_2_address       ),
        .outputs_stq_head_2_bit_vec       ( outputs_stq_head_2_bit_vec       ),
        .outputs_stq_head_2_data          ( outputs_stq_head_2_data          ),

        .outputs_stq_head_3_full          ( outputs_stq_head_3_full          ),
        .outputs_stq_head_3_empty         ( outputs_stq_head_3_empty         ),
        .outputs_stq_head_3_address       ( outputs_stq_head_3_address       ),
        .outputs_stq_head_3_bit_vec       ( outputs_stq_head_3_bit_vec       ),
        .outputs_stq_head_3_data          ( outputs_stq_head_3_data          ),

        .outputs_mio_head_full            ( outputs_mio_head_full            ),
        .outputs_mio_head_empty           ( outputs_mio_head_empty           ),
        .outputs_mio_head_address         ( outputs_mio_head_address         ),
        .outputs_mio_head_bit_vec         ( outputs_mio_head_bit_vec         ),
        .outputs_mio_head_data            ( outputs_mio_head_data            ),

        .outputs_dep_check_entry_0_valid   ( outputs_dep_check_entry_0_valid   ),
        .outputs_dep_check_entry_0_address ( outputs_dep_check_entry_0_address ),
        .outputs_dep_check_entry_1_valid   ( outputs_dep_check_entry_1_valid   ),
        .outputs_dep_check_entry_1_address ( outputs_dep_check_entry_1_address ),
        .outputs_dep_check_entry_2_valid   ( outputs_dep_check_entry_2_valid   ),
        .outputs_dep_check_entry_2_address ( outputs_dep_check_entry_2_address ),
        .outputs_dep_check_entry_3_valid   ( outputs_dep_check_entry_3_valid   ),
        .outputs_dep_check_entry_3_address ( outputs_dep_check_entry_3_address ),
        .outputs_dep_check_entry_4_valid   ( outputs_dep_check_entry_4_valid   ),
        .outputs_dep_check_entry_4_address ( outputs_dep_check_entry_4_address ),
        .outputs_dep_check_entry_5_valid   ( outputs_dep_check_entry_5_valid   ),
        .outputs_dep_check_entry_5_address ( outputs_dep_check_entry_5_address ),
        .outputs_dep_check_entry_6_valid   ( outputs_dep_check_entry_6_valid   ),
        .outputs_dep_check_entry_6_address ( outputs_dep_check_entry_6_address ),
        .outputs_dep_check_entry_7_valid   ( outputs_dep_check_entry_7_valid   ),
        .outputs_dep_check_entry_7_address ( outputs_dep_check_entry_7_address ),
        .outputs_dep_check_entry_8_valid   ( outputs_dep_check_entry_8_valid   ),
        .outputs_dep_check_entry_8_address ( outputs_dep_check_entry_8_address ),
        .outputs_dep_check_entry_9_valid   ( outputs_dep_check_entry_9_valid   ),
        .outputs_dep_check_entry_9_address ( outputs_dep_check_entry_9_address ),
        .outputs_dep_check_entry_10_valid  ( outputs_dep_check_entry_10_valid  ),
        .outputs_dep_check_entry_10_address( outputs_dep_check_entry_10_address),
        .outputs_dep_check_entry_11_valid  ( outputs_dep_check_entry_11_valid  ),
        .outputs_dep_check_entry_11_address( outputs_dep_check_entry_11_address),
        .outputs_dep_check_entry_12_valid  ( outputs_dep_check_entry_12_valid  ),
        .outputs_dep_check_entry_12_address( outputs_dep_check_entry_12_address),
        .outputs_dep_check_entry_13_valid  ( outputs_dep_check_entry_13_valid  ),
        .outputs_dep_check_entry_13_address( outputs_dep_check_entry_13_address),
        .outputs_dep_check_entry_14_valid  ( outputs_dep_check_entry_14_valid  ),
        .outputs_dep_check_entry_14_address( outputs_dep_check_entry_14_address),
        .outputs_dep_check_entry_15_valid  ( outputs_dep_check_entry_15_valid  ),
        .outputs_dep_check_entry_15_address( outputs_dep_check_entry_15_address)
    );

    // ----------------------------------------------------------------
    // Stimulus
    // ----------------------------------------------------------------
    initial begin
        rst = 0;
        wb_latches_valid      = 0;
        wb_latches_cs_ST_OP   = 0;
        wb_latches_cs_WB_DR   = 0;
        wb_latches_cs_WB_SR   = 0;
        wb_latches_cs_WB_EAX  = 0;
        wb_latches_ST_XCL     = 0;
        wb_latches_ST_PADDR_0 = 0;
        wb_latches_ST_BIT_VEC_0 = 0;
        wb_latches_ST_PADDR_1 = 0;
        wb_latches_ST_BIT_VEC_1 = 0;
        wb_latches_MIO        = 0;
        wb_latches_EIP        = 0;
        wb_latches_res_buf    = 0;
        wb_latches_sr_id      = 0;
        wb_latches_sr_data    = 0;
        wb_latches_dr_id      = 0;
        wb_latches_dr_data    = 0;
        wb_latches_EAX        = 0;
        write_success_0       = 0;
        write_success_1       = 0;
        write_success_2       = 0;
        write_success_3       = 0;
        write_success_mio     = 0;

        #10 rst = 1;
        #200 $finish;
    end

endmodule
