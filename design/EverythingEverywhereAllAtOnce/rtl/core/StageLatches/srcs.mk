STAGE_LATCH_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/StageLatches/


#no packages
STAGE_LATCHES_SRC_FILES = \
				 $(STAGE_LATCH_PATH_INTERNAL)/DC_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/EXE_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/MEM_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/RR_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/WB_Latches.sv \


STAGE_LATCHES_STRUCTURAL_SRC_FILES = \
				 $(STAGE_LATCH_PATH_INTERNAL)/structural/DC_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/structural/EXE_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/structural/MEM_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/structural/RR_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/structural/WB_Latches.sv \
