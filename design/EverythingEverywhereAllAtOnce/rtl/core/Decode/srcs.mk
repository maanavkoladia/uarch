DECODE_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/Decode/

DECODE_PKGS = \
						$(DECODE_PATH_INTERNAL)/pkg/Decode_pkg.sv \

GEN_DECODE_SRC_FILES = \
						  $(DECODE_PATH_INTERNAL)/structural/gen/MOD_LUT.v \
						  $(DECODE_PATH_INTERNAL)/structural/gen/OP_LUT.v	\
						  $(DECODE_PATH_INTERNAL)/structural/gen/PF_LUT.v \
						  $(DECODE_PATH_INTERNAL)/structural/gen/ir_logic.v \
						  $(DECODE_PATH_INTERNAL)/structural/gen/rep_fsm.sv \
						  $(DECODE_PATH_INTERNAL)/structural/gen/rr_valid_logic.v \

DECODE_SRC_FILES_STRUCTURAL = \
								$(DECODE_PATH_INTERNAL)/structural/disp_finder.v \
								$(DECODE_PATH_INTERNAL)/structural/imm_finder.v \
								$(DECODE_PATH_INTERNAL)/structural/modrm_size.v \
								$(DECODE_PATH_INTERNAL)/structural/num_pf_gen.v \
								$(DECODE_PATH_INTERNAL)/structural/op_size.v \
								$(DECODE_PATH_INTERNAL)/structural/pf_checker.v \
								$(DECODE_PATH_INTERNAL)/structural/pf_vector_gen.v \
								$(DECODE_PATH_INTERNAL)/structural/ppu.v \
								$(DECODE_PATH_INTERNAL)/structural/selection_logic.v \
								$(DECODE_PATH_INTERNAL)/structural/sib_finder.v \
								$(DECODE_PATH_INTERNAL)/structural/predecode.v \

DECODE_SRC_FILES = \
						$(DECODE_PATH_INTERNAL)/br_info_processing.sv \
						$(DECODE_PATH_INTERNAL)/control_store_genned.sv \
						$(DECODE_PATH_INTERNAL)/control_store.sv \
						$(DECODE_PATH_INTERNAL)/cs_post_processor.sv \
						$(DECODE_PATH_INTERNAL)/decode_gp_gen.sv \
						$(DECODE_PATH_INTERNAL)/modrm_processor.sv \
						$(DECODE_PATH_INTERNAL)/sib_processor.sv \
						$(DECODE_PATH_INTERNAL)/rep_controller.sv \
						$(DECODE_PATH_INTERNAL)/Decode.sv \

#dont add gen files here are they are includede in the core srcs.mk file
DECODE_STRUCTURAL_SRC_FILES = \
