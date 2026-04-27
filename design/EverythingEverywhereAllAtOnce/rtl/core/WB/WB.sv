import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;


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
                data    : stq_outputs[i].head_data
            };
        end
    end

    //stq to dep check (no MIO)
    always_comb begin
        for(int num_q = 0; num_q < NUM_WB_ST_QS; num_q++)begin
            for(int i = 0; i < ST_Q_DEPTH; i++)begin
                dc_dep.entries[num_q*ST_Q_DEPTH + i] = '{
                    valid   : stq_outputs[num_q].valid[i],
                    address : stq_outputs[num_q].address[i],
                    stq_data: stq_outputs[num_q].data[i]
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


    //Store queue gen
    genvar i;
    for(i = 0; i < NUM_WB_ST_QS; i++)begin : gen_st_q
        STQ_shift stq_inst (
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

