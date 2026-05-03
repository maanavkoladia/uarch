import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;


// WB.sv (structural-folder copy)
//
// Currently only ST_Q is the structural port. ST_Q_logic, ST_Q_MIO_logic,
// and MIO_Q are the legacy SystemVerilog implementations (their structural
// versions are commented out at the bottom of their respective files).
//
// To enable the next structural port: uncomment that submodule's structural
// block and switch its instantiation here back to flat ports.
//
// The only conversion overhead this file carries is around ST_Q[i]:
//   1. Per-bank: unpack stq_info[i] (st_q_inputs_t) struct into flat wires.
//   2. Per-bank: pack the byte-array data field into a 128-bit bus.
//   3. Per-bank: instantiate the structural ST_Q with flat ports.
//   4. Per-bank: pack flat outputs back into stq_outputs[i] struct so the
//      downstream stq_heads/dc_dep/stall_flop_next code is unchanged.

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
    mio_inputs_t mio_q_input;
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
    // LEGACY (SV-struct) submodule instantiations -- 3 of 4
    // ===================================================================

    //store queue push pop logic
    ST_Q_logic st_q_logic(
        .wb_valid(wb_latches.valid),
        .st_paddr_0(wb_latches.ST_PADDR_0),
        .st_paddr_1(wb_latches.ST_PADDR_1),
        .res_buf(wb_latches.res_buf),
        .bit_vect_0(wb_latches.ST_BIT_VEC_0),
        .bit_vect_1(wb_latches.ST_BIT_VEC_1),
        .ST_OP(wb_latches.cs.ST_OP),
        .ST_XCL(wb_latches.ST_XCL),
        .MIO(wb_latches.MIO),
        .write_success(write_success),

        .stq_info(stq_info)
    );

    //st_q_logic for mio
    ST_Q_MIO_logic st_q_mio_logic(
        .wb_valid(wb_latches.valid),
        .st_paddr_0_mio(wb_latches.ST_PADDR_0),
        .res_buf(wb_latches.res_buf),
        .ST_OP(wb_latches.cs.ST_OP),
        .MIO(wb_latches.MIO),
        .write_success_mio(write_success_mio),
        .mio_q_input_o(mio_q_input)
    );

    //MIO Queue instantiation
    MIO_Q mio_q_inst (
        .clk(clk),
        .rst(rst),
        .mio_input(mio_q_input),
        .push_fail(mio_push_fail),
        .outs(mio_q_output)
    );


    // ===================================================================
    // STRUCTURAL ST_Q INSTANCES (the only ported submodule for now)
    // For each bank i in 0..3 we:
    //   * unpack stq_info[i] struct -> flat input wires
    //   * pack the 16-byte data array -> 128-bit bus
    //   * instantiate the structural ST_Q with flat ports
    //   * pack flat outputs -> stq_outputs[i] struct
    // ===================================================================

    // Per-bank flat input wires (driven from stq_info[i])
    wire         stq_in_0_data_valid,    stq_in_1_data_valid,    stq_in_2_data_valid,    stq_in_3_data_valid;
    wire [14:0]  stq_in_0_data_address,  stq_in_1_data_address,  stq_in_2_data_address,  stq_in_3_data_address;
    wire [15:0]  stq_in_0_data_bit_vec,  stq_in_1_data_bit_vec,  stq_in_2_data_bit_vec,  stq_in_3_data_bit_vec;
    wire [127:0] stq_in_0_data_data,     stq_in_1_data_data,     stq_in_2_data_data,     stq_in_3_data_data;
    wire         stq_in_0_push,          stq_in_1_push,          stq_in_2_push,          stq_in_3_push;
    wire         stq_in_0_pop,           stq_in_1_pop,           stq_in_2_pop,           stq_in_3_pop;

    // Per-bank flat output wires (driven by ST_Q[i])
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

    // -------- Unpack stq_info[i] struct -> per-bank flat input wires --------
    // Scalar fields go through plain assigns. The 16-byte data array is packed
    // into a 128-bit bus byte-by-byte.
    assign stq_in_0_data_valid   = stq_info[0].data.valid;
    assign stq_in_0_data_address = stq_info[0].data.address;
    assign stq_in_0_data_bit_vec = stq_info[0].data.bit_vec;
    assign stq_in_0_push         = stq_info[0].push;
    assign stq_in_0_pop          = stq_info[0].pop;

    assign stq_in_1_data_valid   = stq_info[1].data.valid;
    assign stq_in_1_data_address = stq_info[1].data.address;
    assign stq_in_1_data_bit_vec = stq_info[1].data.bit_vec;
    assign stq_in_1_push         = stq_info[1].push;
    assign stq_in_1_pop          = stq_info[1].pop;

    assign stq_in_2_data_valid   = stq_info[2].data.valid;
    assign stq_in_2_data_address = stq_info[2].data.address;
    assign stq_in_2_data_bit_vec = stq_info[2].data.bit_vec;
    assign stq_in_2_push         = stq_info[2].push;
    assign stq_in_2_pop          = stq_info[2].pop;

    assign stq_in_3_data_valid   = stq_info[3].data.valid;
    assign stq_in_3_data_address = stq_info[3].data.address;
    assign stq_in_3_data_bit_vec = stq_info[3].data.bit_vec;
    assign stq_in_3_push         = stq_info[3].push;
    assign stq_in_3_pop          = stq_info[3].pop;

    genvar bi;
    generate
        for (bi = 0; bi < CACHE_LINES_SIZE_B; bi = bi + 1) begin : g_pack_data_in
            assign stq_in_0_data_data[bi*8 +: 8] = stq_info[0].data.data[bi];
            assign stq_in_1_data_data[bi*8 +: 8] = stq_info[1].data.data[bi];
            assign stq_in_2_data_data[bi*8 +: 8] = stq_info[2].data.data[bi];
            assign stq_in_3_data_data[bi*8 +: 8] = stq_info[3].data.data[bi];
        end
    endgenerate

    // -------- ST_Q x4 (one per bank), all structural --------
    ST_Q stq_inst_0 (
        .clk                  ( clk                     ),
        .rst                  ( rst                     ),
        .wb_in_data_valid     ( stq_in_0_data_valid     ),
        .wb_in_data_address   ( stq_in_0_data_address   ),
        .wb_in_data_bit_vec   ( stq_in_0_data_bit_vec   ),
        .wb_in_data_data      ( stq_in_0_data_data      ),
        .wb_in_push           ( stq_in_0_push           ),
        .wb_in_pop            ( stq_in_0_pop            ),
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
        .wb_in_data_valid     ( stq_in_1_data_valid     ),
        .wb_in_data_address   ( stq_in_1_data_address   ),
        .wb_in_data_bit_vec   ( stq_in_1_data_bit_vec   ),
        .wb_in_data_data      ( stq_in_1_data_data      ),
        .wb_in_push           ( stq_in_1_push           ),
        .wb_in_pop            ( stq_in_1_pop            ),
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
        .wb_in_data_valid     ( stq_in_2_data_valid     ),
        .wb_in_data_address   ( stq_in_2_data_address   ),
        .wb_in_data_bit_vec   ( stq_in_2_data_bit_vec   ),
        .wb_in_data_data      ( stq_in_2_data_data      ),
        .wb_in_push           ( stq_in_2_push           ),
        .wb_in_pop            ( stq_in_2_pop            ),
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
        .wb_in_data_valid     ( stq_in_3_data_valid     ),
        .wb_in_data_address   ( stq_in_3_data_address   ),
        .wb_in_data_bit_vec   ( stq_in_3_data_bit_vec   ),
        .wb_in_data_data      ( stq_in_3_data_data      ),
        .wb_in_push           ( stq_in_3_push           ),
        .wb_in_pop            ( stq_in_3_pop            ),
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

    // -------- Pack flat ST_Q outputs back into stq_outputs[i] structs --------
    // Downstream always_combs (stq_heads, dc_dep, stall_flop_next) read these
    // structs untouched.
    always_comb begin
        // ---- queue 0 ----
        stq_outputs[0].full          = stq_out_0_full;
        stq_outputs[0].empty         = stq_out_0_empty;
        stq_outputs[0].head_address  = stq_out_0_head_address;
        stq_outputs[0].bit_vec       = stq_out_0_bit_vec;
        stq_outputs[0].push_fail     = stq_out_0_push_fail;
        stq_outputs[0].valid[0]      = stq_out_0_valid_0;
        stq_outputs[0].valid[1]      = stq_out_0_valid_1;
        stq_outputs[0].valid[2]      = stq_out_0_valid_2;
        stq_outputs[0].valid[3]      = stq_out_0_valid_3;
        stq_outputs[0].address[0]    = stq_out_0_address_0;
        stq_outputs[0].address[1]    = stq_out_0_address_1;
        stq_outputs[0].address[2]    = stq_out_0_address_2;
        stq_outputs[0].address[3]    = stq_out_0_address_3;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_outputs[0].data[b] = stq_out_0_data[b*8 +: 8];
        end
        // ---- queue 1 ----
        stq_outputs[1].full          = stq_out_1_full;
        stq_outputs[1].empty         = stq_out_1_empty;
        stq_outputs[1].head_address  = stq_out_1_head_address;
        stq_outputs[1].bit_vec       = stq_out_1_bit_vec;
        stq_outputs[1].push_fail     = stq_out_1_push_fail;
        stq_outputs[1].valid[0]      = stq_out_1_valid_0;
        stq_outputs[1].valid[1]      = stq_out_1_valid_1;
        stq_outputs[1].valid[2]      = stq_out_1_valid_2;
        stq_outputs[1].valid[3]      = stq_out_1_valid_3;
        stq_outputs[1].address[0]    = stq_out_1_address_0;
        stq_outputs[1].address[1]    = stq_out_1_address_1;
        stq_outputs[1].address[2]    = stq_out_1_address_2;
        stq_outputs[1].address[3]    = stq_out_1_address_3;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_outputs[1].data[b] = stq_out_1_data[b*8 +: 8];
        end
        // ---- queue 2 ----
        stq_outputs[2].full          = stq_out_2_full;
        stq_outputs[2].empty         = stq_out_2_empty;
        stq_outputs[2].head_address  = stq_out_2_head_address;
        stq_outputs[2].bit_vec       = stq_out_2_bit_vec;
        stq_outputs[2].push_fail     = stq_out_2_push_fail;
        stq_outputs[2].valid[0]      = stq_out_2_valid_0;
        stq_outputs[2].valid[1]      = stq_out_2_valid_1;
        stq_outputs[2].valid[2]      = stq_out_2_valid_2;
        stq_outputs[2].valid[3]      = stq_out_2_valid_3;
        stq_outputs[2].address[0]    = stq_out_2_address_0;
        stq_outputs[2].address[1]    = stq_out_2_address_1;
        stq_outputs[2].address[2]    = stq_out_2_address_2;
        stq_outputs[2].address[3]    = stq_out_2_address_3;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_outputs[2].data[b] = stq_out_2_data[b*8 +: 8];
        end
        // ---- queue 3 ----
        stq_outputs[3].full          = stq_out_3_full;
        stq_outputs[3].empty         = stq_out_3_empty;
        stq_outputs[3].head_address  = stq_out_3_head_address;
        stq_outputs[3].bit_vec       = stq_out_3_bit_vec;
        stq_outputs[3].push_fail     = stq_out_3_push_fail;
        stq_outputs[3].valid[0]      = stq_out_3_valid_0;
        stq_outputs[3].valid[1]      = stq_out_3_valid_1;
        stq_outputs[3].valid[2]      = stq_out_3_valid_2;
        stq_outputs[3].valid[3]      = stq_out_3_valid_3;
        stq_outputs[3].address[0]    = stq_out_3_address_0;
        stq_outputs[3].address[1]    = stq_out_3_address_1;
        stq_outputs[3].address[2]    = stq_out_3_address_2;
        stq_outputs[3].address[3]    = stq_out_3_address_3;
        for (int b = 0; b < CACHE_LINES_SIZE_B; b++) begin
            stq_outputs[3].data[b] = stq_out_3_data[b*8 +: 8];
        end
    end


endmodule
