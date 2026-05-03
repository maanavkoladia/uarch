MEM_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/MEM/

# MEM packages..dont exist rn

GEN_MEM_SRC_FILES = \
	$(MEM_PATH_INTERNAL)/gen/EXE_valid_logic.v	\

#MEM source files
MEM_STAGE_SRC_FILES = \
	$(MEM_PATH_INTERNAL)/structural/mem_miss_stall_logic.sv \
	$(MEM_PATH_INTERNAL)/structural/MEM.sv \

MEM_STAGE_STRUCTURAL_SRC_FILES = \
	$(MEM_PATH_INTERNAL)/structural/mem_miss_stall_logic_structural.v \
	$(MEM_PATH_INTERNAL)/structural/MEM_structural.sv \
