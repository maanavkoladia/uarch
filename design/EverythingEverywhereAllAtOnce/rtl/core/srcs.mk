#add fetch, RR, DC, MEM, EXE, WB srcmks files

CORE_PATH_INTERNAL = $(ROOT)/rtl/core/

include $(CORE_PATH_INTERNAL)/Decode/structural/srcs.mk


CORE_GEN_SRC_FILES = \
					 $(GEN_DECODE_SRC_FILES)	\


CORE_SRC_FILES = \
				 $(CORE_GEN_SRC_FILES)	\
				 $(DECODE_SRC_FILES_STRUCTURAL)	\
				 $(CORE_PATH_INTERNAL)/IDM/IDM.sv	\
				 $(CORE_PATH_INTERNAL)/Fetch/Fetch.sv \
				 $(CORE_PATH_INTERNAL)/Decode/Decode.sv \
				 $(CORE_PATH_INTERNAL)/RR/RR.sv \
				 $(CORE_PATH_INTERNAL)/DC/DC.sv \
				 $(CORE_PATH_INTERNAL)/MEM/MEM.sv \
				 $(CORE_PATH_INTERNAL)/EXE/EXE.sv \
				 $(CORE_PATH_INTERNAL)/WB/WB.sv \
				 $(CORE_PATH_INTERNAL)/StageLatches/DC_Latches.sv \
				 $(CORE_PATH_INTERNAL)/StageLatches/EXE_Latches.sv \
				 $(CORE_PATH_INTERNAL)/StageLatches/MEM_Latches.sv \
				 $(CORE_PATH_INTERNAL)/StageLatches/RR_Latches.sv \
				 $(CORE_PATH_INTERNAL)/StageLatches/WB_Latches.sv \
				 $(CORE_PATH_INTERNAL)/CoreTop.sv \


#no prodecode pakcages rn that need ot be compiled

CORE_PKGS = \
			$(CORE_PATH_INTERNAL)/pkgs/execute_op_types_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/reg_ids_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/flag_fields_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_common_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_stage_latches_pkg.sv \
			$(CORE_PATH_INTERNAL)/IDM/pkg/IDM_pkg.sv	\
