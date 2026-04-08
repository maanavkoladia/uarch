EXE_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/EXE/

# EXE packages (none - uses common_pkg and control_store_pkg from core/pkgs)
EXE_PKGS = \

GEN_EXE_SRC_FILES = \
    $(EXE_PATH_INTERNAL)/gen/wb_valid_logic.v \

# EXE source files
EXE_SRC_FILES = \
    $(EXE_PATH_INTERNAL)/alu_input_sel.sv \
    $(EXE_PATH_INTERNAL)/bit_vec_logic.sv \
    $(EXE_PATH_INTERNAL)/branch_res.sv \
    $(EXE_PATH_INTERNAL)/cs_change_logic.sv \
    $(EXE_PATH_INTERNAL)/res_buf_logic.sv \
    $(EXE_PATH_INTERNAL)/res_buf_sel.sv \
    $(EXE_PATH_INTERNAL)/dr_sel.sv \
    $(EXE_PATH_INTERNAL)/sr_sel.sv \
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
    $(EXE_PATH_INTERNAL)/EXE.sv \

EXE_STRUCTURAL_SRC_FILES = \
						   $(GEN_EXE_SRC_FILES)
