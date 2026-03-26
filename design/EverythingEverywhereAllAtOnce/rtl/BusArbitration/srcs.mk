BUS_ARB_PATH_INTERNAL = $(ROOT)/rtl/BusArbitration/

BUS_ARB_GEN_SRC_FILES = \

BUS_ARB_SRC_FILES = \
					$(BUS_ARB_GEN_SRC_FILES)	\
					$(BUS_ARB_PATH_INTERNAL)/Scheduler/Scheduler_DCachePicking.sv \
					$(BUS_ARB_PATH_INTERNAL)/Scheduler/Scheduler.sv	\
					$(BUS_ARB_PATH_INTERNAL)/BusArbitration.sv	\

BUS_ARB_PKGS = \
			   $(BUS_ARB_PATH_INTERNAL)/pkg/BusArbitration_common_pkg.sv
