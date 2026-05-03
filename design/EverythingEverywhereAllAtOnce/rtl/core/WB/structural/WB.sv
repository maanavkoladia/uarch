import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;


// WB.sv (structural-folder copy)
//
// All four submodules (ST_Q_logic, ST_Q_MIO_logic, ST_Q, MIO_Q) are pure
// structural. WB.sv internally is now also structural -- it contains only
// continuous `assign` statements (for wire renaming and struct-field
// connectivity), `generate`-for blocks (for byte-array unpacks), and
// gate-macro instantiations from STDCell_Macros.vh. NO always_comb / no
// always_ff blocks remain.
//
// What was kept SV (per the user, for clean parent-stage integration):
//   * The module port list still uses SystemVerilog struct types
//     (wb_latches_t, wb_outputs_t, bool[]) -- the parent stage / top-level
//     wiring expects these types.
//   * Output struct fields are driven via continuous assigns to
//     `outputs.<field>` -- a wire-level connection, not behavioral logic.
//   * The unused `reg_wb_logic_outputs_t reg_wb_logic_outs;` declaration
//     is preserved (placeholder for a future submodule).
//   * The legacy `stall_flop` register and its always_ff are kept commented
//     out at the bottom of the module (currently unused -- wb_stall is
//     driven combinationally from stall_flop_next).
//
// What changed from the previous (SV-internals) version:
//   * Three always_comb blocks (stq_heads pack, dc_dep pack, stall OR-tree)
//     are gone. Each output bit is now driven by a single continuous
//     assign (or, for byte arrays, a generate-for of byte assigns).
//   * The OR-reduction `stall_flop_next |= ...` over the four ST_Q
//     push_fail signals plus mio_push_fail is now a single OR_5 gate.
//   * The `assign outputs = '{...}` struct literal is split into per-field
//     continuous assigns.
//   * The intermediate struct buffers (stq_outputs[i], stq_heads[i],
//     mio_q_output, dc_dep) are gone -- outputs.<field> is driven directly
//     from the flat submodule wires.

