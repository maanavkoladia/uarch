PRECODE_PATH_INTERNAL = $(ROOT)/rtl/core/PreDecode/structural/

GEN_PREDECODE_SRC_FILES = \
						  $(PRECODE_PATH_INTERNAL)/gen/MOD_LUT.v \
						  $(PRECODE_PATH_INTERNAL)/gen/OP_LUT.v

PREDECODE_SRC_FILES_STRUCTURAL = \
								$(PRECODE_PATH_INTERNAL)/modrm_size.v \
								$(PRECODE_PATH_INTERNAL)/op_size.v \
								$(PRECODE_PATH_INTERNAL)/pf_checker.v \
								$(PRECODE_PATH_INTERNAL)/pf_gen.v \
								$(PRECODE_PATH_INTERNAL)/pf_vector_gen.v \
								$(PRECODE_PATH_INTERNAL)/ppu.v	\
								$(PRECODE_PATH_INTERNAL)/predecode.v \
								$(PRECODE_PATH_INTERNAL)/selection_logic.v
