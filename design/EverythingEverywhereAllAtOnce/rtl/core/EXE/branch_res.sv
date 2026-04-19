import common_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;

module branch_res(
//br_info
    input bool stage_valid_i,
    input bool br_info_valid_i,
    input l_address_t br_eip_i,
    input bool br_xcl_i,

    //prediction info
    input bool br_pred_taken_i,
    input l_address_t speculative_target_i,

    //exe_cs
    input bool br_ucond_i,
    input bool relative_branch_i,
    input bool special_br_i,
    input bool is_far_i,
    input bool is_call_i,
    input bool second_flag_needed_i,

//from exe stage
    input uint32_t br_source_i,
    input l_address_t NEIP_i,
    input l_address_t br_rel_target,
    input bool CF,
    input bool ZF,

    output exe_br_resolution_outputs_t outs_o
);

    bool valid;
    l_address_t br_target;
    bool taken;
    bool clr_exp_mode;
    bool flush;

    bool miss_prediction;

    bool second_flag_result;
    bool cond_br_res;
    bool target_match;

    assign valid = stage_valid_i & br_info_valid_i;
    //taken logic
    assign second_flag_result = second_flag_needed_i ? ~CF : 1'b1; //mux
    assign cond_br_res = ~ZF & second_flag_result;
    assign taken = (br_ucond_i || cond_br_res) & valid;

    bool farFlush, callFlush;
    assign farFlush = is_far_i & valid;
    assign callFlush = is_call_i & valid;

    //target logic
    assign br_target = relative_branch_i ? (br_rel_target) : br_source_i;

    //target match check
    assign target_match = speculative_target_i == br_target;

    //misprediction logic
    always_comb begin
        miss_prediction = ((taken ^ br_pred_taken_i) |
                           (taken & br_pred_taken_i & ~target_match) |
                           (farFlush | callFlush)
                          ) & valid;

        flush = miss_prediction;
    end

    assign clr_exp_mode = special_br_i & valid;

assign outs_o = '{
        valid: valid,
        flush: flush,
        farFlush: farFlush,
        callFlush: callFlush,
        miss_prediction: miss_prediction,
        br_eip: br_eip_i,
        neip: NEIP_i,
        br_target: br_target,
        taken: taken,
        br_XCL: br_xcl_i,
        clr_exp_mode: clr_exp_mode,
        br_ucond: br_ucond_i
    };


endmodule