module branch_res(
    input br_info_t br_info_i;
    input l_address_t NEIP_i;
    input uint64_t imm64_i;
    input exe_cs_t cs_i;
    input flags_idx_e flags_i;

    output exe_br_resolution_outputs_t outs_o
);


    assign = '{
        valid: br_info_i.valid,
        flush: 
        miss_prediction:
        br_eip: br_info_i.br_eip,
        neip: NEIP_i
        br_target: 
        taken:
        br_XCL: 
        clr_exp_mode: cs_i.clr_exp_mode,
        br_ucond: br_info_i.br_ucond
    };



    

/*
    typedef struct {
        bool valid;  //we had a br in decode
        bool isFar;  //need to flush fuck it
        bool br_pred_taken;  //if fetch said taken, then high, else low
        l_address_t br_btb_target;  //needed bc target can change if in mem or reg, this is NOT the same as the actual target in EXE res
        l_address_t br_eip;  //for btb entries going back to fetch during br resolution in execute
        //neip not needed ready being sent in latches
    } br_info_t;

*/


endmodule