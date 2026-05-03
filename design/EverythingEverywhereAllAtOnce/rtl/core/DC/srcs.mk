DC_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/DC/

# DC packages (must be compiled before modules)
DC_PKGS = \
	$(DC_PATH_INTERNAL)/pkg/DC_pkg.sv \

GEN_DC_SRC_FILES = \
	$(DC_PATH_INTERNAL)/gen/mem_valid_logic.v \

# DC source files
DC_SRC_FILES = \
	$(GEN_DC_SRC_FILES) \
	$(DC_PATH_INTERNAL)/npu_node2.sv \
	$(DC_PATH_INTERNAL)/in_flight_sb_logic.sv \
	$(DC_PATH_INTERNAL)/wb_stq_sb_logic.sv \
	$(DC_PATH_INTERNAL)/req_gen_logic.sv \
	$(DC_PATH_INTERNAL)/data_size_vec_logic.sv \
	$(DC_PATH_INTERNAL)/segx.sv \
	$(DC_PATH_INTERNAL)/push_address_gen.sv \
	$(DC_PATH_INTERNAL)/DC.sv \

DC_STRUCTURAL_SRC_FILES = \
