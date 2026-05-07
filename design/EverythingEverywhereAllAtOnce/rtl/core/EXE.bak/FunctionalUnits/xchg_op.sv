module xchg_op(
    input  uint64_t srA, //AX or EAX or RM
    input uint64_t srB,   //r32
    input logic [4:0] srA_id,
    input logic [4:0] srB_id,
    input st_op,
    input logic[3:0] data_size,
    input logic [3:0] sr_data_size_vec,
    output uint64_t res_buf,
    output uint64_t dr_o, //AX EAX RM
    output uint64_t sr_o //R32
);

    bool same_id;
    assign same_id = !st_op && (srA_id == srB_id);

    uint32_t new_rm_value;
    uint32_t new_r32_val;
    uint32_t merged_value;

    logic [7:0] new_rm_low_sel;
    logic [7:0] new_rm_upper_sel;
    logic [7:0] new_r32_low_sel;
    logic [7:0] new_r32_upper_sel;

    assign new_rm_low_sel    = sr_data_size_vec[0] ? srB[7:0]  : srB[15:8];
    assign new_rm_upper_sel  = sr_data_size_vec[1] ? srB[15:8] : srB[7:0];

    assign new_r32_low_sel   = data_size[0] ? srA[7:0]  : srA[15:8];
    assign new_r32_upper_sel = data_size[1] ? srA[15:8] : srA[7:0];

    // Independent results — correct when operands are in different registers
    assign new_rm_value[7:0]   = data_size[0] ? new_rm_low_sel   : srA[7:0];
    assign new_rm_value[15:8]  = data_size[1] ? new_rm_upper_sel : srA[15:8];
    assign new_rm_value[31:16] = data_size[2] ? srB[31:16]       : srA[31:16];

    assign new_r32_val[7:0]   = sr_data_size_vec[0] ? new_r32_low_sel   : srB[7:0];
    assign new_r32_val[15:8]  = sr_data_size_vec[1] ? new_r32_upper_sel : srB[15:8];
    assign new_r32_val[31:16] = sr_data_size_vec[2] ? srA[31:16]        : srB[31:16];

    // Merged result for same-register xchg (e.g. xchg AH, AL):
    // DR-target slot takes from new_rm_value, SR-target slot takes from new_r32_val,
    // remaining slots keep srA unchanged. Both dr_o and sr_o get this single value.
    assign merged_value[7:0]   = data_size[0]        ? new_rm_value[7:0]   :
                                  sr_data_size_vec[0] ? new_r32_val[7:0]   :
                                  srA[7:0];
    assign merged_value[15:8]  = data_size[1]        ? new_rm_value[15:8]  :
                                  sr_data_size_vec[1] ? new_r32_val[15:8]  :
                                  srA[15:8];
    assign merged_value[31:16] = data_size[2]        ? new_rm_value[31:16] :
                                  sr_data_size_vec[2] ? new_r32_val[31:16] :
                                  srA[31:16];

    assign res_buf = {32'd0, new_rm_value};
    assign dr_o    = same_id ? {32'd0, merged_value} : {32'd0, new_rm_value};
    assign sr_o    = same_id ? {32'd0, merged_value} : {32'd0, new_r32_val};



endmodule
