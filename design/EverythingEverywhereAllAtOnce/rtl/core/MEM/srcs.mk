MEM_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/MEM/

# MEM packages..dont exist rn

MEM_GEN_SRC_FILES = \
	$(MEM_PATH_INTERNAL)/gen/EXE_valid_logic.v	\

#MEM source files
MEM_STAGE_SRC_FILES = \
	$(MEM_GEN_SRC_FILES) \
	$(MEM_PATH_INTERNAL)/mem_miss_stall_logic.sv \
	$(MEM_PATH_INTERNAL)/MEM.sv \

# Explicit list (no glob) -- the structural folder also contains
# MEM_structural.sv (the SV/struct-port reference), which must not be
# compiled alongside the flat-port MEM_structural.v.
MEM_STAGE_STRUCTURAL_SRC_FILES = \
								 $(MEM_GEN_SRC_FILES) \
								 $(MEM_PATH_INTERNAL)/structural/mem_miss_stall_logic_structural.v \
								 $(MEM_PATH_INTERNAL)/structural/MEM_structural.v \
