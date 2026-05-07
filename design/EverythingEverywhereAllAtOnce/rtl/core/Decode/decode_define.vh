// Macros used by control_store_top_structural.v
//   CS_INSTANCE_PORTS(YZA, X) — port-binding block for one of 32 control_store
//                                instances. YZA = {pf3,pf1,pf0} (3 chars),
//                                X = opcode index in IR (0..3).
//   CS_MUX_PORTS(YZA)         — 69 stage-1 MUX_4s collapsing the x dimension
//                                via num_pfs, for a given yza.

`define CS_INSTANCE_PORTS(YZA, X) \
        .decode_cs_REP(decode_cs_REP_``YZA``_x[X]), \
        .decode_cs_REP_CMP(decode_cs_REP_CMP_``YZA``_x[X]), \
        .decode_cs_HALT(decode_cs_HALT_``YZA``_x[X]), \
        .decode_cs_MODRM_NEEDED(decode_cs_MODRM_NEEDED_``YZA``_x[X]), \
        .decode_cs_RM_IS_DR(decode_cs_RM_IS_DR_``YZA``_x[X]), \
        .decode_cs_REG_IS_DR(decode_cs_REG_IS_DR_``YZA``_x[X]), \
        .decode_cs_REG_IS_SEGMENT(decode_cs_REG_IS_SEGMENT_``YZA``_x[X]), \
        .decode_cs_HARDCODED_DR_HIGH8(decode_cs_HARDCODED_DR_HIGH8_``YZA``_x[X]), \
        .decode_cs_MODRM_BUT_NO_SR(decode_cs_MODRM_BUT_NO_SR_``YZA``_x[X]), \
        .decode_cs_HARDCODED_DR(decode_cs_HARDCODED_DR_``YZA``_x[X]), \
        .decode_cs_HARDCODED_DR_ID(decode_cs_HARDCODED_DR_ID_``YZA``_x[X]), \
        .decode_cs_HARDCODED_SR(decode_cs_HARDCODED_SR_``YZA``_x[X]), \
        .decode_cs_HARDCODED_SR_ID(decode_cs_HARDCODED_SR_ID_``YZA``_x[X]), \
        .decode_cs_HARDCODED_DR_RD(decode_cs_HARDCODED_DR_RD_``YZA``_x[X]), \
        .decode_cs_HARDCODED_DR_WR(decode_cs_HARDCODED_DR_WR_``YZA``_x[X]), \
        .decode_cs_HARDCODED_SR_RD(decode_cs_HARDCODED_SR_RD_``YZA``_x[X]), \
        .decode_cs_HARDCODED_SR_WR(decode_cs_HARDCODED_SR_WR_``YZA``_x[X]), \
        .decode_cs_HARDCODED_LD_OP(decode_cs_HARDCODED_LD_OP_``YZA``_x[X]), \
        .decode_cs_HARDCODED_ST_OP(decode_cs_HARDCODED_ST_OP_``YZA``_x[X]), \
        .decode_cs_LD_OP_CANCEL(decode_cs_LD_OP_CANCEL_``YZA``_x[X]), \
        .decode_cs_ST_OP_CANCEL(decode_cs_ST_OP_CANCEL_``YZA``_x[X]), \
        .decode_cs_OP_IN_MODRM(decode_cs_OP_IN_MODRM_``YZA``_x[X]), \
        .decode_cs_DATA_SIZE(decode_cs_DATA_SIZE_``YZA``_x[X]), \
        .rr_cs_ST_SEL(rr_cs_ST_SEL_``YZA``_x[X]), \
        .rr_cs_MODRM_NEEDED(rr_cs_MODRM_NEEDED_``YZA``_x[X]), \
        .rr_cs_RM_IS_DR(rr_cs_RM_IS_DR_``YZA``_x[X]), \
        .rr_cs_SWITCH_LD_ADDY(rr_cs_SWITCH_LD_ADDY_``YZA``_x[X]), \
        .rr_cs_LD_OP(rr_cs_LD_OP_``YZA``_x[X]), \
        .rr_cs_ST_OP(rr_cs_ST_OP_``YZA``_x[X]), \
        .rr_cs_dr_id(rr_cs_dr_id_``YZA``_x[X]), \
        .rr_cs_sr_id(rr_cs_sr_id_``YZA``_x[X]), \
        .rr_cs_dr_rd(rr_cs_dr_rd_``YZA``_x[X]), \
        .rr_cs_sr_rd(rr_cs_sr_rd_``YZA``_x[X]), \
        .rr_cs_eax_rd(rr_cs_eax_rd_``YZA``_x[X]), \
        .rr_cs_dr_wr(rr_cs_dr_wr_``YZA``_x[X]), \
        .rr_cs_sr_wr(rr_cs_sr_wr_``YZA``_x[X]), \
        .rr_cs_eax_wr(rr_cs_eax_wr_``YZA``_x[X]), \
        .rr_cs_MOVS_OP(rr_cs_MOVS_OP_``YZA``_x[X]), \
        .rr_cs_datasize(rr_cs_datasize_``YZA``_x[X]), \
        .rr_cs_will_mod_zf(rr_cs_will_mod_zf_``YZA``_x[X]), \
        .rr_cs_seg_1_valid(rr_cs_seg_1_valid_``YZA``_x[X]), \
        .rr_cs_seg_0_id(rr_cs_seg_0_id_``YZA``_x[X]), \
        .rr_cs_seg_1_id(rr_cs_seg_1_id_``YZA``_x[X]), \
        .rr_cs_special_modrm_bs(rr_cs_special_modrm_bs_``YZA``_x[X]), \
        .rr_cs_special_br(rr_cs_special_br_``YZA``_x[X]), \
        .dc_cs_LD_OP(dc_cs_LD_OP_``YZA``_x[X]), \
        .dc_cs_ST_OP(dc_cs_ST_OP_``YZA``_x[X]), \
        .dc_cs_dr_upper8(dc_cs_dr_upper8_``YZA``_x[X]), \
        .dc_cs_sr_upper8(dc_cs_sr_upper8_``YZA``_x[X]), \
        .dc_cs_datasize(dc_cs_datasize_``YZA``_x[X]), \
        .mem_cs_ST_OP(mem_cs_ST_OP_``YZA``_x[X]), \
        .mem_cs_LD_OP(mem_cs_LD_OP_``YZA``_x[X]), \
        .exe_cs_ST_OP(exe_cs_ST_OP_``YZA``_x[X]), \
        .exe_cs_OP_TYPE(exe_cs_OP_TYPE_``YZA``_x[X]), \
        .exe_cs_alu_inputA_sel(exe_cs_alu_inputA_sel_``YZA``_x[X]), \
        .exe_cs_alu_inputB_sel(exe_cs_alu_inputB_sel_``YZA``_x[X]), \
        .exe_cs_branch_target_sel(exe_cs_branch_target_sel_``YZA``_x[X]), \
        .exe_cs_shift_by_one(exe_cs_shift_by_one_``YZA``_x[X]), \
        .exe_cs_br_ucond(exe_cs_br_ucond_``YZA``_x[X]), \
        .exe_cs_relative_branch(exe_cs_relative_branch_``YZA``_x[X]), \
        .exe_cs_special_br(exe_cs_special_br_``YZA``_x[X]), \
        .exe_cs_is_far(exe_cs_is_far_``YZA``_x[X]), \
        .exe_cs_is_call(exe_cs_is_call_``YZA``_x[X]), \
        .exe_cs_second_flag_needed(exe_cs_second_flag_needed_``YZA``_x[X]), \
        .exe_cs_rep_no_zf_update(exe_cs_rep_no_zf_update_``YZA``_x[X]), \
        .wb_cs_ST_OP(wb_cs_ST_OP_``YZA``_x[X]), \
        .wb_cs_WB_DR(wb_cs_WB_DR_``YZA``_x[X]), \
        .wb_cs_WB_SR(wb_cs_WB_SR_``YZA``_x[X]), \
        .wb_cs_WB_EAX(wb_cs_WB_EAX_``YZA``_x[X])


`define CS_MUX_PORTS(YZA) \
    `MUX_4(decode_cs_REP_``YZA``_mux,                 1,             decode_cs_REP_``YZA,                 decode_cs_REP_``YZA``_x[0],                 decode_cs_REP_``YZA``_x[1],                 decode_cs_REP_``YZA``_x[2],                 decode_cs_REP_``YZA``_x[3],                 num_pfs) \
    `MUX_4(decode_cs_REP_CMP_``YZA``_mux,             1,             decode_cs_REP_CMP_``YZA,             decode_cs_REP_CMP_``YZA``_x[0],             decode_cs_REP_CMP_``YZA``_x[1],             decode_cs_REP_CMP_``YZA``_x[2],             decode_cs_REP_CMP_``YZA``_x[3],             num_pfs) \
    `MUX_4(decode_cs_HALT_``YZA``_mux,                1,             decode_cs_HALT_``YZA,                decode_cs_HALT_``YZA``_x[0],                decode_cs_HALT_``YZA``_x[1],                decode_cs_HALT_``YZA``_x[2],                decode_cs_HALT_``YZA``_x[3],                num_pfs) \
    `MUX_4(decode_cs_MODRM_NEEDED_``YZA``_mux,        1,             decode_cs_MODRM_NEEDED_``YZA,        decode_cs_MODRM_NEEDED_``YZA``_x[0],        decode_cs_MODRM_NEEDED_``YZA``_x[1],        decode_cs_MODRM_NEEDED_``YZA``_x[2],        decode_cs_MODRM_NEEDED_``YZA``_x[3],        num_pfs) \
    `MUX_4(decode_cs_RM_IS_DR_``YZA``_mux,            1,             decode_cs_RM_IS_DR_``YZA,            decode_cs_RM_IS_DR_``YZA``_x[0],            decode_cs_RM_IS_DR_``YZA``_x[1],            decode_cs_RM_IS_DR_``YZA``_x[2],            decode_cs_RM_IS_DR_``YZA``_x[3],            num_pfs) \
    `MUX_4(decode_cs_REG_IS_DR_``YZA``_mux,           1,             decode_cs_REG_IS_DR_``YZA,           decode_cs_REG_IS_DR_``YZA``_x[0],           decode_cs_REG_IS_DR_``YZA``_x[1],           decode_cs_REG_IS_DR_``YZA``_x[2],           decode_cs_REG_IS_DR_``YZA``_x[3],           num_pfs) \
    `MUX_4(decode_cs_REG_IS_SEGMENT_``YZA``_mux,      1,             decode_cs_REG_IS_SEGMENT_``YZA,      decode_cs_REG_IS_SEGMENT_``YZA``_x[0],      decode_cs_REG_IS_SEGMENT_``YZA``_x[1],      decode_cs_REG_IS_SEGMENT_``YZA``_x[2],      decode_cs_REG_IS_SEGMENT_``YZA``_x[3],      num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_HIGH8_``YZA``_mux,  1,             decode_cs_HARDCODED_DR_HIGH8_``YZA,  decode_cs_HARDCODED_DR_HIGH8_``YZA``_x[0],  decode_cs_HARDCODED_DR_HIGH8_``YZA``_x[1],  decode_cs_HARDCODED_DR_HIGH8_``YZA``_x[2],  decode_cs_HARDCODED_DR_HIGH8_``YZA``_x[3],  num_pfs) \
    `MUX_4(decode_cs_MODRM_BUT_NO_SR_``YZA``_mux,     1,             decode_cs_MODRM_BUT_NO_SR_``YZA,     decode_cs_MODRM_BUT_NO_SR_``YZA``_x[0],     decode_cs_MODRM_BUT_NO_SR_``YZA``_x[1],     decode_cs_MODRM_BUT_NO_SR_``YZA``_x[2],     decode_cs_MODRM_BUT_NO_SR_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_``YZA``_mux,        1,             decode_cs_HARDCODED_DR_``YZA,        decode_cs_HARDCODED_DR_``YZA``_x[0],        decode_cs_HARDCODED_DR_``YZA``_x[1],        decode_cs_HARDCODED_DR_``YZA``_x[2],        decode_cs_HARDCODED_DR_``YZA``_x[3],        num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_ID_``YZA``_mux,     `REG_ID_W,     decode_cs_HARDCODED_DR_ID_``YZA,     decode_cs_HARDCODED_DR_ID_``YZA``_x[0],     decode_cs_HARDCODED_DR_ID_``YZA``_x[1],     decode_cs_HARDCODED_DR_ID_``YZA``_x[2],     decode_cs_HARDCODED_DR_ID_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_``YZA``_mux,        1,             decode_cs_HARDCODED_SR_``YZA,        decode_cs_HARDCODED_SR_``YZA``_x[0],        decode_cs_HARDCODED_SR_``YZA``_x[1],        decode_cs_HARDCODED_SR_``YZA``_x[2],        decode_cs_HARDCODED_SR_``YZA``_x[3],        num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_ID_``YZA``_mux,     `REG_ID_W,     decode_cs_HARDCODED_SR_ID_``YZA,     decode_cs_HARDCODED_SR_ID_``YZA``_x[0],     decode_cs_HARDCODED_SR_ID_``YZA``_x[1],     decode_cs_HARDCODED_SR_ID_``YZA``_x[2],     decode_cs_HARDCODED_SR_ID_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_RD_``YZA``_mux,     1,             decode_cs_HARDCODED_DR_RD_``YZA,     decode_cs_HARDCODED_DR_RD_``YZA``_x[0],     decode_cs_HARDCODED_DR_RD_``YZA``_x[1],     decode_cs_HARDCODED_DR_RD_``YZA``_x[2],     decode_cs_HARDCODED_DR_RD_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_DR_WR_``YZA``_mux,     1,             decode_cs_HARDCODED_DR_WR_``YZA,     decode_cs_HARDCODED_DR_WR_``YZA``_x[0],     decode_cs_HARDCODED_DR_WR_``YZA``_x[1],     decode_cs_HARDCODED_DR_WR_``YZA``_x[2],     decode_cs_HARDCODED_DR_WR_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_RD_``YZA``_mux,     1,             decode_cs_HARDCODED_SR_RD_``YZA,     decode_cs_HARDCODED_SR_RD_``YZA``_x[0],     decode_cs_HARDCODED_SR_RD_``YZA``_x[1],     decode_cs_HARDCODED_SR_RD_``YZA``_x[2],     decode_cs_HARDCODED_SR_RD_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_SR_WR_``YZA``_mux,     1,             decode_cs_HARDCODED_SR_WR_``YZA,     decode_cs_HARDCODED_SR_WR_``YZA``_x[0],     decode_cs_HARDCODED_SR_WR_``YZA``_x[1],     decode_cs_HARDCODED_SR_WR_``YZA``_x[2],     decode_cs_HARDCODED_SR_WR_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_LD_OP_``YZA``_mux,     1,             decode_cs_HARDCODED_LD_OP_``YZA,     decode_cs_HARDCODED_LD_OP_``YZA``_x[0],     decode_cs_HARDCODED_LD_OP_``YZA``_x[1],     decode_cs_HARDCODED_LD_OP_``YZA``_x[2],     decode_cs_HARDCODED_LD_OP_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_HARDCODED_ST_OP_``YZA``_mux,     1,             decode_cs_HARDCODED_ST_OP_``YZA,     decode_cs_HARDCODED_ST_OP_``YZA``_x[0],     decode_cs_HARDCODED_ST_OP_``YZA``_x[1],     decode_cs_HARDCODED_ST_OP_``YZA``_x[2],     decode_cs_HARDCODED_ST_OP_``YZA``_x[3],     num_pfs) \
    `MUX_4(decode_cs_LD_OP_CANCEL_``YZA``_mux,        1,             decode_cs_LD_OP_CANCEL_``YZA,        decode_cs_LD_OP_CANCEL_``YZA``_x[0],        decode_cs_LD_OP_CANCEL_``YZA``_x[1],        decode_cs_LD_OP_CANCEL_``YZA``_x[2],        decode_cs_LD_OP_CANCEL_``YZA``_x[3],        num_pfs) \
    `MUX_4(decode_cs_ST_OP_CANCEL_``YZA``_mux,        1,             decode_cs_ST_OP_CANCEL_``YZA,        decode_cs_ST_OP_CANCEL_``YZA``_x[0],        decode_cs_ST_OP_CANCEL_``YZA``_x[1],        decode_cs_ST_OP_CANCEL_``YZA``_x[2],        decode_cs_ST_OP_CANCEL_``YZA``_x[3],        num_pfs) \
    `MUX_4(decode_cs_OP_IN_MODRM_``YZA``_mux,         1,             decode_cs_OP_IN_MODRM_``YZA,         decode_cs_OP_IN_MODRM_``YZA``_x[0],         decode_cs_OP_IN_MODRM_``YZA``_x[1],         decode_cs_OP_IN_MODRM_``YZA``_x[2],         decode_cs_OP_IN_MODRM_``YZA``_x[3],         num_pfs) \
    `MUX_4(decode_cs_DATA_SIZE_``YZA``_mux,           2,             decode_cs_DATA_SIZE_``YZA,           decode_cs_DATA_SIZE_``YZA``_x[0],           decode_cs_DATA_SIZE_``YZA``_x[1],           decode_cs_DATA_SIZE_``YZA``_x[2],           decode_cs_DATA_SIZE_``YZA``_x[3],           num_pfs) \
    `MUX_4(rr_cs_ST_SEL_``YZA``_mux,                  1,             rr_cs_ST_SEL_``YZA,                  rr_cs_ST_SEL_``YZA``_x[0],                  rr_cs_ST_SEL_``YZA``_x[1],                  rr_cs_ST_SEL_``YZA``_x[2],                  rr_cs_ST_SEL_``YZA``_x[3],                  num_pfs) \
    `MUX_4(rr_cs_MODRM_NEEDED_``YZA``_mux,            1,             rr_cs_MODRM_NEEDED_``YZA,            rr_cs_MODRM_NEEDED_``YZA``_x[0],            rr_cs_MODRM_NEEDED_``YZA``_x[1],            rr_cs_MODRM_NEEDED_``YZA``_x[2],            rr_cs_MODRM_NEEDED_``YZA``_x[3],            num_pfs) \
    `MUX_4(rr_cs_RM_IS_DR_``YZA``_mux,                1,             rr_cs_RM_IS_DR_``YZA,                rr_cs_RM_IS_DR_``YZA``_x[0],                rr_cs_RM_IS_DR_``YZA``_x[1],                rr_cs_RM_IS_DR_``YZA``_x[2],                rr_cs_RM_IS_DR_``YZA``_x[3],                num_pfs) \
    `MUX_4(rr_cs_SWITCH_LD_ADDY_``YZA``_mux,          1,             rr_cs_SWITCH_LD_ADDY_``YZA,          rr_cs_SWITCH_LD_ADDY_``YZA``_x[0],          rr_cs_SWITCH_LD_ADDY_``YZA``_x[1],          rr_cs_SWITCH_LD_ADDY_``YZA``_x[2],          rr_cs_SWITCH_LD_ADDY_``YZA``_x[3],          num_pfs) \
    `MUX_4(rr_cs_LD_OP_``YZA``_mux,                   1,             rr_cs_LD_OP_``YZA,                   rr_cs_LD_OP_``YZA``_x[0],                   rr_cs_LD_OP_``YZA``_x[1],                   rr_cs_LD_OP_``YZA``_x[2],                   rr_cs_LD_OP_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_ST_OP_``YZA``_mux,                   1,             rr_cs_ST_OP_``YZA,                   rr_cs_ST_OP_``YZA``_x[0],                   rr_cs_ST_OP_``YZA``_x[1],                   rr_cs_ST_OP_``YZA``_x[2],                   rr_cs_ST_OP_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_dr_id_``YZA``_mux,                   `REG_ID_W,     rr_cs_dr_id_``YZA,                   rr_cs_dr_id_``YZA``_x[0],                   rr_cs_dr_id_``YZA``_x[1],                   rr_cs_dr_id_``YZA``_x[2],                   rr_cs_dr_id_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_id_``YZA``_mux,                   `REG_ID_W,     rr_cs_sr_id_``YZA,                   rr_cs_sr_id_``YZA``_x[0],                   rr_cs_sr_id_``YZA``_x[1],                   rr_cs_sr_id_``YZA``_x[2],                   rr_cs_sr_id_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_dr_rd_``YZA``_mux,                   1,             rr_cs_dr_rd_``YZA,                   rr_cs_dr_rd_``YZA``_x[0],                   rr_cs_dr_rd_``YZA``_x[1],                   rr_cs_dr_rd_``YZA``_x[2],                   rr_cs_dr_rd_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_rd_``YZA``_mux,                   1,             rr_cs_sr_rd_``YZA,                   rr_cs_sr_rd_``YZA``_x[0],                   rr_cs_sr_rd_``YZA``_x[1],                   rr_cs_sr_rd_``YZA``_x[2],                   rr_cs_sr_rd_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_eax_rd_``YZA``_mux,                  1,             rr_cs_eax_rd_``YZA,                  rr_cs_eax_rd_``YZA``_x[0],                  rr_cs_eax_rd_``YZA``_x[1],                  rr_cs_eax_rd_``YZA``_x[2],                  rr_cs_eax_rd_``YZA``_x[3],                  num_pfs) \
    `MUX_4(rr_cs_dr_wr_``YZA``_mux,                   1,             rr_cs_dr_wr_``YZA,                   rr_cs_dr_wr_``YZA``_x[0],                   rr_cs_dr_wr_``YZA``_x[1],                   rr_cs_dr_wr_``YZA``_x[2],                   rr_cs_dr_wr_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_sr_wr_``YZA``_mux,                   1,             rr_cs_sr_wr_``YZA,                   rr_cs_sr_wr_``YZA``_x[0],                   rr_cs_sr_wr_``YZA``_x[1],                   rr_cs_sr_wr_``YZA``_x[2],                   rr_cs_sr_wr_``YZA``_x[3],                   num_pfs) \
    `MUX_4(rr_cs_eax_wr_``YZA``_mux,                  1,             rr_cs_eax_wr_``YZA,                  rr_cs_eax_wr_``YZA``_x[0],                  rr_cs_eax_wr_``YZA``_x[1],                  rr_cs_eax_wr_``YZA``_x[2],                  rr_cs_eax_wr_``YZA``_x[3],                  num_pfs) \
    `MUX_4(rr_cs_MOVS_OP_``YZA``_mux,                 1,             rr_cs_MOVS_OP_``YZA,                 rr_cs_MOVS_OP_``YZA``_x[0],                 rr_cs_MOVS_OP_``YZA``_x[1],                 rr_cs_MOVS_OP_``YZA``_x[2],                 rr_cs_MOVS_OP_``YZA``_x[3],                 num_pfs) \
    `MUX_4(rr_cs_datasize_``YZA``_mux,                2,             rr_cs_datasize_``YZA,                rr_cs_datasize_``YZA``_x[0],                rr_cs_datasize_``YZA``_x[1],                rr_cs_datasize_``YZA``_x[2],                rr_cs_datasize_``YZA``_x[3],                num_pfs) \
    `MUX_4(rr_cs_will_mod_zf_``YZA``_mux,             1,             rr_cs_will_mod_zf_``YZA,             rr_cs_will_mod_zf_``YZA``_x[0],             rr_cs_will_mod_zf_``YZA``_x[1],             rr_cs_will_mod_zf_``YZA``_x[2],             rr_cs_will_mod_zf_``YZA``_x[3],             num_pfs) \
    `MUX_4(rr_cs_seg_1_valid_``YZA``_mux,             1,             rr_cs_seg_1_valid_``YZA,             rr_cs_seg_1_valid_``YZA``_x[0],             rr_cs_seg_1_valid_``YZA``_x[1],             rr_cs_seg_1_valid_``YZA``_x[2],             rr_cs_seg_1_valid_``YZA``_x[3],             num_pfs) \
    `MUX_4(rr_cs_seg_0_id_``YZA``_mux,                `REG_ID_W,     rr_cs_seg_0_id_``YZA,                rr_cs_seg_0_id_``YZA``_x[0],                rr_cs_seg_0_id_``YZA``_x[1],                rr_cs_seg_0_id_``YZA``_x[2],                rr_cs_seg_0_id_``YZA``_x[3],                num_pfs) \
    `MUX_4(rr_cs_seg_1_id_``YZA``_mux,                `REG_ID_W,     rr_cs_seg_1_id_``YZA,                rr_cs_seg_1_id_``YZA``_x[0],                rr_cs_seg_1_id_``YZA``_x[1],                rr_cs_seg_1_id_``YZA``_x[2],                rr_cs_seg_1_id_``YZA``_x[3],                num_pfs) \
    `MUX_4(rr_cs_special_modrm_bs_``YZA``_mux,        1,             rr_cs_special_modrm_bs_``YZA,        rr_cs_special_modrm_bs_``YZA``_x[0],        rr_cs_special_modrm_bs_``YZA``_x[1],        rr_cs_special_modrm_bs_``YZA``_x[2],        rr_cs_special_modrm_bs_``YZA``_x[3],        num_pfs) \
    `MUX_4(rr_cs_special_br_``YZA``_mux,              1,             rr_cs_special_br_``YZA,              rr_cs_special_br_``YZA``_x[0],              rr_cs_special_br_``YZA``_x[1],              rr_cs_special_br_``YZA``_x[2],              rr_cs_special_br_``YZA``_x[3],              num_pfs) \
    `MUX_4(dc_cs_LD_OP_``YZA``_mux,                   1,             dc_cs_LD_OP_``YZA,                   dc_cs_LD_OP_``YZA``_x[0],                   dc_cs_LD_OP_``YZA``_x[1],                   dc_cs_LD_OP_``YZA``_x[2],                   dc_cs_LD_OP_``YZA``_x[3],                   num_pfs) \
    `MUX_4(dc_cs_ST_OP_``YZA``_mux,                   1,             dc_cs_ST_OP_``YZA,                   dc_cs_ST_OP_``YZA``_x[0],                   dc_cs_ST_OP_``YZA``_x[1],                   dc_cs_ST_OP_``YZA``_x[2],                   dc_cs_ST_OP_``YZA``_x[3],                   num_pfs) \
    `MUX_4(dc_cs_dr_upper8_``YZA``_mux,               1,             dc_cs_dr_upper8_``YZA,               dc_cs_dr_upper8_``YZA``_x[0],               dc_cs_dr_upper8_``YZA``_x[1],               dc_cs_dr_upper8_``YZA``_x[2],               dc_cs_dr_upper8_``YZA``_x[3],               num_pfs) \
    `MUX_4(dc_cs_sr_upper8_``YZA``_mux,               1,             dc_cs_sr_upper8_``YZA,               dc_cs_sr_upper8_``YZA``_x[0],               dc_cs_sr_upper8_``YZA``_x[1],               dc_cs_sr_upper8_``YZA``_x[2],               dc_cs_sr_upper8_``YZA``_x[3],               num_pfs) \
    `MUX_4(dc_cs_datasize_``YZA``_mux,                2,             dc_cs_datasize_``YZA,                dc_cs_datasize_``YZA``_x[0],                dc_cs_datasize_``YZA``_x[1],                dc_cs_datasize_``YZA``_x[2],                dc_cs_datasize_``YZA``_x[3],                num_pfs) \
    `MUX_4(mem_cs_ST_OP_``YZA``_mux,                  1,             mem_cs_ST_OP_``YZA,                  mem_cs_ST_OP_``YZA``_x[0],                  mem_cs_ST_OP_``YZA``_x[1],                  mem_cs_ST_OP_``YZA``_x[2],                  mem_cs_ST_OP_``YZA``_x[3],                  num_pfs) \
    `MUX_4(mem_cs_LD_OP_``YZA``_mux,                  1,             mem_cs_LD_OP_``YZA,                  mem_cs_LD_OP_``YZA``_x[0],                  mem_cs_LD_OP_``YZA``_x[1],                  mem_cs_LD_OP_``YZA``_x[2],                  mem_cs_LD_OP_``YZA``_x[3],                  num_pfs) \
    `MUX_4(exe_cs_ST_OP_``YZA``_mux,                  1,             exe_cs_ST_OP_``YZA,                  exe_cs_ST_OP_``YZA``_x[0],                  exe_cs_ST_OP_``YZA``_x[1],                  exe_cs_ST_OP_``YZA``_x[2],                  exe_cs_ST_OP_``YZA``_x[3],                  num_pfs) \
    `MUX_4(exe_cs_OP_TYPE_``YZA``_mux,                `EXE_OP_W,     exe_cs_OP_TYPE_``YZA,                exe_cs_OP_TYPE_``YZA``_x[0],                exe_cs_OP_TYPE_``YZA``_x[1],                exe_cs_OP_TYPE_``YZA``_x[2],                exe_cs_OP_TYPE_``YZA``_x[3],                num_pfs) \
    `MUX_4(exe_cs_alu_inputA_sel_``YZA``_mux,         `SRC_SEL_W,    exe_cs_alu_inputA_sel_``YZA,         exe_cs_alu_inputA_sel_``YZA``_x[0],         exe_cs_alu_inputA_sel_``YZA``_x[1],         exe_cs_alu_inputA_sel_``YZA``_x[2],         exe_cs_alu_inputA_sel_``YZA``_x[3],         num_pfs) \
    `MUX_4(exe_cs_alu_inputB_sel_``YZA``_mux,         `SRC_SEL_W,    exe_cs_alu_inputB_sel_``YZA,         exe_cs_alu_inputB_sel_``YZA``_x[0],         exe_cs_alu_inputB_sel_``YZA``_x[1],         exe_cs_alu_inputB_sel_``YZA``_x[2],         exe_cs_alu_inputB_sel_``YZA``_x[3],         num_pfs) \
    `MUX_4(exe_cs_branch_target_sel_``YZA``_mux,      `SRC_SEL_W,    exe_cs_branch_target_sel_``YZA,      exe_cs_branch_target_sel_``YZA``_x[0],      exe_cs_branch_target_sel_``YZA``_x[1],      exe_cs_branch_target_sel_``YZA``_x[2],      exe_cs_branch_target_sel_``YZA``_x[3],      num_pfs) \
    `MUX_4(exe_cs_shift_by_one_``YZA``_mux,           1,             exe_cs_shift_by_one_``YZA,           exe_cs_shift_by_one_``YZA``_x[0],           exe_cs_shift_by_one_``YZA``_x[1],           exe_cs_shift_by_one_``YZA``_x[2],           exe_cs_shift_by_one_``YZA``_x[3],           num_pfs) \
    `MUX_4(exe_cs_br_ucond_``YZA``_mux,               1,             exe_cs_br_ucond_``YZA,               exe_cs_br_ucond_``YZA``_x[0],               exe_cs_br_ucond_``YZA``_x[1],               exe_cs_br_ucond_``YZA``_x[2],               exe_cs_br_ucond_``YZA``_x[3],               num_pfs) \
    `MUX_4(exe_cs_relative_branch_``YZA``_mux,        1,             exe_cs_relative_branch_``YZA,        exe_cs_relative_branch_``YZA``_x[0],        exe_cs_relative_branch_``YZA``_x[1],        exe_cs_relative_branch_``YZA``_x[2],        exe_cs_relative_branch_``YZA``_x[3],        num_pfs) \
    `MUX_4(exe_cs_special_br_``YZA``_mux,             1,             exe_cs_special_br_``YZA,             exe_cs_special_br_``YZA``_x[0],             exe_cs_special_br_``YZA``_x[1],             exe_cs_special_br_``YZA``_x[2],             exe_cs_special_br_``YZA``_x[3],             num_pfs) \
    `MUX_4(exe_cs_is_far_``YZA``_mux,                 1,             exe_cs_is_far_``YZA,                 exe_cs_is_far_``YZA``_x[0],                 exe_cs_is_far_``YZA``_x[1],                 exe_cs_is_far_``YZA``_x[2],                 exe_cs_is_far_``YZA``_x[3],                 num_pfs) \
    `MUX_4(exe_cs_is_call_``YZA``_mux,                1,             exe_cs_is_call_``YZA,                exe_cs_is_call_``YZA``_x[0],                exe_cs_is_call_``YZA``_x[1],                exe_cs_is_call_``YZA``_x[2],                exe_cs_is_call_``YZA``_x[3],                num_pfs) \
    `MUX_4(exe_cs_second_flag_needed_``YZA``_mux,     1,             exe_cs_second_flag_needed_``YZA,     exe_cs_second_flag_needed_``YZA``_x[0],     exe_cs_second_flag_needed_``YZA``_x[1],     exe_cs_second_flag_needed_``YZA``_x[2],     exe_cs_second_flag_needed_``YZA``_x[3],     num_pfs) \
    `MUX_4(exe_cs_rep_no_zf_update_``YZA``_mux,       1,             exe_cs_rep_no_zf_update_``YZA,       exe_cs_rep_no_zf_update_``YZA``_x[0],       exe_cs_rep_no_zf_update_``YZA``_x[1],       exe_cs_rep_no_zf_update_``YZA``_x[2],       exe_cs_rep_no_zf_update_``YZA``_x[3],       num_pfs) \
    `MUX_4(wb_cs_ST_OP_``YZA``_mux,                   1,             wb_cs_ST_OP_``YZA,                   wb_cs_ST_OP_``YZA``_x[0],                   wb_cs_ST_OP_``YZA``_x[1],                   wb_cs_ST_OP_``YZA``_x[2],                   wb_cs_ST_OP_``YZA``_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_DR_``YZA``_mux,                   1,             wb_cs_WB_DR_``YZA,                   wb_cs_WB_DR_``YZA``_x[0],                   wb_cs_WB_DR_``YZA``_x[1],                   wb_cs_WB_DR_``YZA``_x[2],                   wb_cs_WB_DR_``YZA``_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_SR_``YZA``_mux,                   1,             wb_cs_WB_SR_``YZA,                   wb_cs_WB_SR_``YZA``_x[0],                   wb_cs_WB_SR_``YZA``_x[1],                   wb_cs_WB_SR_``YZA``_x[2],                   wb_cs_WB_SR_``YZA``_x[3],                   num_pfs) \
    `MUX_4(wb_cs_WB_EAX_``YZA``_mux,                  1,             wb_cs_WB_EAX_``YZA,                  wb_cs_WB_EAX_``YZA``_x[0],                  wb_cs_WB_EAX_``YZA``_x[1],                  wb_cs_WB_EAX_``YZA``_x[2],                  wb_cs_WB_EAX_``YZA``_x[3],                  num_pfs)
