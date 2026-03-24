DC_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/DC/

# DC packages (must be compiled before modules)
DC_PKGS = \
	$(DC_PATH_INTERNAL)/pkg/DC_pkg.sv \

# DC source files
DC_SRC_FILES = \
	$(DC_PATH_INTERNAL)/in_flight_sb_logic.sv \
	$(DC_PATH_INTERNAL)/wb_stq_sb_logic.sv \
	$(DC_PATH_INTERNAL)/req_gen_logic.sv \
	$(DC_PATH_INTERNAL)/DC.sv \
