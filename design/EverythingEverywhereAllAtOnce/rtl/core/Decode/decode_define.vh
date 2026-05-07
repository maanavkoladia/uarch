// Macros used by control_store_top_structural.v
//   CS_INSTANCE_PORTS(YZA, X) — port-binding block for one of 32 control_store
//                                instances. YZA = {pf3,pf1,pf0} (3 chars),
//                                X = opcode index in IR (0..3).
//   CS_MUX_PORTS(YZA)         — 69 stage-1 MUX_4s collapsing the x dimension
//                                via num_pfs, for a given yza.

`define CS_INSTANCE_PORTS(YZA, X) \
    control_store cs (
        .invalid_inst(invalid_inst), .total_pf_vector_0(1'b1), .total_pf_vector_1(1'b1), .total_pf_vector_3(1'b1),
        .opcode(IR[3*8 +: 8]), .modrm(IR[4*8 +: 8]), .seg_override(seg_override), .seg0(seg0),
        .decode_cs_REP(decode_cs_REP_YZA_x[X]), \
        .decode_cs_REP_CMP(decode_cs_REP_CMP_YZA_x[X]), \
        .decode_cs_HALT(decode_cs_HALT_YZA_x[X]), \
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_YZA_x[X]), \
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_YZA_x[X]), \
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_YZA_x[X]), \
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_YZA_x[X]), \
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_YZA_x[X]), \
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_YZA_x[X]), \
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_YZA_x[X]), \
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_YZA_x[X]), \
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_YZA_x[X]), \
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_YZA_x[X]), \
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_YZA_x[X]), \
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_YZA_x[X]), \
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_YZA_x[X]), \
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_YZA_x[X]), \
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_YZA_x[X]), \
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_YZA_x[X]), \
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_YZA_x[X]), \
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_YZA_x[X]), \
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_YZA_x[X]), \
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_YZA_x[X]), \
        .rr_cs_ST_SEL(rr_cs_ST_SEL_YZA_x[X]), \
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_YZA_x[X]), \
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_YZA_x[X]), \
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_YZA_x[X]), \
        .rr_cs_LD_OP(rr_cs_LD_OP_YZA_x[X]), \
        .rr_cs_ST_OP(rr_cs_ST_OP_YZA_x[X]), \
        .rr_cs_dr_id(rr_cs_dr_id_YZA_x[X]), \
        .rr_cs_sr_id(rr_cs_sr_id_YZA_x[X]), \
        .rr_cs_dr_rd(rr_cs_dr_rd_YZA_x[X]), \
        .rr_cs_sr_rd(rr_cs_sr_rd_YZA_x[X]), \
        .rr_cs_eax_rd(rr_cs_eax_rd_YZA_x[X]), \
        .rr_cs_dr_wr(rr_cs_dr_wr_YZA_x[X]), \
        .rr_cs_sr_wr(rr_cs_sr_wr_YZA_x[X]), \
        .rr_cs_eax_wr(rr_cs_eax_wr_YZA_x[X]), \
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_YZA_x[X]), \
        .rr_cs_datasize(rr_cs_datasize_YZA_x[X]), \
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_YZA_x[X]), \
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_YZA_x[X]), \
        .rr_cs_seg_0_id(rr_cs_seg_0_id_YZA_x[X]), \
        .rr_cs_seg_1_id(rr_cs_seg_1_id_YZA_x[X]), \
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_YZA_x[X]), \
        .rr_cs_special_br(rr_cs_special_br_YZA_x[X]), \
        .dc_cs_LD_OP(dc_cs_LD_OP_YZA_x[X]), \
        .dc_cs_ST_OP(dc_cs_ST_OP_YZA_x[X]), \
        .dc_cs_dr_upper8(dc_cs_dr_upper8_YZA_x[X]), \
        .dc_cs_sr_upper8(dc_cs_sr_upper8_YZA_x[X]), \
        .dc_cs_datasize(dc_cs_datasize_YZA_x[X]), \
        .mem_cs_ST_OP(mem_cs_ST_OP_YZA_x[X]), \
        .mem_cs_LD_OP(mem_cs_LD_OP_YZA_x[X]), \
        .exe_cs_ST_OP(exe_cs_ST_OP_YZA_x[X]), \
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_YZA_x[X]), \
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_YZA_x[X]), \
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_YZA_x[X]), \
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_YZA_x[X]), \
        .exe_cs_shift_by_one(exe_cs_shift_by_one_YZA_x[X]), \
        .exe_cs_br_ucond(exe_cs_br_ucond_YZA_x[X]), \
        .exe_cs_relative_branch(exe_cs_relative_branch_YZA_x[X]), \
        .exe_cs_special_br(exe_cs_special_br_YZA_x[X]), \
        .exe_cs_is_far(exe_cs_is_far_YZA_x[X]), \
        .exe_cs_is_call(exe_cs_is_call_YZA_x[X]), \
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_YZA_x[X]), \
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_YZA_x[X]), \
        .wb_cs_ST_OP(wb_cs_ST_OP_YZA_x[X]), \
        .wb_cs_WB_DR(wb_cs_WB_DR_YZA_x[X]), \
        .wb_cs_WB_SR(wb_cs_WB_SR_YZA_x[X]), \
        .wb_cs_WB_EAX(wb_cs_WB_EAX_YZA_x[X]));


`define CS_MUX_PORTS(YZA) \
    `MUX_4(decode_cs_REP_YZA_mux,                 1,             decode_cs_REP_YZA,                 decode_cs_REP_YZA_x[0],                 decode_cs_REP_YZA_x[1],                 decode_cs_REP_YZA_x[2],                 decode_cs_REP_YZA_x[3],                 num_pfs) \
    `MUX_4(decode_cs_REP_CMP_YZA_mux,             1,             decode_cs_REP_CMP_YZA,             decode_cs_REP_CMP_YZA_x[0],             decode_cs_REP_CMP_YZA_x[1],             decode_cs_REP_CMP_YZA_x[2],             decode_cs_REP_CMP_YZA_x[3],             num_pfs) \
    `MUX_4(decode_cs_HALT_YZA_mux,                1,             decode_cs_HALT_YZA,                decode_cs_HALT_YZA_x[0],                decode_cs_HALT_YZA_x[1],                decode_cs_HALT_YZA_x[2],                decode_cs_HALT_YZA_x[3],                num_pfs) \
    `MUX_4(decode_cs_MODRM_NEEDED_YZA_mux,        1,             decode_cs_MODRM_NEEDED_YZA,        decode_cs_MODRM_NEEDED_YZA_x[0],        decode_cs_MODRM_NEEDED_YZA_x[1],        decode_cs_MODRM_NEEDED_YZA_x[2],        decode_cs_MODRM_NEEDED_YZA_x[3],        num_pfs) \
    `MUX_4(decode_cs_RM_IS_DR_YZA_mux,            1,             decode_cs_RM_IS_DR_YZA,            decode_cs_RM_IS_DR_YZA_x[0],            decode_cs_RM_IS_DR_YZA_x[1],            decode_cs_RM_IS_DR_YZA_x[2],            decode_cs_RM_IS_DR_YZA_x[3],            num_pfs) \
    `MUX_4(decode_cs_REG_IS_DR_YZA_mux,           1,             decode_cs_REG_IS_DR_YZA,           decode_cs_REG_IS_DR_YZA_x[0],           decode_cs_REG_IS_DR_YZA_x[1],           decode_cs_REG_IS_DR_YZA_x[2],           decode_cs_REG_IS_DR_YZA_x[3],           num_pfs) \
    `MUX_4(decode_cs_REG_IS_SEGMENT_YZA_mux,      1,             decode_cs_REG_IS_SEGMENT_YZA,      decode_cs_REG_IS_SEGMENT_YZA_x[0],      decode_cs_REG_IS_SEGMENT_YZA_x[1],      decode_cs_REG_IS_SEGMENT_YZA_x[2],      decode_cs_REG_IS_SEGMENT_YZA_x[3],      num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_YZA_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_YZA,  decode_cs_HARDCODED_DR_HIGH8_YZA_x[0],  decode_cs_HARDCODED_DR_HIGH8_YZA_x[1],  decode_cs_HARDCODED_DR_HIGH8_YZA_x[2],  decode_cs_HARDCODED_DR_HIGH8_YZA_x[3],  num_pfs) \
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_YZA_mux,     1,             decode_cs_MODRM_BUT_NO_SR_YZA,     decode_cs_MODRM_BUT_NO_SR_YZA_x[0],     decode_cs_MODRM_BUT_NO_SR_YZA_x[1],     decode_cs_MODRM_BUT_NO_SR_YZA_x[2],     decode_cs_MODRM_BUT_NO_SR_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_YZA_mux,        1,             decode_cs_HARDCODED_DR_YZA,        decode_cs_HARDCODED_DR_YZA_x[0],        decode_cs_HARDCODED_DR_YZA_x[1],        decode_cs_HARDCODED_DR_YZA_x[2],        decode_cs_HARDCODED_DR_YZA_x[3],        num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_ID_YZA_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_YZA,     decode_cs_HARDCODED_DR_ID_YZA_x[0],     decode_cs_HARDCODED_DR_ID_YZA_x[1],     decode_cs_HARDCODED_DR_ID_YZA_x[2],     decode_cs_HARDCODED_DR_ID_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_YZA_mux,        1,             decode_cs_HARDCODED_SR_YZA,        decode_cs_HARDCODED_SR_YZA_x[0],        decode_cs_HARDCODED_SR_YZA_x[1],        decode_cs_HARDCODED_SR_YZA_x[2],        decode_cs_HARDCODED_SR_YZA_x[3],        num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_ID_YZA_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_YZA,     decode_cs_HARDCODED_SR_ID_YZA_x[0],     decode_cs_HARDCODED_SR_ID_YZA_x[1],     decode_cs_HARDCODED_SR_ID_YZA_x[2],     decode_cs_HARDCODED_SR_ID_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_RD_YZA_mux,     1,             decode_cs_HARDCODED_DR_RD_YZA,     decode_cs_HARDCODED_DR_RD_YZA_x[0],     decode_cs_HARDCODED_DR_RD_YZA_x[1],     decode_cs_HARDCODED_DR_RD_YZA_x[2],     decode_cs_HARDCODED_DR_RD_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_WR_YZA_mux,     1,             decode_cs_HARDCODED_DR_WR_YZA,     decode_cs_HARDCODED_DR_WR_YZA_x[0],     decode_cs_HARDCODED_DR_WR_YZA_x[1],     decode_cs_HARDCODED_DR_WR_YZA_x[2],     decode_cs_HARDCODED_DR_WR_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_RD_YZA_mux,     1,             decode_cs_HARDCODED_SR_RD_YZA,     decode_cs_HARDCODED_SR_RD_YZA_x[0],     decode_cs_HARDCODED_SR_RD_YZA_x[1],     decode_cs_HARDCODED_SR_RD_YZA_x[2],     decode_cs_HARDCODED_SR_RD_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_WR_YZA_mux,     1,             decode_cs_HARDCODED_SR_WR_YZA,     decode_cs_HARDCODED_SR_WR_YZA_x[0],     decode_cs_HARDCODED_SR_WR_YZA_x[1],     decode_cs_HARDCODED_SR_WR_YZA_x[2],     decode_cs_HARDCODED_SR_WR_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_LD_OP_YZA_mux,     1,             decode_cs_HARDCODED_LD_OP_YZA,     decode_cs_HARDCODED_LD_OP_YZA_x[0],     decode_cs_HARDCODED_LD_OP_YZA_x[1],     decode_cs_HARDCODED_LD_OP_YZA_x[2],     decode_cs_HARDCODED_LD_OP_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_ST_OP_YZA_mux,     1,             decode_cs_HARDCODED_ST_OP_YZA,     decode_cs_HARDCODED_ST_OP_YZA_x[0],     decode_cs_HARDCODED_ST_OP_YZA_x[1],     decode_cs_HARDCODED_ST_OP_YZA_x[2],     decode_cs_HARDCODED_ST_OP_YZA_x[3],     num_pfs) \
    `MUX_4(decode_cs_LD_OP_CANCEL_YZA_mux,        1,             decode_cs_LD_OP_CANCEL_YZA,        decode_cs_LD_OP_CANCEL_YZA_x[0],        decode_cs_LD_OP_CANCEL_YZA_x[1],        decode_cs_LD_OP_CANCEL_YZA_x[2],        decode_cs_LD_OP_CANCEL_YZA_x[3],        num_pfs) \
    `MUX_4(decode_cs_ST_OP_CANCEL_YZA_mux,        1,             decode_cs_ST_OP_CANCEL_YZA,        decode_cs_ST_OP_CANCEL_YZA_x[0],        decode_cs_ST_OP_CANCEL_YZA_x[1],        decode_cs_ST_OP_CANCEL_YZA_x[2],        decode_cs_ST_OP_CANCEL_YZA_x[3],        num_pfs) \
    `MUX_4(decode_cs_OP_IN_MODRM_YZA_mux,         1,             decode_cs_OP_IN_MODRM_YZA,         decode_cs_OP_IN_MODRM_YZA_x[0],         decode_cs_OP_IN_MODRM_YZA_x[1],         decode_cs_OP_IN_MODRM_YZA_x[2],         decode_cs_OP_IN_MODRM_YZA_x[3],         num_pfs) \
    `MUX_4(decode_cs_DATA_SIZE_YZA_mux,           2,             decode_cs_DATA_SIZE_YZA,           decode_cs_DATA_SIZE_YZA_x[0],           decode_cs_DATA_SIZE_YZA_x[1],           decode_cs_DATA_SIZE_YZA_x[2],           decode_cs_DATA_SIZE_YZA_x[3],           num_pfs) \
    `MUX_4(rr_cs_ST_SEL_YZA_mux,                  1,             rr_cs_ST_SEL_YZA,                  rr_cs_ST_SEL_YZA_x[0],                  rr_cs_ST_SEL_YZA_x[1],                  rr_cs_ST_SEL_YZA_x[2],                  rr_cs_ST_SEL_YZA_x[3],                  num_pfs) \
    `MUX_4(rr_cs_MODRM_NEEDED_YZA_mux,            1,             rr_cs_MODRM_NEEDED_YZA,            rr_cs_MODRM_NEEDED_YZA_x[0],            rr_cs_MODRM_NEEDED_YZA_x[1],            rr_cs_MODRM_NEEDED_YZA_x[2],            rr_cs_MODRM_NEEDED_YZA_x[3],            num_pfs) \
    `MUX_4(rr_cs_RM_IS_DR_YZA_mux,                1,             rr_cs_RM_IS_DR_YZA,                rr_cs_RM_IS_DR_YZA_x[0],                rr_cs_RM_IS_DR_YZA_x[1],                rr_cs_RM_IS_DR_YZA_x[2],                rr_cs_RM_IS_DR_YZA_x[3],                num_pfs) \
    `MUX_4(rr_cs_SWITCH_LD_ADDY_YZA_mux,          1,             rr_cs_SWITCH_LD_ADDY_YZA,          rr_cs_SWITCH_LD_ADDY_YZA_x[0],          rr_cs_SWITCH_LD_ADDY_YZA_x[1],          rr_cs_SWITCH_LD_ADDY_YZA_x[2],          rr_cs_SWITCH_LD_ADDY_YZA_x[3],          num_pfs) \
    `MUX_4(rr_cs_LD_OP_YZA_mux,                   1,             rr_cs_LD_OP_YZA,                   rr_cs_LD_OP_YZA_x[0],                   rr_cs_LD_OP_YZA_x[1],                   rr_cs_LD_OP_YZA_x[2],                   rr_cs_LD_OP_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_ST_OP_YZA_mux,                   1,             rr_cs_ST_OP_YZA,                   rr_cs_ST_OP_YZA_x[0],                   rr_cs_ST_OP_YZA_x[1],                   rr_cs_ST_OP_YZA_x[2],                   rr_cs_ST_OP_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_dr_id_YZA_mux,                   `REG_ID_W,     rr_cs_dr_id_YZA,                   rr_cs_dr_id_YZA_x[0],                   rr_cs_dr_id_YZA_x[1],                   rr_cs_dr_id_YZA_x[2],                   rr_cs_dr_id_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_id_YZA_mux,                   `REG_ID_W,     rr_cs_sr_id_YZA,                   rr_cs_sr_id_YZA_x[0],                   rr_cs_sr_id_YZA_x[1],                   rr_cs_sr_id_YZA_x[2],                   rr_cs_sr_id_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_dr_rd_YZA_mux,                   1,             rr_cs_dr_rd_YZA,                   rr_cs_dr_rd_YZA_x[0],                   rr_cs_dr_rd_YZA_x[1],                   rr_cs_dr_rd_YZA_x[2],                   rr_cs_dr_rd_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_rd_YZA_mux,                   1,             rr_cs_sr_rd_YZA,                   rr_cs_sr_rd_YZA_x[0],                   rr_cs_sr_rd_YZA_x[1],                   rr_cs_sr_rd_YZA_x[2],                   rr_cs_sr_rd_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_eax_rd_YZA_mux,                  1,             rr_cs_eax_rd_YZA,                  rr_cs_eax_rd_YZA_x[0],                  rr_cs_eax_rd_YZA_x[1],                  rr_cs_eax_rd_YZA_x[2],                  rr_cs_eax_rd_YZA_x[3],                  num_pfs) \
    `MUX_4(rr_cs_dr_wr_YZA_mux,                   1,             rr_cs_dr_wr_YZA,                   rr_cs_dr_wr_YZA_x[0],                   rr_cs_dr_wr_YZA_x[1],                   rr_cs_dr_wr_YZA_x[2],                   rr_cs_dr_wr_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_wr_YZA_mux,                   1,             rr_cs_sr_wr_YZA,                   rr_cs_sr_wr_YZA_x[0],                   rr_cs_sr_wr_YZA_x[1],                   rr_cs_sr_wr_YZA_x[2],                   rr_cs_sr_wr_YZA_x[3],                   num_pfs) \
    `MUX_4(rr_cs_eax_wr_YZA_mux,                  1,             rr_cs_eax_wr_YZA,                  rr_cs_eax_wr_YZA_x[0],                  rr_cs_eax_wr_YZA_x[1],                  rr_cs_eax_wr_YZA_x[2],                  rr_cs_eax_wr_YZA_x[3],                  num_pfs) \
    `MUX_4(rr_cs_MOVS_OP_YZA_mux,                 1,             rr_cs_MOVS_OP_YZA,                 rr_cs_MOVS_OP_YZA_x[0],                 rr_cs_MOVS_OP_YZA_x[1],                 rr_cs_MOVS_OP_YZA_x[2],                 rr_cs_MOVS_OP_YZA_x[3],                 num_pfs) \
    `MUX_4(rr_cs_datasize_YZA_mux,                2,             rr_cs_datasize_YZA,                rr_cs_datasize_YZA_x[0],                rr_cs_datasize_YZA_x[1],                rr_cs_datasize_YZA_x[2],                rr_cs_datasize_YZA_x[3],                num_pfs) \
    `MUX_4(rr_cs_will_mod_zf_YZA_mux,             1,             rr_cs_will_mod_zf_YZA,             rr_cs_will_mod_zf_YZA_x[0],             rr_cs_will_mod_zf_YZA_x[1],             rr_cs_will_mod_zf_YZA_x[2],             rr_cs_will_mod_zf_YZA_x[3],             num_pfs) \
    `MUX_4(rr_cs_seg_1_valid_YZA_mux,             1,             rr_cs_seg_1_valid_YZA,             rr_cs_seg_1_valid_YZA_x[0],             rr_cs_seg_1_valid_YZA_x[1],             rr_cs_seg_1_valid_YZA_x[2],             rr_cs_seg_1_valid_YZA_x[3],             num_pfs) \
    `MUX_4(rr_cs_seg_0_id_YZA_mux,                `REG_ID_W,     rr_cs_seg_0_id_YZA,                rr_cs_seg_0_id_YZA_x[0],                rr_cs_seg_0_id_YZA_x[1],                rr_cs_seg_0_id_YZA_x[2],                rr_cs_seg_0_id_YZA_x[3],                num_pfs) \
    `MUX_4(rr_cs_seg_1_id_YZA_mux,                `REG_ID_W,     rr_cs_seg_1_id_YZA,                rr_cs_seg_1_id_YZA_x[0],                rr_cs_seg_1_id_YZA_x[1],                rr_cs_seg_1_id_YZA_x[2],                rr_cs_seg_1_id_YZA_x[3],                num_pfs) \
    `MUX_4(rr_cs_special_modrm_bs_YZA_mux,        1,             rr_cs_special_modrm_bs_YZA,        rr_cs_special_modrm_bs_YZA_x[0],        rr_cs_special_modrm_bs_YZA_x[1],        rr_cs_special_modrm_bs_YZA_x[2],        rr_cs_special_modrm_bs_YZA_x[3],        num_pfs) \
    `MUX_4(rr_cs_special_br_YZA_mux,              1,             rr_cs_special_br_YZA,              rr_cs_special_br_YZA_x[0],              rr_cs_special_br_YZA_x[1],              rr_cs_special_br_YZA_x[2],              rr_cs_special_br_YZA_x[3],              num_pfs) \
    `MUX_4(dc_cs_LD_OP_YZA_mux,                   1,             dc_cs_LD_OP_YZA,                   dc_cs_LD_OP_YZA_x[0],                   dc_cs_LD_OP_YZA_x[1],                   dc_cs_LD_OP_YZA_x[2],                   dc_cs_LD_OP_YZA_x[3],                   num_pfs) \
    `MUX_4(dc_cs_ST_OP_YZA_mux,                   1,             dc_cs_ST_OP_YZA,                   dc_cs_ST_OP_YZA_x[0],                   dc_cs_ST_OP_YZA_x[1],                   dc_cs_ST_OP_YZA_x[2],                   dc_cs_ST_OP_YZA_x[3],                   num_pfs) \
    `MUX_4(dc_cs_dr_upper8_YZA_mux,               1,             dc_cs_dr_upper8_YZA,               dc_cs_dr_upper8_YZA_x[0],               dc_cs_dr_upper8_YZA_x[1],               dc_cs_dr_upper8_YZA_x[2],               dc_cs_dr_upper8_YZA_x[3],               num_pfs) \
    `MUX_4(dc_cs_sr_upper8_YZA_mux,               1,             dc_cs_sr_upper8_YZA,               dc_cs_sr_upper8_YZA_x[0],               dc_cs_sr_upper8_YZA_x[1],               dc_cs_sr_upper8_YZA_x[2],               dc_cs_sr_upper8_YZA_x[3],               num_pfs) \
    `MUX_4(dc_cs_datasize_YZA_mux,                2,             dc_cs_datasize_YZA,                dc_cs_datasize_YZA_x[0],                dc_cs_datasize_YZA_x[1],                dc_cs_datasize_YZA_x[2],                dc_cs_datasize_YZA_x[3],                num_pfs) \
    `MUX_4(mem_cs_ST_OP_YZA_mux,                  1,             mem_cs_ST_OP_YZA,                  mem_cs_ST_OP_YZA_x[0],                  mem_cs_ST_OP_YZA_x[1],                  mem_cs_ST_OP_YZA_x[2],                  mem_cs_ST_OP_YZA_x[3],                  num_pfs) \
    `MUX_4(mem_cs_LD_OP_YZA_mux,                  1,             mem_cs_LD_OP_YZA,                  mem_cs_LD_OP_YZA_x[0],                  mem_cs_LD_OP_YZA_x[1],                  mem_cs_LD_OP_YZA_x[2],                  mem_cs_LD_OP_YZA_x[3],                  num_pfs) \
    `MUX_4(exe_cs_ST_OP_YZA_mux,                  1,             exe_cs_ST_OP_YZA,                  exe_cs_ST_OP_YZA_x[0],                  exe_cs_ST_OP_YZA_x[1],                  exe_cs_ST_OP_YZA_x[2],                  exe_cs_ST_OP_YZA_x[3],                  num_pfs) \
    `MUX_4(exe_cs_OP_TYPE_YZA_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_YZA,                exe_cs_OP_TYPE_YZA_x[0],                exe_cs_OP_TYPE_YZA_x[1],                exe_cs_OP_TYPE_YZA_x[2],                exe_cs_OP_TYPE_YZA_x[3],                num_pfs) \
    `MUX_4(exe_cs_alu_inputA_sel_YZA_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_YZA,         exe_cs_alu_inputA_sel_YZA_x[0],         exe_cs_alu_inputA_sel_YZA_x[1],         exe_cs_alu_inputA_sel_YZA_x[2],         exe_cs_alu_inputA_sel_YZA_x[3],         num_pfs) \
    `MUX_4(exe_cs_alu_inputB_sel_YZA_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_YZA,         exe_cs_alu_inputB_sel_YZA_x[0],         exe_cs_alu_inputB_sel_YZA_x[1],         exe_cs_alu_inputB_sel_YZA_x[2],         exe_cs_alu_inputB_sel_YZA_x[3],         num_pfs) \
    `MUX_4(exe_cs_branch_target_sel_YZA_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_YZA,      exe_cs_branch_target_sel_YZA_x[0],      exe_cs_branch_target_sel_YZA_x[1],      exe_cs_branch_target_sel_YZA_x[2],      exe_cs_branch_target_sel_YZA_x[3],      num_pfs) \
    `MUX_4(exe_cs_shift_by_one_YZA_mux,           1,             exe_cs_shift_by_one_YZA,           exe_cs_shift_by_one_YZA_x[0],           exe_cs_shift_by_one_YZA_x[1],           exe_cs_shift_by_one_YZA_x[2],           exe_cs_shift_by_one_YZA_x[3],           num_pfs) \
    `MUX_4(exe_cs_br_ucond_YZA_mux,               1,             exe_cs_br_ucond_YZA,               exe_cs_br_ucond_YZA_x[0],               exe_cs_br_ucond_YZA_x[1],               exe_cs_br_ucond_YZA_x[2],               exe_cs_br_ucond_YZA_x[3],               num_pfs) \
    `MUX_4(exe_cs_relative_branch_YZA_mux,        1,             exe_cs_relative_branch_YZA,        exe_cs_relative_branch_YZA_x[0],        exe_cs_relative_branch_YZA_x[1],        exe_cs_relative_branch_YZA_x[2],        exe_cs_relative_branch_YZA_x[3],        num_pfs) \
    `MUX_4(exe_cs_special_br_YZA_mux,             1,             exe_cs_special_br_YZA,             exe_cs_special_br_YZA_x[0],             exe_cs_special_br_YZA_x[1],             exe_cs_special_br_YZA_x[2],             exe_cs_special_br_YZA_x[3],             num_pfs) \
    `MUX_4(exe_cs_is_far_YZA_mux,                 1,             exe_cs_is_far_YZA,                 exe_cs_is_far_YZA_x[0],                 exe_cs_is_far_YZA_x[1],                 exe_cs_is_far_YZA_x[2],                 exe_cs_is_far_YZA_x[3],                 num_pfs) \
    `MUX_4(exe_cs_is_call_YZA_mux,                1,             exe_cs_is_call_YZA,                exe_cs_is_call_YZA_x[0],                exe_cs_is_call_YZA_x[1],                exe_cs_is_call_YZA_x[2],                exe_cs_is_call_YZA_x[3],                num_pfs) \
    `MUX_4(exe_cs_second_flag_needed_YZA_mux,     1,             exe_cs_second_flag_needed_YZA,     exe_cs_second_flag_needed_YZA_x[0],     exe_cs_second_flag_needed_YZA_x[1],     exe_cs_second_flag_needed_YZA_x[2],     exe_cs_second_flag_needed_YZA_x[3],     num_pfs) \
    `MUX_4(exe_cs_rep_no_zf_update_YZA_mux,       1,             exe_cs_rep_no_zf_update_YZA,       exe_cs_rep_no_zf_update_YZA_x[0],       exe_cs_rep_no_zf_update_YZA_x[1],       exe_cs_rep_no_zf_update_YZA_x[2],       exe_cs_rep_no_zf_update_YZA_x[3],       num_pfs) \
    `MUX_4(wb_cs_ST_OP_YZA_mux,                   1,             wb_cs_ST_OP_YZA,                   wb_cs_ST_OP_YZA_x[0],                   wb_cs_ST_OP_YZA_x[1],                   wb_cs_ST_OP_YZA_x[2],                   wb_cs_ST_OP_YZA_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_DR_YZA_mux,                   1,             wb_cs_WB_DR_YZA,                   wb_cs_WB_DR_YZA_x[0],                   wb_cs_WB_DR_YZA_x[1],                   wb_cs_WB_DR_YZA_x[2],                   wb_cs_WB_DR_YZA_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_SR_YZA_mux,                   1,             wb_cs_WB_SR_YZA,                   wb_cs_WB_SR_YZA_x[0],                   wb_cs_WB_SR_YZA_x[1],                   wb_cs_WB_SR_YZA_x[2],                   wb_cs_WB_SR_YZA_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_EAX_YZA_mux,                  1,             wb_cs_WB_EAX_YZA,                  wb_cs_WB_EAX_YZA_x[0],                  wb_cs_WB_EAX_YZA_x[1],                  wb_cs_WB_EAX_YZA_x[2],                  wb_cs_WB_EAX_YZA_x[3],                  num_pfs)
