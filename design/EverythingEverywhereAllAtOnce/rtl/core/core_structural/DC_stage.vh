`define DC_STAGE \
    DC dc_unit ( \
        .clk(clk), \
        .rst(rst), \
        .latches_valid(dc_latches_valid), \
        .latches_cs_LD_OP(dc_latches_cs_LD_OP), \
        .latches_cs_ST_OP(dc_latches_cs_ST_OP), \
        .latches_cs_dr_upper8(dc_latches_cs_dr_upper8), \
        .latches_cs_sr_upper8(dc_latches_cs_sr_upper8), \
        .latches_cs_datasize(dc_latches_cs_datasize), \
        .latches_mem_cs_ST_OP(dc_latches_mem_cs_ST_OP), \
        .latches_mem_cs_LD_OP(dc_latches_mem_cs_LD_OP), \
        .latches_exe_cs_ST_OP(dc_latches_exe_cs_ST_OP), \
        .latches_exe_cs_OP_TYPE(dc_latches_exe_cs_OP_TYPE), \
        .latches_exe_cs_alu_inputA_sel(dc_latches_exe_cs_alu_inputA_sel), \
        .latches_exe_cs_alu_inputB_sel(dc_latches_exe_cs_alu_inputB_sel), \
        .latches_exe_cs_branch_target_sel(dc_latches_exe_cs_branch_target_sel), \
        .latches_exe_cs_shift_by_one(dc_latches_exe_cs_shift_by_one), \
        .latches_exe_cs_br_ucond(dc_latches_exe_cs_br_ucond), \
        .latches_exe_cs_relative_branch(dc_latches_exe_cs_relative_branch), \
        .latches_exe_cs_special_br(dc_latches_exe_cs_special_br), \
        .latches_exe_cs_is_far(dc_latches_exe_cs_is_far), \
        .latches_exe_cs_is_call(dc_latches_exe_cs_is_call), \
        .latches_exe_cs_second_flag_needed(dc_latches_exe_cs_second_flag_needed), \
        .latches_exe_cs_rep_no_zf_update(dc_latches_exe_cs_rep_no_zf_update), \
        .latches_wb_cs_ST_OP(dc_latches_wb_cs_ST_OP), \
        .latches_wb_cs_WB_DR(dc_latches_wb_cs_WB_DR), \
        .latches_wb_cs_WB_SR(dc_latches_wb_cs_WB_SR), \
        .latches_wb_cs_WB_EAX(dc_latches_wb_cs_WB_EAX), \
        .latches_br_info_valid(dc_latches_br_info_valid), \
        .latches_br_info_br_eip(dc_latches_br_info_br_eip), \
        .latches_br_info_br_xcl(dc_latches_br_info_br_xcl), \
        .latches_br_info_br_pred_taken(dc_latches_br_info_br_pred_taken), \
        .latches_br_info_speculative_target(dc_latches_br_info_speculative_target), \
        .latches_rr_gp(dc_latches_rr_gp), \
        .latches_ld_vaddy(dc_latches_ld_vaddy), \
        .latches_seg0_limit_w_datasize(dc_latches_seg0_limit_w_datasize), \
        .latches_seg0_limit_wo_datasize(dc_latches_seg0_limit_wo_datasize), \
        .latches_next_ld_vaddy(dc_latches_next_ld_vaddy), \
        .latches_ld_laddy(dc_latches_ld_laddy), \
        .latches_ld_stack_access(dc_latches_ld_stack_access), \
        .latches_st_vaddy(dc_latches_st_vaddy), \
        .latches_seg1_limit_w_datasize(dc_latches_seg1_limit_w_datasize), \
        .latches_seg1_limit_wo_datasize(dc_latches_seg1_limit_wo_datasize), \
        .latches_next_st_vaddy(dc_latches_next_st_vaddy), \
        .latches_st_laddy(dc_latches_st_laddy), \
        .latches_st_stack_access(dc_latches_st_stack_access), \
        .latches_NEIP(dc_latches_NEIP), \
        .latches_EIP(dc_latches_EIP), \
        .latches_EAX(dc_latches_EAX), \
        .latches_imm64(dc_latches_imm64), \
        .latches_sr_id(dc_latches_sr_id), \
        .latches_sr_data(dc_latches_sr_data), \
        .latches_dr_id(dc_latches_dr_id), \
        .latches_dr_data(dc_latches_dr_data), \
        .fetch_outs_exp_pipe_clear(fetch_outputs_exp_pipe_clear), \
        .mem_outs_valid(mem_outputs_valid), \
        .mem_outs_stall(mem_outputs_stall), \
        .mem_outs_ST_OP(mem_outputs_ST_OP), \
        .mem_outs_ST_XCL(mem_outputs_ST_XCL), \
        .mem_outs_ST_PADDR_0(mem_outputs_ST_PADDR_0), \
        .mem_outs_ST_PADDR_1(mem_outputs_ST_PADDR_1), \
        .exe_outs_valid(exe_outputs_valid), \
        .exe_outs_ST_OP(exe_outputs_ST_OP), \
        .exe_outs_ST_XCL(exe_outputs_ST_XCL), \
        .exe_outs_ST_PADDR_0(exe_outputs_ST_PADDR_0), \
        .exe_outs_ST_PADDR_1(exe_outputs_ST_PADDR_1), \
        .exe_outs_br_res_flush(exe_outputs_br_res_flush), \
        .wb_outs_valid(wb_outputs_valid), \
        .wb_outs_wb_stall(wb_outputs_wb_stall), \
        .wb_outs_ST_OP(wb_outputs_ST_OP), \
        .wb_outs_ST_XCL(wb_outputs_ST_XCL), \
        .wb_outs_ST_PADDR_0(wb_outputs_ST_PADDR_0), \
        .wb_outs_ST_PADDR_1(wb_outputs_ST_PADDR_1), \
        .wb_outs_dep_check_entry_0_valid   (wb_outputs_dep_check_entry_0_valid), \
        .wb_outs_dep_check_entry_0_address (wb_outputs_dep_check_entry_0_address), \
        .wb_outs_dep_check_entry_1_valid   (wb_outputs_dep_check_entry_1_valid), \
        .wb_outs_dep_check_entry_1_address (wb_outputs_dep_check_entry_1_address), \
        .wb_outs_dep_check_entry_2_valid   (wb_outputs_dep_check_entry_2_valid), \
        .wb_outs_dep_check_entry_2_address (wb_outputs_dep_check_entry_2_address), \
        .wb_outs_dep_check_entry_3_valid   (wb_outputs_dep_check_entry_3_valid), \
        .wb_outs_dep_check_entry_3_address (wb_outputs_dep_check_entry_3_address), \
        .wb_outs_dep_check_entry_4_valid   (wb_outputs_dep_check_entry_4_valid), \
        .wb_outs_dep_check_entry_4_address (wb_outputs_dep_check_entry_4_address), \
        .wb_outs_dep_check_entry_5_valid   (wb_outputs_dep_check_entry_5_valid), \
        .wb_outs_dep_check_entry_5_address (wb_outputs_dep_check_entry_5_address), \
        .wb_outs_dep_check_entry_6_valid   (wb_outputs_dep_check_entry_6_valid), \
        .wb_outs_dep_check_entry_6_address (wb_outputs_dep_check_entry_6_address), \
        .wb_outs_dep_check_entry_7_valid   (wb_outputs_dep_check_entry_7_valid), \
        .wb_outs_dep_check_entry_7_address (wb_outputs_dep_check_entry_7_address), \
        .wb_outs_dep_check_entry_8_valid   (wb_outputs_dep_check_entry_8_valid), \
        .wb_outs_dep_check_entry_8_address (wb_outputs_dep_check_entry_8_address), \
        .wb_outs_dep_check_entry_9_valid   (wb_outputs_dep_check_entry_9_valid), \
        .wb_outs_dep_check_entry_9_address (wb_outputs_dep_check_entry_9_address), \
        .wb_outs_dep_check_entry_10_valid  (wb_outputs_dep_check_entry_10_valid), \
        .wb_outs_dep_check_entry_10_address(wb_outputs_dep_check_entry_10_address), \
        .wb_outs_dep_check_entry_11_valid  (wb_outputs_dep_check_entry_11_valid), \
        .wb_outs_dep_check_entry_11_address(wb_outputs_dep_check_entry_11_address), \
        .wb_outs_dep_check_entry_12_valid  (wb_outputs_dep_check_entry_12_valid), \
        .wb_outs_dep_check_entry_12_address(wb_outputs_dep_check_entry_12_address), \
        .wb_outs_dep_check_entry_13_valid  (wb_outputs_dep_check_entry_13_valid), \
        .wb_outs_dep_check_entry_13_address(wb_outputs_dep_check_entry_13_address), \
        .wb_outs_dep_check_entry_14_valid  (wb_outputs_dep_check_entry_14_valid), \
        .wb_outs_dep_check_entry_14_address(wb_outputs_dep_check_entry_14_address), \
        .wb_outs_dep_check_entry_15_valid  (wb_outputs_dep_check_entry_15_valid), \
        .wb_outs_dep_check_entry_15_address(wb_outputs_dep_check_entry_15_address), \
        .req_served_mio(dcache2Core_reqServed_MIO_o), \
        .req_served_0  (dcache2Core_reqServed_0_o), \
        .req_served_1  (dcache2Core_reqServed_1_o), \
        .mem_latches_next_valid                    (mem_latches_next_valid), \
        .mem_latches_next_cs_ST_OP                 (mem_latches_next_cs_ST_OP), \
        .mem_latches_next_cs_LD_OP                 (mem_latches_next_cs_LD_OP), \
        .mem_latches_next_exe_cs_ST_OP             (mem_latches_next_exe_cs_ST_OP), \
        .mem_latches_next_exe_cs_OP_TYPE           (mem_latches_next_exe_cs_OP_TYPE), \
        .mem_latches_next_exe_cs_alu_inputA_sel    (mem_latches_next_exe_cs_alu_inputA_sel), \
        .mem_latches_next_exe_cs_alu_inputB_sel    (mem_latches_next_exe_cs_alu_inputB_sel), \
        .mem_latches_next_exe_cs_branch_target_sel (mem_latches_next_exe_cs_branch_target_sel), \
        .mem_latches_next_exe_cs_shift_by_one      (mem_latches_next_exe_cs_shift_by_one), \
        .mem_latches_next_exe_cs_br_ucond          (mem_latches_next_exe_cs_br_ucond), \
        .mem_latches_next_exe_cs_relative_branch   (mem_latches_next_exe_cs_relative_branch), \
        .mem_latches_next_exe_cs_special_br        (mem_latches_next_exe_cs_special_br), \
        .mem_latches_next_exe_cs_is_far            (mem_latches_next_exe_cs_is_far), \
        .mem_latches_next_exe_cs_is_call           (mem_latches_next_exe_cs_is_call), \
        .mem_latches_next_exe_cs_second_flag_needed(mem_latches_next_exe_cs_second_flag_needed), \
        .mem_latches_next_exe_cs_rep_no_zf_update  (mem_latches_next_exe_cs_rep_no_zf_update), \
        .mem_latches_next_wb_cs_ST_OP              (mem_latches_next_wb_cs_ST_OP), \
        .mem_latches_next_wb_cs_WB_DR              (mem_latches_next_wb_cs_WB_DR), \
        .mem_latches_next_wb_cs_WB_SR              (mem_latches_next_wb_cs_WB_SR), \
        .mem_latches_next_wb_cs_WB_EAX             (mem_latches_next_wb_cs_WB_EAX), \
        .mem_latches_next_br_info_valid            (mem_latches_next_br_info_valid), \
        .mem_latches_next_br_info_br_eip           (mem_latches_next_br_info_br_eip), \
        .mem_latches_next_br_info_br_xcl           (mem_latches_next_br_info_br_xcl), \
        .mem_latches_next_br_info_br_pred_taken   (mem_latches_next_br_info_br_pred_taken), \
        .mem_latches_next_br_info_speculative_target(mem_latches_next_br_info_speculative_target), \
        .mem_latches_next_data_size_vec            (mem_latches_next_data_size_vec), \
        .mem_latches_next_sr_data_size_vec         (mem_latches_next_sr_data_size_vec), \
        .mem_latches_next_shift_sr_up              (mem_latches_next_shift_sr_up), \
        .mem_latches_next_shift_sr_down            (mem_latches_next_shift_sr_down), \
        .mem_latches_next_ST_XCL                   (mem_latches_next_ST_XCL), \
        .mem_latches_next_ST_PADDR_0               (mem_latches_next_ST_PADDR_0), \
        .mem_latches_next_ST_PADDR_1               (mem_latches_next_ST_PADDR_1), \
        .mem_latches_next_MIO                      (mem_latches_next_MIO), \
        .mem_latches_next_NEIP                     (mem_latches_next_NEIP), \
        .mem_latches_next_EIP                      (mem_latches_next_EIP), \
        .mem_latches_next_EAX                      (mem_latches_next_EAX), \
        .mem_latches_next_imm64                    (mem_latches_next_imm64), \
        .mem_latches_next_sr_id                    (mem_latches_next_sr_id), \
        .mem_latches_next_sr_data                  (mem_latches_next_sr_data), \
        .mem_latches_next_dr_id                    (mem_latches_next_dr_id), \
        .mem_latches_next_dr_data                  (mem_latches_next_dr_data), \
        .mem_latches_next_LD_XCL                   (mem_latches_next_LD_XCL), \
        .mem_latches_next_swapLines                (mem_latches_next_swapLines), \
        .mem_latches_next_LD_PADDR_0               (mem_latches_next_LD_PADDR_0), \
        .mem_latches_next_LD_PADDR_1               (mem_latches_next_LD_PADDR_1), \
        .dc_outs_valid             (dc_outputs_valid), \
        .dc_outs_dc_eip            (dc_outputs_dc_eip), \
        .dc_outs_stall             (dc_outputs_stall), \
        .dc_outs_exp_pf            (dc_outputs_exp_pf), \
        .dc_outs_exp_present       (dc_outputs_exp_present), \
        .dc_outs_ld_addr_0_V       (dc_outputs_ld_addr_0_V), \
        .dc_outs_ld_addr_0         (dc_outputs_ld_addr_0), \
        .dc_outs_ld_addr_1_V       (dc_outputs_ld_addr_1_V), \
        .dc_outs_ld_addr_1         (dc_outputs_ld_addr_1), \
        .dc_outs_ld_addr_MIO_V     (dc_outputs_ld_addr_MIO_V), \
        .dc_outs_ld_addr_MIO       (dc_outputs_ld_addr_MIO), \
        .dc_outs_mem_stage_latch_we(dc_outputs_mem_stage_latch_we) \
    );
