// WB_structural.v
//
// Pure Verilog-2005 top of the writeback stage. Structurally identical to
// WB_structural.sv (kept on disk as the SV reference) but every SV-only
// construct is gone:
//   * No `import` of any package.
//   * No struct or typedef ports -- wb_latches_t, wb_outputs_t, and
//     bool[NUM_WB_ST_QS] write_success are unrolled into individual flat
//     wires whose widths come straight from the field types.
//   * No unpacked-array ports -- byte arrays (res_buf, stq_heads.data,
//     mio_head.data) are passed as packed buses.
//
// The internal logic, submodule instantiations, and gate-macro use are the
// same as the SV version; the only deletions are the per-byte pack/unpack
// generates that were translating struct byte-arrays to/from packed buses.


module WB (
    input  wire         clk,
    input  wire         rst,

    // ---- wb_latches_t (input) ---------------------------------------------
    input  wire         wb_latches_valid,
    input  wire         wb_latches_cs_ST_OP,
    input  wire         wb_latches_cs_WB_DR,
    input  wire         wb_latches_cs_WB_SR,
    input  wire         wb_latches_cs_WB_EAX,
    input  wire         wb_latches_ST_XCL,
    input  wire [14:0]  wb_latches_ST_PADDR_0,
    input  wire [15:0]  wb_latches_ST_BIT_VEC_0,
    input  wire [14:0]  wb_latches_ST_PADDR_1,
    input  wire [15:0]  wb_latches_ST_BIT_VEC_1,
    input  wire         wb_latches_MIO,
    input  wire [31:0]  wb_latches_EIP,
    input  wire [255:0] wb_latches_res_buf,           // CACHE_LINES_SIZE_B*2 bytes, byte 0 in [7:0]
    input  wire [4:0]   wb_latches_sr_id,
    input  wire [63:0]  wb_latches_sr_data,
    input  wire [4:0]   wb_latches_dr_id,
    input  wire [63:0]  wb_latches_dr_data,
    input  wire [31:0]  wb_latches_EAX,

    // ---- bool write_success[NUM_WB_ST_QS] + write_success_mio --------------
    input  wire         write_success_0,
    input  wire         write_success_1,
    input  wire         write_success_2,
    input  wire         write_success_3,
    input  wire         write_success_mio,

    // ---- wb_outputs_t scalars ---------------------------------------------
    output wire         outputs_valid,
    output wire         outputs_wb_stall,
    output wire         outputs_ST_OP,
    output wire         outputs_ST_XCL,
    output wire [14:0]  outputs_ST_PADDR_0,
    output wire [14:0]  outputs_ST_PADDR_1,

    // ---- wb_outputs_t.stq_heads[0..3] (st_q_2_dcache_t) -------------------
    output wire         outputs_stq_head_0_full,
    output wire         outputs_stq_head_0_empty,
    output wire [14:0]  outputs_stq_head_0_address,
    output wire [15:0]  outputs_stq_head_0_bit_vec,
    output wire [127:0] outputs_stq_head_0_data,

    output wire         outputs_stq_head_1_full,
    output wire         outputs_stq_head_1_empty,
    output wire [14:0]  outputs_stq_head_1_address,
    output wire [15:0]  outputs_stq_head_1_bit_vec,
    output wire [127:0] outputs_stq_head_1_data,

    output wire         outputs_stq_head_2_full,
    output wire         outputs_stq_head_2_empty,
    output wire [14:0]  outputs_stq_head_2_address,
    output wire [15:0]  outputs_stq_head_2_bit_vec,
    output wire [127:0] outputs_stq_head_2_data,

    output wire         outputs_stq_head_3_full,
    output wire         outputs_stq_head_3_empty,
    output wire [14:0]  outputs_stq_head_3_address,
    output wire [15:0]  outputs_stq_head_3_bit_vec,
    output wire [127:0] outputs_stq_head_3_data,

    // ---- wb_outputs_t.mio_head -------------------------------------------
    output wire         outputs_mio_head_full,
    output wire         outputs_mio_head_empty,
    output wire [14:0]  outputs_mio_head_address,
    output wire [15:0]  outputs_mio_head_bit_vec,
    output wire [127:0] outputs_mio_head_data,

    // ---- wb_outputs_t.dep_check.entries[0..15] ----------------------------
    output wire         outputs_dep_check_entry_0_valid,
    output wire [14:0]  outputs_dep_check_entry_0_address,
    output wire         outputs_dep_check_entry_1_valid,
    output wire [14:0]  outputs_dep_check_entry_1_address,
    output wire         outputs_dep_check_entry_2_valid,
    output wire [14:0]  outputs_dep_check_entry_2_address,
    output wire         outputs_dep_check_entry_3_valid,
    output wire [14:0]  outputs_dep_check_entry_3_address,
    output wire         outputs_dep_check_entry_4_valid,
    output wire [14:0]  outputs_dep_check_entry_4_address,
    output wire         outputs_dep_check_entry_5_valid,
    output wire [14:0]  outputs_dep_check_entry_5_address,
    output wire         outputs_dep_check_entry_6_valid,
    output wire [14:0]  outputs_dep_check_entry_6_address,
    output wire         outputs_dep_check_entry_7_valid,
    output wire [14:0]  outputs_dep_check_entry_7_address,
    output wire         outputs_dep_check_entry_8_valid,
    output wire [14:0]  outputs_dep_check_entry_8_address,
    output wire         outputs_dep_check_entry_9_valid,
    output wire [14:0]  outputs_dep_check_entry_9_address,
    output wire         outputs_dep_check_entry_10_valid,
    output wire [14:0]  outputs_dep_check_entry_10_address,
    output wire         outputs_dep_check_entry_11_valid,
    output wire [14:0]  outputs_dep_check_entry_11_address,
    output wire         outputs_dep_check_entry_12_valid,
    output wire [14:0]  outputs_dep_check_entry_12_address,
    output wire         outputs_dep_check_entry_13_valid,
    output wire [14:0]  outputs_dep_check_entry_13_address,
    output wire         outputs_dep_check_entry_14_valid,
    output wire [14:0]  outputs_dep_check_entry_14_address,
    output wire         outputs_dep_check_entry_15_valid,
    output wire [14:0]  outputs_dep_check_entry_15_address
);


    wire stall_flop_next;
    wire mio_push_fail;


    // ===================================================================
    // STRUCTURAL ST_Q_logic
    //   - Flat per-bank output wires feed ST_Q[i] flat inputs DIRECTLY
    // ===================================================================
    wire         stq_info_0_push, stq_info_0_pop, stq_info_0_data_valid;
    wire [14:0]  stq_info_0_data_address;
    wire [15:0]  stq_info_0_data_bit_vec;
    wire [127:0] stq_info_0_data_data;

    wire         stq_info_1_push, stq_info_1_pop, stq_info_1_data_valid;
    wire [14:0]  stq_info_1_data_address;
    wire [15:0]  stq_info_1_data_bit_vec;
    wire [127:0] stq_info_1_data_data;

    wire         stq_info_2_push, stq_info_2_pop, stq_info_2_data_valid;
    wire [14:0]  stq_info_2_data_address;
    wire [15:0]  stq_info_2_data_bit_vec;
    wire [127:0] stq_info_2_data_data;

    wire         stq_info_3_push, stq_info_3_pop, stq_info_3_data_valid;
    wire [14:0]  stq_info_3_data_address;
    wire [15:0]  stq_info_3_data_bit_vec;
    wire [127:0] stq_info_3_data_data;

    ST_Q_logic st_q_logic (
        .wb_valid                ( wb_latches_valid        ),
        .st_paddr_0              ( wb_latches_ST_PADDR_0   ),
        .st_paddr_1              ( wb_latches_ST_PADDR_1   ),
        .res_buf                 ( wb_latches_res_buf      ),
        .bit_vect_0              ( wb_latches_ST_BIT_VEC_0 ),
        .bit_vect_1              ( wb_latches_ST_BIT_VEC_1 ),
        .ST_OP                   ( wb_latches_cs_ST_OP     ),
        .ST_XCL                  ( wb_latches_ST_XCL       ),
        .MIO                     ( wb_latches_MIO          ),
        .write_success_0         ( write_success_0         ),
        .write_success_1         ( write_success_1         ),
        .write_success_2         ( write_success_2         ),
        .write_success_3         ( write_success_3         ),

        .stq_info_0_push         ( stq_info_0_push         ),
        .stq_info_0_pop          ( stq_info_0_pop          ),
        .stq_info_0_data_valid   ( stq_info_0_data_valid   ),
        .stq_info_0_data_address ( stq_info_0_data_address ),
        .stq_info_0_data_bit_vec ( stq_info_0_data_bit_vec ),
        .stq_info_0_data_data    ( stq_info_0_data_data    ),

        .stq_info_1_push         ( stq_info_1_push         ),
        .stq_info_1_pop          ( stq_info_1_pop          ),
        .stq_info_1_data_valid   ( stq_info_1_data_valid   ),
        .stq_info_1_data_address ( stq_info_1_data_address ),
        .stq_info_1_data_bit_vec ( stq_info_1_data_bit_vec ),
        .stq_info_1_data_data    ( stq_info_1_data_data    ),

        .stq_info_2_push         ( stq_info_2_push         ),
        .stq_info_2_pop          ( stq_info_2_pop          ),
        .stq_info_2_data_valid   ( stq_info_2_data_valid   ),
        .stq_info_2_data_address ( stq_info_2_data_address ),
        .stq_info_2_data_bit_vec ( stq_info_2_data_bit_vec ),
        .stq_info_2_data_data    ( stq_info_2_data_data    ),

        .stq_info_3_push         ( stq_info_3_push         ),
        .stq_info_3_pop          ( stq_info_3_pop          ),
        .stq_info_3_data_valid   ( stq_info_3_data_valid   ),
        .stq_info_3_data_address ( stq_info_3_data_address ),
        .stq_info_3_data_bit_vec ( stq_info_3_data_bit_vec ),
        .stq_info_3_data_data    ( stq_info_3_data_data    )
    );


    // ===================================================================
    // STRUCTURAL ST_Q x4
    // ===================================================================
    wire         stq_out_0_full, stq_out_0_empty, stq_out_0_push_fail;
    wire         stq_out_0_valid_0, stq_out_0_valid_1, stq_out_0_valid_2, stq_out_0_valid_3;
    wire [14:0]  stq_out_0_address_0, stq_out_0_address_1, stq_out_0_address_2, stq_out_0_address_3;
    wire [14:0]  stq_out_0_head_address;
    wire [15:0]  stq_out_0_bit_vec;
    wire [127:0] stq_out_0_data;

    wire         stq_out_1_full, stq_out_1_empty, stq_out_1_push_fail;
    wire         stq_out_1_valid_0, stq_out_1_valid_1, stq_out_1_valid_2, stq_out_1_valid_3;
    wire [14:0]  stq_out_1_address_0, stq_out_1_address_1, stq_out_1_address_2, stq_out_1_address_3;
    wire [14:0]  stq_out_1_head_address;
    wire [15:0]  stq_out_1_bit_vec;
    wire [127:0] stq_out_1_data;

    wire         stq_out_2_full, stq_out_2_empty, stq_out_2_push_fail;
    wire         stq_out_2_valid_0, stq_out_2_valid_1, stq_out_2_valid_2, stq_out_2_valid_3;
    wire [14:0]  stq_out_2_address_0, stq_out_2_address_1, stq_out_2_address_2, stq_out_2_address_3;
    wire [14:0]  stq_out_2_head_address;
    wire [15:0]  stq_out_2_bit_vec;
    wire [127:0] stq_out_2_data;

    wire         stq_out_3_full, stq_out_3_empty, stq_out_3_push_fail;
    wire         stq_out_3_valid_0, stq_out_3_valid_1, stq_out_3_valid_2, stq_out_3_valid_3;
    wire [14:0]  stq_out_3_address_0, stq_out_3_address_1, stq_out_3_address_2, stq_out_3_address_3;
    wire [14:0]  stq_out_3_head_address;
    wire [15:0]  stq_out_3_bit_vec;
    wire [127:0] stq_out_3_data;

    ST_Q stq_inst_0 (
        .clk                  ( clk                     ),
        .rst                  ( rst                     ),
        .wb_in_data_valid     ( stq_info_0_data_valid   ),
        .wb_in_data_address   ( stq_info_0_data_address ),
        .wb_in_data_bit_vec   ( stq_info_0_data_bit_vec ),
        .wb_in_data_data      ( stq_info_0_data_data    ),
        .wb_in_push           ( stq_info_0_push         ),
        .wb_in_pop            ( stq_info_0_pop          ),
        .outputs_full         ( stq_out_0_full          ),
        .outputs_empty        ( stq_out_0_empty         ),
        .outputs_valid_0      ( stq_out_0_valid_0       ),
        .outputs_valid_1      ( stq_out_0_valid_1       ),
        .outputs_valid_2      ( stq_out_0_valid_2       ),
        .outputs_valid_3      ( stq_out_0_valid_3       ),
        .outputs_address_0    ( stq_out_0_address_0     ),
        .outputs_address_1    ( stq_out_0_address_1     ),
        .outputs_address_2    ( stq_out_0_address_2     ),
        .outputs_address_3    ( stq_out_0_address_3     ),
        .outputs_head_address ( stq_out_0_head_address  ),
        .outputs_bit_vec      ( stq_out_0_bit_vec       ),
        .outputs_data         ( stq_out_0_data          ),
        .outputs_push_fail    ( stq_out_0_push_fail     )
    );

    ST_Q stq_inst_1 (
        .clk                  ( clk                     ),
        .rst                  ( rst                     ),
        .wb_in_data_valid     ( stq_info_1_data_valid   ),
        .wb_in_data_address   ( stq_info_1_data_address ),
        .wb_in_data_bit_vec   ( stq_info_1_data_bit_vec ),
        .wb_in_data_data      ( stq_info_1_data_data    ),
        .wb_in_push           ( stq_info_1_push         ),
        .wb_in_pop            ( stq_info_1_pop          ),
        .outputs_full         ( stq_out_1_full          ),
        .outputs_empty        ( stq_out_1_empty         ),
        .outputs_valid_0      ( stq_out_1_valid_0       ),
        .outputs_valid_1      ( stq_out_1_valid_1       ),
        .outputs_valid_2      ( stq_out_1_valid_2       ),
        .outputs_valid_3      ( stq_out_1_valid_3       ),
        .outputs_address_0    ( stq_out_1_address_0     ),
        .outputs_address_1    ( stq_out_1_address_1     ),
        .outputs_address_2    ( stq_out_1_address_2     ),
        .outputs_address_3    ( stq_out_1_address_3     ),
        .outputs_head_address ( stq_out_1_head_address  ),
        .outputs_bit_vec      ( stq_out_1_bit_vec       ),
        .outputs_data         ( stq_out_1_data          ),
        .outputs_push_fail    ( stq_out_1_push_fail     )
    );

    ST_Q stq_inst_2 (
        .clk                  ( clk                     ),
        .rst                  ( rst                     ),
        .wb_in_data_valid     ( stq_info_2_data_valid   ),
        .wb_in_data_address   ( stq_info_2_data_address ),
        .wb_in_data_bit_vec   ( stq_info_2_data_bit_vec ),
        .wb_in_data_data      ( stq_info_2_data_data    ),
        .wb_in_push           ( stq_info_2_push         ),
        .wb_in_pop            ( stq_info_2_pop          ),
        .outputs_full         ( stq_out_2_full          ),
        .outputs_empty        ( stq_out_2_empty         ),
        .outputs_valid_0      ( stq_out_2_valid_0       ),
        .outputs_valid_1      ( stq_out_2_valid_1       ),
        .outputs_valid_2      ( stq_out_2_valid_2       ),
        .outputs_valid_3      ( stq_out_2_valid_3       ),
        .outputs_address_0    ( stq_out_2_address_0     ),
        .outputs_address_1    ( stq_out_2_address_1     ),
        .outputs_address_2    ( stq_out_2_address_2     ),
        .outputs_address_3    ( stq_out_2_address_3     ),
        .outputs_head_address ( stq_out_2_head_address  ),
        .outputs_bit_vec      ( stq_out_2_bit_vec       ),
        .outputs_data         ( stq_out_2_data          ),
        .outputs_push_fail    ( stq_out_2_push_fail     )
    );

    ST_Q stq_inst_3 (
        .clk                  ( clk                     ),
        .rst                  ( rst                     ),
        .wb_in_data_valid     ( stq_info_3_data_valid   ),
        .wb_in_data_address   ( stq_info_3_data_address ),
        .wb_in_data_bit_vec   ( stq_info_3_data_bit_vec ),
        .wb_in_data_data      ( stq_info_3_data_data    ),
        .wb_in_push           ( stq_info_3_push         ),
        .wb_in_pop            ( stq_info_3_pop          ),
        .outputs_full         ( stq_out_3_full          ),
        .outputs_empty        ( stq_out_3_empty         ),
        .outputs_valid_0      ( stq_out_3_valid_0       ),
        .outputs_valid_1      ( stq_out_3_valid_1       ),
        .outputs_valid_2      ( stq_out_3_valid_2       ),
        .outputs_valid_3      ( stq_out_3_valid_3       ),
        .outputs_address_0    ( stq_out_3_address_0     ),
        .outputs_address_1    ( stq_out_3_address_1     ),
        .outputs_address_2    ( stq_out_3_address_2     ),
        .outputs_address_3    ( stq_out_3_address_3     ),
        .outputs_head_address ( stq_out_3_head_address  ),
        .outputs_bit_vec      ( stq_out_3_bit_vec       ),
        .outputs_data         ( stq_out_3_data          ),
        .outputs_push_fail    ( stq_out_3_push_fail     )
    );


    // ===================================================================
    // outputs_stq_head_i_* driven directly from ST_Q[i] flat outputs
    // ===================================================================
    assign outputs_stq_head_0_full    = stq_out_0_full;
    assign outputs_stq_head_0_empty   = stq_out_0_empty;
    assign outputs_stq_head_0_address = stq_out_0_head_address;
    assign outputs_stq_head_0_bit_vec = stq_out_0_bit_vec;
    assign outputs_stq_head_0_data    = stq_out_0_data;

    assign outputs_stq_head_1_full    = stq_out_1_full;
    assign outputs_stq_head_1_empty   = stq_out_1_empty;
    assign outputs_stq_head_1_address = stq_out_1_head_address;
    assign outputs_stq_head_1_bit_vec = stq_out_1_bit_vec;
    assign outputs_stq_head_1_data    = stq_out_1_data;

    assign outputs_stq_head_2_full    = stq_out_2_full;
    assign outputs_stq_head_2_empty   = stq_out_2_empty;
    assign outputs_stq_head_2_address = stq_out_2_head_address;
    assign outputs_stq_head_2_bit_vec = stq_out_2_bit_vec;
    assign outputs_stq_head_2_data    = stq_out_2_data;

    assign outputs_stq_head_3_full    = stq_out_3_full;
    assign outputs_stq_head_3_empty   = stq_out_3_empty;
    assign outputs_stq_head_3_address = stq_out_3_head_address;
    assign outputs_stq_head_3_bit_vec = stq_out_3_bit_vec;
    assign outputs_stq_head_3_data    = stq_out_3_data;


    // ===================================================================
    // outputs_dep_check_entry_k_* driven directly from ST_Q flat outputs
    //   entries[0..3]   <- bank 0, slots 0..3
    //   entries[4..7]   <- bank 1, slots 0..3
    //   entries[8..11]  <- bank 2, slots 0..3
    //   entries[12..15] <- bank 3, slots 0..3
    // ===================================================================
    assign outputs_dep_check_entry_0_valid    = stq_out_0_valid_0;
    assign outputs_dep_check_entry_0_address  = stq_out_0_address_0;
    assign outputs_dep_check_entry_1_valid    = stq_out_0_valid_1;
    assign outputs_dep_check_entry_1_address  = stq_out_0_address_1;
    assign outputs_dep_check_entry_2_valid    = stq_out_0_valid_2;
    assign outputs_dep_check_entry_2_address  = stq_out_0_address_2;
    assign outputs_dep_check_entry_3_valid    = stq_out_0_valid_3;
    assign outputs_dep_check_entry_3_address  = stq_out_0_address_3;

    assign outputs_dep_check_entry_4_valid    = stq_out_1_valid_0;
    assign outputs_dep_check_entry_4_address  = stq_out_1_address_0;
    assign outputs_dep_check_entry_5_valid    = stq_out_1_valid_1;
    assign outputs_dep_check_entry_5_address  = stq_out_1_address_1;
    assign outputs_dep_check_entry_6_valid    = stq_out_1_valid_2;
    assign outputs_dep_check_entry_6_address  = stq_out_1_address_2;
    assign outputs_dep_check_entry_7_valid    = stq_out_1_valid_3;
    assign outputs_dep_check_entry_7_address  = stq_out_1_address_3;

    assign outputs_dep_check_entry_8_valid    = stq_out_2_valid_0;
    assign outputs_dep_check_entry_8_address  = stq_out_2_address_0;
    assign outputs_dep_check_entry_9_valid    = stq_out_2_valid_1;
    assign outputs_dep_check_entry_9_address  = stq_out_2_address_1;
    assign outputs_dep_check_entry_10_valid   = stq_out_2_valid_2;
    assign outputs_dep_check_entry_10_address = stq_out_2_address_2;
    assign outputs_dep_check_entry_11_valid   = stq_out_2_valid_3;
    assign outputs_dep_check_entry_11_address = stq_out_2_address_3;

    assign outputs_dep_check_entry_12_valid   = stq_out_3_valid_0;
    assign outputs_dep_check_entry_12_address = stq_out_3_address_0;
    assign outputs_dep_check_entry_13_valid   = stq_out_3_valid_1;
    assign outputs_dep_check_entry_13_address = stq_out_3_address_1;
    assign outputs_dep_check_entry_14_valid   = stq_out_3_valid_2;
    assign outputs_dep_check_entry_14_address = stq_out_3_address_2;
    assign outputs_dep_check_entry_15_valid   = stq_out_3_valid_3;
    assign outputs_dep_check_entry_15_address = stq_out_3_address_3;


    // ===================================================================
    // STRUCTURAL ST_Q_MIO_logic + MIO_Q
    // ===================================================================
    wire         mio_q_input_o_data_valid;
    wire [14:0]  mio_q_input_o_data_address;
    wire [127:0] mio_q_input_o_data_data;
    wire         mio_q_input_o_push;
    wire         mio_q_input_o_pop;

    ST_Q_MIO_logic st_q_mio_logic (
        .wb_valid                   ( wb_latches_valid           ),
        .st_paddr_0_mio             ( wb_latches_ST_PADDR_0      ),
        .res_buf                    ( wb_latches_res_buf         ),
        .ST_OP                      ( wb_latches_cs_ST_OP        ),
        .MIO                        ( wb_latches_MIO             ),
        .write_success_mio          ( write_success_mio          ),

        .mio_q_input_o_data_valid   ( mio_q_input_o_data_valid   ),
        .mio_q_input_o_data_address ( mio_q_input_o_data_address ),
        .mio_q_input_o_data_data    ( mio_q_input_o_data_data    ),
        .mio_q_input_o_push         ( mio_q_input_o_push         ),
        .mio_q_input_o_pop          ( mio_q_input_o_pop          )
    );

    wire         mio_q_full_w;
    wire         mio_q_empty_w;
    wire [14:0]  mio_q_address_w;
    wire [15:0]  mio_q_bit_vec_w;
    wire [127:0] mio_q_data_w;

    MIO_Q mio_q_inst (
        .clk                    ( clk                        ),
        .rst                    ( rst                        ),
        .mio_input_data_valid   ( mio_q_input_o_data_valid   ),
        .mio_input_data_address ( mio_q_input_o_data_address ),
        .mio_input_data_data    ( mio_q_input_o_data_data    ),
        .mio_input_push         ( mio_q_input_o_push         ),
        .mio_input_pop          ( mio_q_input_o_pop          ),
        .push_fail              ( mio_push_fail              ),
        .outs_full              ( mio_q_full_w               ),
        .outs_empty             ( mio_q_empty_w              ),
        .outs_address           ( mio_q_address_w            ),
        .outs_bit_vec           ( mio_q_bit_vec_w            ),
        .outs_data              ( mio_q_data_w               )
    );

    assign outputs_mio_head_full    = mio_q_full_w;
    assign outputs_mio_head_empty   = mio_q_empty_w;
    assign outputs_mio_head_address = mio_q_address_w;
    assign outputs_mio_head_bit_vec = mio_q_bit_vec_w;
    assign outputs_mio_head_data    = mio_q_data_w;


    // ===================================================================
    // Stall logic: 5-input OR of all push_fail signals
    //
    // The OR_5 result drives outputs_wb_stall, which is consumed by ~6
    // external loads (stall sinks across the core). Insert a bufferH16$
    // between the OR_5 output and the module port so the wire-driver-of-
    // record is a buffer cell (which is rated for 16 fanout) rather than
    // the internal nand3 inside OR_5 (which is fanout-limited).
    // ===================================================================
    `OR_5(u_stall_or, 1, stall_flop_next,
          stq_out_0_push_fail, stq_out_1_push_fail,
          stq_out_2_push_fail, stq_out_3_push_fail,
          mio_push_fail)

    wire stall_flop_next_buf;
    bufferH16$ u_stall_buf (.out(stall_flop_next_buf), .in(stall_flop_next));


    // ===================================================================
    // Scalar outputs
    // ===================================================================
    assign outputs_valid      = wb_latches_valid;
    assign outputs_wb_stall   = stall_flop_next_buf;
    assign outputs_ST_OP      = wb_latches_cs_ST_OP;
    assign outputs_ST_XCL     = wb_latches_ST_XCL;
    assign outputs_ST_PADDR_0 = wb_latches_ST_PADDR_0;
    assign outputs_ST_PADDR_1 = wb_latches_ST_PADDR_1;


endmodule
