EXE_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/EXE/
EXE_PATH_INTERNAL_STRUCTURAL = $(CORE_PATH_INTERNAL)/EXE/structural

# EXE packages (none - uses common_pkg and control_store_pkg from core/pkgs)
EXE_PKGS = \

GEN_EXE_SRC_FILES = \
    $(EXE_PATH_INTERNAL)/gen/wb_valid_logic.v \

# EXE source files
EXE_SRC_FILES = \
	$(GEN_EXE_SRC_FILES) \
    $(EXE_PATH_INTERNAL)/alu_input_sel.sv \
    $(EXE_PATH_INTERNAL)/bit_vec_logic.sv \
    $(EXE_PATH_INTERNAL)/branch_res.sv \
    $(EXE_PATH_INTERNAL)/res_buf_logic.sv \
    $(EXE_PATH_INTERNAL)/res_buf_sel.sv \
    $(EXE_PATH_INTERNAL)/dr_sel.sv \
    $(EXE_PATH_INTERNAL)/sr_sel.sv \
    $(EXE_PATH_INTERNAL)/reg_wb_logic.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/af_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/cf_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/df_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/of_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/pf_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/sf_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/flag_sel/zf_flag_sel.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/aaa_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/adc_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/add_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/and_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/bsf_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/call_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/cmp.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/cmpxchg_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/far_call_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/iretd_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/mov_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/not_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/or_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/packssdw.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/packsswb.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/paddd.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/paddw.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/pavgb.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/pavgw.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/pop_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/push_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/ret_far_imm_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/ret_far_ops.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/ret_imm_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/ret_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/sal_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/sar_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/sbb_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/xchg_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/movs_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/add_df_op.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/far_jmp.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/exp_call.sv \
    $(EXE_PATH_INTERNAL)/FunctionalUnits/rep_cmp.sv \
    $(EXE_PATH_INTERNAL)/EXE.sv \


EXE_STRUCTURAL_SRC_FILES = \
	$(GEN_EXE_SRC_FILES) \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/alu_input_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/bit_vec_logic_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/branch_res_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/res_buf_logic_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/res_buf_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/dr_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/sr_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/reg_wb_logic_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/af_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/cf_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/df_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/of_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/pf_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/sf_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/flag_sel/zf_flag_sel_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/flag_helpers_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/aaa_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/adc_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/add_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/and_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/bsf_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/call_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/cmp_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/cmpxchg_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/far_call_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/iretd_op_structural.v\
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/mov_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/not_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/or_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/packssdw_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/packsswb_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/paddd_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/paddw_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/pavgb_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/pavgw_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/pop_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/push_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/ret_far_imm_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/ret_far_ops_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/ret_imm_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/ret_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/sal_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/sar_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/sbb_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/xchg_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/movs_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/add_df_op_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/far_jmp_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/exp_call_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/FunctionalUnits/rep_cmp_structural.v \
    $(EXE_PATH_INTERNAL_STRUCTURAL)/EXE_structural.v \

#EXE_STRUCTURAL_FANOUT_SRC_FILES  = $(EXE_PATH_INTERNAL_STRUCTURAL)/fanout/*.*v

#EXE_STRUCTURAL_SRC_FILES = $(EXE_STRUCTURAL_FANOUT_SRC_FILE)



