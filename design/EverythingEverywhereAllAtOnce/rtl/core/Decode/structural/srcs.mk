DECODE_PATH_INTERNAL = $(ROOT)/rtl/core/Decode/structural/

GEN_DECODE_SRC_FILES = \
						  $(DECODE_PATH_INTERNAL)/gen/MOD_LUT.v \
						  $(DECODE_PATH_INTERNAL)/gen/OP_LUT.v	\
						  $(DECODE_PATH_INTERNAL)/gen/PF_LUT.v \
						  $(DECODE_PATH_INTERNAL)/gen/ir_logic.v \
						  $(DECODE_PATH_INTERNAL)/three_input_adder.v \

DECODE_SRC_FILES_STRUCTURAL = \
								$(DECODE_PATH_INTERNAL)/modrm_size.v \
								$(DECODE_PATH_INTERNAL)/op_size.v \
								$(DECODE_PATH_INTERNAL)/pf_checker.v \
								$(DECODE_PATH_INTERNAL)/num_pf_gen.v \
								$(DECODE_PATH_INTERNAL)/pf_vector_gen.v \
								$(DECODE_PATH_INTERNAL)/ppu.v	\
								$(DECODE_PATH_INTERNAL)/selection_logic.v	\
								$(DECODE_PATH_INTERNAL)/predecode.v \