module WB (
    input wire clk,
    input wire rst,

    input wb_latches_t wb_latches,

    //D$ write success for st_qs
    input bool write_success[NUM_WB_ST_QS],

    input bool write_success_mio,

    output wb_outputs_t outputs
);


    bool stall_flop_next;
    bool mio_push_fail;
    reg_wb_logic_outputs_t reg_wb_logic_outs;   // unused, kept for compat


    // ===================================================================
    // Flatten wb_latches.res_buf (byte_t[32]) into a 256-bit bus, shared
    // by ST_Q_logic and ST_Q_MIO_logic.
    // ===================================================================
    wire [255:0] res_buf_flat;
    genvar       j;
    generate
        for (j = 0; j < CACHE_LINES_SIZE_B*2; j = j + 1) begin : g_resbuf_pack
            assign res_buf_flat[j*8 +: 8] = wb_latches.res_buf[j];
        end
    endgenerate


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
        .wb_valid                ( wb_latches.valid        ),
        .st_paddr_0              ( wb_latches.ST_PADDR_0   ),
        .st_paddr_1              ( wb_latches.ST_PADDR_1   ),
        .res_buf                 ( res_buf_flat            ),
        .bit_vect_0              ( wb_latches.ST_BIT_VEC_0 ),
        .bit_vect_1              ( wb_latches.ST_BIT_VEC_1 ),
        .ST_OP                   ( wb_latches.cs.ST_OP     ),
        .ST_XCL                  ( wb_latches.ST_XCL       ),
        .MIO                     ( wb_latches.MIO          ),
        .write_success_0         ( write_success[0]        ),
        .write_success_1         ( write_success[1]        ),
        .write_success_2         ( write_success[2]        ),
        .write_success_3         ( write_success[3]        ),

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
    //   Per-bank flat output wires feed outputs.stq_heads[i] and
    //   outputs.dep_check.entries[i*4 + j] directly via continuous assigns
    //   (further down in the file).
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
    // outputs.stq_heads[0..3] driven directly from ST_Q[i] flat outputs
    // (replaces the legacy `stq_heads` always_comb).
    // ===================================================================
    // ---- bank 0 ----
    assign outputs.stq_heads[0].full    = stq_out_0_full;
    assign outputs.stq_heads[0].empty   = stq_out_0_empty;
    assign outputs.stq_heads[0].address = stq_out_0_head_address;
    assign outputs.stq_heads[0].bit_vec = stq_out_0_bit_vec;
    genvar bd0;
    generate
        for (bd0 = 0; bd0 < CACHE_LINES_SIZE_B; bd0 = bd0 + 1) begin : g_oh_d_0
            assign outputs.stq_heads[0].data[bd0] = stq_out_0_data[bd0*8 +: 8];
        end
    endgenerate
    // ---- bank 1 ----
    assign outputs.stq_heads[1].full    = stq_out_1_full;
    assign outputs.stq_heads[1].empty   = stq_out_1_empty;
    assign outputs.stq_heads[1].address = stq_out_1_head_address;
    assign outputs.stq_heads[1].bit_vec = stq_out_1_bit_vec;
    genvar bd1;
    generate
        for (bd1 = 0; bd1 < CACHE_LINES_SIZE_B; bd1 = bd1 + 1) begin : g_oh_d_1
            assign outputs.stq_heads[1].data[bd1] = stq_out_1_data[bd1*8 +: 8];
        end
    endgenerate
    // ---- bank 2 ----
    assign outputs.stq_heads[2].full    = stq_out_2_full;
    assign outputs.stq_heads[2].empty   = stq_out_2_empty;
    assign outputs.stq_heads[2].address = stq_out_2_head_address;
    assign outputs.stq_heads[2].bit_vec = stq_out_2_bit_vec;
    genvar bd2;
    generate
        for (bd2 = 0; bd2 < CACHE_LINES_SIZE_B; bd2 = bd2 + 1) begin : g_oh_d_2
            assign outputs.stq_heads[2].data[bd2] = stq_out_2_data[bd2*8 +: 8];
        end
    endgenerate
    // ---- bank 3 ----
    assign outputs.stq_heads[3].full    = stq_out_3_full;
    assign outputs.stq_heads[3].empty   = stq_out_3_empty;
    assign outputs.stq_heads[3].address = stq_out_3_head_address;
    assign outputs.stq_heads[3].bit_vec = stq_out_3_bit_vec;
    genvar bd3;
    generate
        for (bd3 = 0; bd3 < CACHE_LINES_SIZE_B; bd3 = bd3 + 1) begin : g_oh_d_3
            assign outputs.stq_heads[3].data[bd3] = stq_out_3_data[bd3*8 +: 8];
        end
    endgenerate


    // ===================================================================
    // outputs.dep_check.entries[k] driven directly from ST_Q flat outputs
    // (replaces the legacy `dc_dep` always_comb).
    //
    // Index mapping (matches legacy num_q*ST_Q_DEPTH + i):
    //   entries[0..3]   <- bank 0, slots 0..3
    //   entries[4..7]   <- bank 1, slots 0..3
    //   entries[8..11]  <- bank 2, slots 0..3
    //   entries[12..15] <- bank 3, slots 0..3
    // ===================================================================
    // ---- bank 0 ----
    assign outputs.dep_check.entries[0 ].valid   = stq_out_0_valid_0;
    assign outputs.dep_check.entries[0 ].address = stq_out_0_address_0;
    assign outputs.dep_check.entries[1 ].valid   = stq_out_0_valid_1;
    assign outputs.dep_check.entries[1 ].address = stq_out_0_address_1;
    assign outputs.dep_check.entries[2 ].valid   = stq_out_0_valid_2;
    assign outputs.dep_check.entries[2 ].address = stq_out_0_address_2;
    assign outputs.dep_check.entries[3 ].valid   = stq_out_0_valid_3;
    assign outputs.dep_check.entries[3 ].address = stq_out_0_address_3;
    // ---- bank 1 ----
    assign outputs.dep_check.entries[4 ].valid   = stq_out_1_valid_0;
    assign outputs.dep_check.entries[4 ].address = stq_out_1_address_0;
    assign outputs.dep_check.entries[5 ].valid   = stq_out_1_valid_1;
    assign outputs.dep_check.entries[5 ].address = stq_out_1_address_1;
    assign outputs.dep_check.entries[6 ].valid   = stq_out_1_valid_2;
    assign outputs.dep_check.entries[6 ].address = stq_out_1_address_2;
    assign outputs.dep_check.entries[7 ].valid   = stq_out_1_valid_3;
    assign outputs.dep_check.entries[7 ].address = stq_out_1_address_3;
    // ---- bank 2 ----
    assign outputs.dep_check.entries[8 ].valid   = stq_out_2_valid_0;
    assign outputs.dep_check.entries[8 ].address = stq_out_2_address_0;
    assign outputs.dep_check.entries[9 ].valid   = stq_out_2_valid_1;
    assign outputs.dep_check.entries[9 ].address = stq_out_2_address_1;
    assign outputs.dep_check.entries[10].valid   = stq_out_2_valid_2;
    assign outputs.dep_check.entries[10].address = stq_out_2_address_2;
    assign outputs.dep_check.entries[11].valid   = stq_out_2_valid_3;
    assign outputs.dep_check.entries[11].address = stq_out_2_address_3;
    // ---- bank 3 ----
    assign outputs.dep_check.entries[12].valid   = stq_out_3_valid_0;
    assign outputs.dep_check.entries[12].address = stq_out_3_address_0;
    assign outputs.dep_check.entries[13].valid   = stq_out_3_valid_1;
    assign outputs.dep_check.entries[13].address = stq_out_3_address_1;
    assign outputs.dep_check.entries[14].valid   = stq_out_3_valid_2;
    assign outputs.dep_check.entries[14].address = stq_out_3_address_2;
    assign outputs.dep_check.entries[15].valid   = stq_out_3_valid_3;
    assign outputs.dep_check.entries[15].address = stq_out_3_address_3;


    // ===================================================================
    // STRUCTURAL ST_Q_MIO_logic + MIO_Q
    //   - ST_Q_MIO_logic reuses res_buf_flat from above
    //   - Its flat outputs feed MIO_Q's flat inputs DIRECTLY (no struct
    //     intermediate -- both endpoints are structural)
    //   - MIO_Q's flat outputs drive outputs.mio_head.* directly (replaces
    //     the legacy `mio_q_output` always_comb)
    // ===================================================================
    wire         mio_q_input_o_data_valid;
    wire [14:0]  mio_q_input_o_data_address;
    wire [127:0] mio_q_input_o_data_data;
    wire         mio_q_input_o_push;
    wire         mio_q_input_o_pop;

    ST_Q_MIO_logic st_q_mio_logic (
        .wb_valid                   ( wb_latches.valid           ),
        .st_paddr_0_mio             ( wb_latches.ST_PADDR_0      ),
        .res_buf                    ( res_buf_flat               ),
        .ST_OP                      ( wb_latches.cs.ST_OP        ),
        .MIO                        ( wb_latches.MIO             ),
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

    // Drive outputs.mio_head from MIO_Q flat outputs
    assign outputs.mio_head.full    = mio_q_full_w;
    assign outputs.mio_head.empty   = mio_q_empty_w;
    assign outputs.mio_head.address = mio_q_address_w;
    assign outputs.mio_head.bit_vec = mio_q_bit_vec_w;
    genvar bdm;
    generate
        for (bdm = 0; bdm < CACHE_LINES_SIZE_B; bdm = bdm + 1) begin : g_oh_d_mio
            assign outputs.mio_head.data[bdm] = mio_q_data_w[bdm*8 +: 8];
        end
    endgenerate


    // ===================================================================
    // Stall logic: 5-input OR of all push_fail signals
    // (replaces the legacy `stall_flop_next |= ...` reduction loop)
    // ===================================================================
    `OR_5(u_stall_or, 1, stall_flop_next,
          stq_out_0_push_fail, stq_out_1_push_fail,
          stq_out_2_push_fail, stq_out_3_push_fail,
          mio_push_fail)


    // ===================================================================
    // Scalar outputs (per-field continuous assigns -- replaces the
    // legacy `assign outputs = '{...}` struct literal).
    //   wb_stall is currently driven combinationally from stall_flop_next
    //   (the registered stall_flop is commented out at the bottom).
    // ===================================================================
    assign outputs.valid      = wb_latches.valid;
    assign outputs.wb_stall   = stall_flop_next;
    assign outputs.ST_OP      = wb_latches.cs.ST_OP;
    assign outputs.ST_XCL     = wb_latches.ST_XCL;
    assign outputs.ST_PADDR_0 = wb_latches.ST_PADDR_0;
    assign outputs.ST_PADDR_1 = wb_latches.ST_PADDR_1;


    // ===================================================================
    // Legacy stall_flop register (kept commented out -- not used).
    // wb_stall is sourced from the combinational stall_flop_next above.
    // ===================================================================
    //bool stall_flop;
    //always_ff @(posedge clk) begin
    //    if (!rst) stall_flop <= 0;
    //    else stall_flop <= stall_flop_next;
    //end


endmodule
