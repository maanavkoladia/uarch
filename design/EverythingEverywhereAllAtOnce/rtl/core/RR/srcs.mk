RR_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/RR/

# RR packages (must be compiled before modules)
RR_PKGS = \
	$(RR_PATH_INTERNAL)/pkg/RegisterRead_pkg.sv \

RR_GEN_SRC_FILES = \
	$(RR_PATH_INTERNAL)/gen/dc_valid_logic.v \

# RR source files
RR_SRC_FILES = \
	$(RR_PATH_INTERNAL)/structural/npu_node1.v \
	$(RR_PATH_INTERNAL)/structural/RegFile.v \
	$(RR_PATH_INTERNAL)/structural/RegSB.v \
	$(RR_PATH_INTERNAL)/structural/RR_structural.sv \

RR_STRUCTURAL_SRC_FILES = \
