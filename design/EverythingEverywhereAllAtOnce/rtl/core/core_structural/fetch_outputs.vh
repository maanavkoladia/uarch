`define FETCH_OUTPUTS \
    wire        fetch_outputs_fetch_2_icache_icache_en; \
    wire [14:0] fetch_outputs_fetch_2_icache_p_addr; \
    wire [31:0] fetch_outputs_fetch_2_icache_v_addr_i; \
    wire [2:0]  fetch_outputs_fetch_2_icache_num_valid_IDM_slots; \
    wire        fetch_outputs_idm_reqs_req_0_ld_meta_data; \
    wire        fetch_outputs_idm_reqs_req_0_ld_data; \
    wire        fetch_outputs_idm_reqs_req_0_valid; \
    wire        fetch_outputs_idm_reqs_req_0_br_valid; \
    wire [31:0] fetch_outputs_idm_reqs_req_0_br_eip; \
    wire [31:0] fetch_outputs_idm_reqs_req_0_br_target; \
    wire        fetch_outputs_idm_reqs_req_0_br_xcl; \
    wire [127:0] fetch_outputs_idm_reqs_req_0_data; \
    wire        fetch_outputs_idm_reqs_req_1_ld_meta_data; \
    wire        fetch_outputs_idm_reqs_req_1_ld_data; \
    wire        fetch_outputs_idm_reqs_req_1_valid; \
    wire        fetch_outputs_idm_reqs_req_1_br_valid; \
    wire [31:0] fetch_outputs_idm_reqs_req_1_br_eip; \
    wire [31:0] fetch_outputs_idm_reqs_req_1_br_target; \
    wire        fetch_outputs_idm_reqs_req_1_br_xcl; \
    wire [127:0] fetch_outputs_idm_reqs_req_1_data; \
    wire        fetch_outputs_idm_reqs_req_2_ld_meta_data; \
    wire        fetch_outputs_idm_reqs_req_2_ld_data; \
    wire        fetch_outputs_idm_reqs_req_2_valid; \
    wire        fetch_outputs_idm_reqs_req_2_br_valid; \
    wire [31:0] fetch_outputs_idm_reqs_req_2_br_eip; \
    wire [31:0] fetch_outputs_idm_reqs_req_2_br_target; \
    wire        fetch_outputs_idm_reqs_req_2_br_xcl; \
    wire [127:0] fetch_outputs_idm_reqs_req_2_data; \
    wire        fetch_outputs_idm_reqs_req_3_ld_meta_data; \
    wire        fetch_outputs_idm_reqs_req_3_ld_data; \
    wire        fetch_outputs_idm_reqs_req_3_valid; \
    wire        fetch_outputs_idm_reqs_req_3_br_valid; \
    wire [31:0] fetch_outputs_idm_reqs_req_3_br_eip; \
    wire [31:0] fetch_outputs_idm_reqs_req_3_br_target; \
    wire        fetch_outputs_idm_reqs_req_3_br_xcl; \
    wire [127:0] fetch_outputs_idm_reqs_req_3_data; \
    wire        fetch_outputs_exp_pipe_clear; \
    wire        fetch_outputs_exp_present; \
    wire        fetch_outputs_exp_pf; \
    wire [1:0]  fetch_outputs_exp_mode_jk; \
    wire        fetch_outputs_int_mode_jk;
