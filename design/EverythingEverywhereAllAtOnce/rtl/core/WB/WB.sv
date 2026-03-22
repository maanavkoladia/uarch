import core_common_pkg::*;
import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;
import interconnect_pkg::*;

module WB (
    input wire clk,
    input wire rst,

    input wb_latches_t wb_latches,

    //D$ write success for st_qs
    input bool write_Success[NUM_WB_ST_QS],

    output wb_outputs_t outputs
);

    //NEED TO DO MMIO!!!!
    
    bool stall_flop;
    bool stall_flop_next;

    st_q_inputs_t stq_info[NUM_WB_ST_QS];
    st_q_outputs_t stq_outputs[NUM_WB_ST_QS];
    reg_wb_logic_outputs_t reg_wb_logic_outs;
    st_q_2_dep_check_outputs_t dc_dep;
    st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];
    bool st_override_array[NUM_WB_ST_QS];


    //stq 2 dcache
    always_comb begin
        for(int i =0; i < NUM_WB_ST_QS; i++)begin
            stq_heads[i] = '{
                full    : stq_outputs[i].full,
                empty   : stq_outputs[i].empty,
                address : stq_outputs[i].head_address,
                bit_vec : stq_outputs[i].bit_vec,
                data    : stq_outputs[i].data
            };
            st_override_array[i] = stq_outputs[i].st_override;
        end
    end

    //stq to dep check
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
    end

    //WB outputs
    assign outputs = '{
        valid : wb_latches.valid,
        wb_stall : stall_flop_next,
        DR_0_we : reg_wb_logic_outs.dr0_we,
        DR_0_id : reg_wb_logic_outs.dr0_id,
        DR_0_data : reg_wb_logic_outs.dr0_data,

        DR_1_we : reg_wb_logic_outs.dr1_we,
        DR_1_id : reg_wb_logic_outs.dr1_id,
        DR_1_data : reg_wb_logic_outs.dr1_data,

        st_override : st_override_array,
        stq_heads : stq_heads,
        dep_check : dc_dep
    };

    //stall mask logic for SB and wb
    always_ff @(posedge clk)begin
        if(rst) stall_flop <=0;
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
        .write_success(write_Success),

        .stq_info(stq_info)
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

    //reg writeback logic
    reg_wb_logic reg_wb(
        .reg_info(wb_latches),
        .stall_flop(stall_flop),
        .outs(reg_wb_logic_outs)
    );



endmodule

