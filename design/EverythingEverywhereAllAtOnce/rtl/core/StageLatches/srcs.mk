STAGE_LATCH_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/StageLatches/


#no packages
STAGE_LATCHES_SRC_FILES = \
				 $(STAGE_LATCH_PATH_INTERNAL)/StageLatches/DC_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/StageLatches/EXE_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/StageLatches/MEM_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/StageLatches/RR_Latches.sv \
				 $(STAGE_LATCH_PATH_INTERNAL)/StageLatches/WB_Latches.sv \


STAGE_LATCHES_STRUCTURAL_SRC_FILES  = \
									  $(STAGE_LATCH_PATH_INTERNAL)/structural/*.sv
