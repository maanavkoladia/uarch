#add fetch, RR, DC, MEM, EXE, WB srcmks files

CORE_PATH_INTERNAL = $(ROOT)/rtl/core/

include $(CORE_PATH_INTERNAL)/PreDecode/structural/srcs.mk


CORE_GEN_SRC_FILES = \
					 $(GEN_PREDECODE_SRC_FILES)

CORE_SRC_FILES = \
				 $(CORE_GEN_SRC_FILES)	\
				 $(PREDECODE_SRC_FILES_STRUCTURAL)


#no prodecode pakcages rn that need ot be compiled

CORE_PKGS = \
			$(CORE_PATH_INTERNAL)/pkgs/execute_op_types_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_common_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_stage_latches_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/segment_table_pkg.sv
