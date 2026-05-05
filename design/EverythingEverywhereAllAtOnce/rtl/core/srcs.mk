CORE_PATH_INTERNAL = $(ROOT)/rtl/core/

include $(CORE_PATH_INTERNAL)/Decode/srcs.mk
include $(CORE_PATH_INTERNAL)/Fetch/srcs.mk
include $(CORE_PATH_INTERNAL)/RR/srcs.mk
include $(CORE_PATH_INTERNAL)/DC/srcs.mk
include $(CORE_PATH_INTERNAL)/EXE/srcs.mk
include $(CORE_PATH_INTERNAL)/MEM/srcs.mk
include $(CORE_PATH_INTERNAL)/WB/srcs.mk
include $(CORE_PATH_INTERNAL)/StageLatches/srcs.mk

CORE_SRC_FILES = \
				 $(CORE_PATH_INTERNAL)/IDM/IDM.sv	\
				 $(CORE_PATH_INTERNAL)/TLB/TLB_structural.v \
				 $(FETCH_SRC_FILES) \
				 $(DECODE_SRC_FILES) \
				 $(RR_SRC_FILES) \
				 $(DC_SRC_FILES) \
				 $(MEM_STAGE_SRC_FILES) \
				 $(EXE_SRC_FILES)\
				 $(WB_SRC_FILES) \
				 $(STAGE_LATCHES_SRC_FILES) \
				 $(CORE_PATH_INTERNAL)/EveryThing_TOP.sv \


CORE_PKGS = \
			$(CORE_PATH_INTERNAL)/pkgs/control_store_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/reg_ids_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_common_pkg.sv \
			$(CORE_PATH_INTERNAL)/pkgs/core_stage_latches_pkg.sv \
			$(CORE_PATH_INTERNAL)/IDM/pkg/IDM_pkg.sv	\
			$(CORE_PATH_INTERNAL)/TLB/pkg/TLB_pkg.sv \
			$(CORE_PATH_INTERNAL)/SegmentTranslation/SegmentTranslation_pkg.sv \
			$(FETCH_PKGS) \
			$(DECODE_PKGS)	\
			$(RR_PKGS)	\
			$(DC_PKGS) \
			$(WB_PKGS) \



CORE_STRUCTURAL_SRC_FILES = \
					 $(CORE_PATH_INTERNAL)/IDM/structural/IDM_structural.v	\
					 $(CORE_PATH_INTERNAL)/TLB/TLB_structural.v \
					 $(FETCH_STRUCTURAL_SRC_FILES) \
					 $(DECODE_STRUCTURAL_SRC_FILES) \
					 $(RR_STRUCTURAL_SRC_FILES) \
					 $(DC_STRUCTURAL_SRC_FILES) \
					 $(MEM_STAGE_STRUCTURAL_SRC_FILES) \
					 $(EXE_STRUCTURAL_SRC_FILES) \
					 $(WB_STRUCTURAL_SRC_FILES) \
					 $(STAGE_LATCHES_STRUCTURAL_SRC_FILES) \
					 $(CORE_PATH_INTERNAL)/EveryThing_TOP_structural.sv \

