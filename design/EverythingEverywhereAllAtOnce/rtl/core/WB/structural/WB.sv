import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;


// WB.sv (structural-folder copy)
//
// Currently only ST_Q_logic is the structural port. ST_Q, ST_Q_MIO_logic,
// and MIO_Q are the legacy SystemVerilog implementations.
//
// To enable the next structural port: uncomment that submodule's structural
// block in its .sv file and switch its instantiation here back to flat ports.
//
// The only conversion overhead this file carries is around ST_Q_logic:
//   1. Flatten wb_latches.res_buf (byte_t[32]) into a 256-bit wire bus.
//   2. Per-bank flat output wires for stq_info_<i>_*.
//   3. Pack those flat wires back into the stq_info[i] struct array so the
//      legacy ST_Q instances (which take st_q_inputs_t) are unchanged.

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
    // LEGACY (SV-struct) submodule instantiations -- 3 of 4
    // ===================================================================

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

    //MIO Queue instantiation
    MIO_Q mio_q_inst (
        .clk(clk),
        .rst(rst),
        .mio_input(mio_q_input),
        .push_fail(mio_push_fail),
        .outs(mio_q_output)
    );


endmodule
