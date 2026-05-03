import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;


// WB.sv (structural-folder copy)
//
// Currently ST_Q_logic, ST_Q_MIO_logic, and MIO_Q are structural ports.
// Only ST_Q (the 4-deep store-queue FIFO) is still the legacy SystemVerilog
// implementation.
//
// To enable the next structural port: uncomment that submodule's structural
// block in its .sv file and switch its instantiation here back to flat ports.
//
// Conversion overhead this file carries:
//   1. Flatten wb_latches.res_buf (byte_t[32]) into a 256-bit wire bus,
//      shared by ST_Q_logic and ST_Q_MIO_logic.
//   2. Per-bank flat output wires for stq_info_<i>_* (ST_Q_logic) and flat
//      wires for the ST_Q_MIO_logic -> MIO_Q link.
//   3. Pack ST_Q_logic flat outputs into the stq_info[i] struct array so the
//      legacy ST_Q[i] generate loop (which takes st_q_inputs_t) is unchanged.
//   4. Pack MIO_Q flat outputs into mio_q_output (st_q_2_dcache_t) so the
//      wb_outputs assembly (which sets `mio_head : mio_q_output`) is
//      unchanged.

module WB (
    input wire clk,
    input wire rst,

    input wb_latches_t wb_latches,

    //D$ write success for st_qs
    input bool write_success[NUM_WB_ST_QS],

    input bool write_success_mio,

    output wb_outputs_t outputs
);


    bool stall_flop;
    bool stall_flop_next;
    bool mio_push_fail;

    st_q_inputs_t stq_info[NUM_WB_ST_QS];
    st_q_outputs_t stq_outputs[NUM_WB_ST_QS];
    reg_wb_logic_outputs_t reg_wb_logic_outs;

    st_q_2_dep_check_outputs_t dc_dep;
    st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];
    st_q_2_dcache_t mio_q_output;


    //stq 2 dcache (non MIO)
    always_comb begin
        for(int i =0; i < NUM_WB_ST_QS; i++)begin
            stq_heads[i] = '{
                full    : stq_outputs[i].full,
                empty   : stq_outputs[i].empty,
                address : stq_outputs[i].head_address,
                bit_vec : stq_outputs[i].bit_vec,
                data    : stq_outputs[i].data
            };
        end
    end

    //stq to dep check (no MIO)
    always_comb begin
        for(int num_q = 0; num_q < NUM_WB_ST_QS; num_q++)begin
            for(int i = 0; i < ST_Q_DEPTH; i++)begin
                dc_dep.entries[num_q*ST_Q_DEPTH + i] = '{
                    valid   : stq_outputs[num_q].valid[i],
                    address : stq_outputs[num_q].address[i]
                };
            end
        end
    end

    //stall logic
    always_comb begin
        stall_flop_next = 1'b0;
        for (int i = 0; i < NUM_WB_ST_QS; i++) begin
            stall_flop_next |= stq_outputs[i].push_fail;  // or whatever signal you need
        end
        stall_flop_next |= mio_push_fail;
    end

    //WB outputs
    assign outputs = '{
        valid : wb_latches.valid,
        wb_stall : stall_flop_next,

        //to DCACHE
        stq_heads : stq_heads,
        mio_head : mio_q_output,

        dep_check : dc_dep,

        ST_OP : wb_latches.cs.ST_OP,
        ST_XCL : wb_latches.ST_XCL,  //valid bit or second set of st info if st_o : ,
        ST_PADDR_0: wb_latches.ST_PADDR_0,  //cacheline algne :
        ST_PADDR_1 : wb_latches.ST_PADDR_1 //cacheline algne : ,
    };

    //stall mask logic for SB and wb
    always_ff @(posedge clk)begin
        if(!rst) stall_flop <=0;
        else stall_flop <= stall_flop_next;
    end


    // ===================================================================
    // STRUCTURAL ST_Q_logic (the only ported submodule for now)
    //   - Flatten wb_latches.res_buf byte array -> 256-bit bus
    //   - Instantiate with flat ports
    //   - Pack flat per-bank output wires back into stq_info[i] struct
    // ===================================================================

    // -------- Flatten res_buf byte array --------
    wire [255:0] res_buf_flat;
    genvar       j;
    generate
        for (j = 0; j < CACHE_LINES_SIZE_B*2; j = j + 1) begin : g_resbuf_pack
            assign res_buf_flat[j*8 +: 8] = wb_latches.res_buf[j];
        end
    endgenerate

    // -------- Per-bank flat output wires from ST_Q_logic --------
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

    // -------- ST_Q_logic instantiation (flat ports) --------
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

    // -------- Pack flat ST_Q_logic outputs into stq_info[i] structs --------
    // The 128-bit data bus is unpacked back into a byte array so legacy ST_Q
    // (which takes st_q_inputs_t) is unchanged.
    always_comb begin
        // ---- queue 0 ----
        stq_info[0].push            = stq_info_0_push;
        stq_info[0].pop             = stq_info_0_pop;
        stq_info[0].data.valid      = stq_info_0_data_valid;
        stq_info[0].data.address    = stq_info_0_data_address;
        stq_info[0].data.bit_vec    = stq_info_0_data_bit_vec;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_info[0].data.data[b] = stq_info_0_data_data[b*8 +: 8];
        end
        // ---- queue 1 ----
        stq_info[1].push            = stq_info_1_push;
        stq_info[1].pop             = stq_info_1_pop;
        stq_info[1].data.valid      = stq_info_1_data_valid;
        stq_info[1].data.address    = stq_info_1_data_address;
        stq_info[1].data.bit_vec    = stq_info_1_data_bit_vec;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_info[1].data.data[b] = stq_info_1_data_data[b*8 +: 8];
        end
        // ---- queue 2 ----
        stq_info[2].push            = stq_info_2_push;
        stq_info[2].pop             = stq_info_2_pop;
        stq_info[2].data.valid      = stq_info_2_data_valid;
        stq_info[2].data.address    = stq_info_2_data_address;
        stq_info[2].data.bit_vec    = stq_info_2_data_bit_vec;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_info[2].data.data[b] = stq_info_2_data_data[b*8 +: 8];
        end
        // ---- queue 3 ----
        stq_info[3].push            = stq_info_3_push;
        stq_info[3].pop             = stq_info_3_pop;
        stq_info[3].data.valid      = stq_info_3_data_valid;
        stq_info[3].data.address    = stq_info_3_data_address;
        stq_info[3].data.bit_vec    = stq_info_3_data_bit_vec;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_info[3].data.data[b] = stq_info_3_data_data[b*8 +: 8];
        end
    end


    // ===================================================================
    // STRUCTURAL ST_Q_MIO_logic + MIO_Q
    //   - ST_Q_MIO_logic reuses res_buf_flat from above
    //   - Its flat outputs feed MIO_Q's flat inputs DIRECTLY (no struct
    //     intermediate -- mio_q_input was a legacy-MIO_Q artifact and is
    //     no longer needed now that both endpoints are structural).
    //   - MIO_Q's flat outputs are packed back into mio_q_output
    //     (st_q_2_dcache_t) so the wb_outputs assembly stays unchanged.
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

    // MIO_Q flat output wires
    wire         mio_q_full_w;
    wire         mio_q_empty_w;
    wire [14:0]  mio_q_address_w;
    wire [15:0]  mio_q_bit_vec_w;
    wire [127:0] mio_q_data_w;

    MIO_Q mio_q_inst (
        .clk                    ( clk                        ),
        .rst                    ( rst                        ),
        // direct flat-to-flat connection from ST_Q_MIO_logic outputs
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

    // -------- Pack flat MIO_Q outputs into mio_q_output struct --------
    always_comb begin
        mio_q_output.full    = mio_q_full_w;
        mio_q_output.empty   = mio_q_empty_w;
        mio_q_output.address = mio_q_address_w;
        mio_q_output.bit_vec = mio_q_bit_vec_w;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            mio_q_output.data[b] = mio_q_data_w[b*8 +: 8];
        end
    end


    // ===================================================================
    // LEGACY (SV-struct) submodule instantiations -- 1 of 4
    // ===================================================================

    //Store queue gen
    genvar i;
    for(i = 0; i < NUM_WB_ST_QS; i++)begin : gen_st_q
        ST_Q stq_inst (
            .clk(clk),
            .rst(rst),
            .wb_in(stq_info[i]),
            .outputs(stq_outputs[i])
        );
    end


endmodule
