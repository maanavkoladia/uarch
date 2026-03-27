BUS_ARB_PATH_INTERNAL = $(ROOT)/rtl/BusArbitration/

BUS_ARB_GEN_SRC_FILES = \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_Core_2_DDR5_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_Core_2_DMA_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_DCache_2_MEM_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_DDR5_2_Core_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_DMA_2_MEM_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_MEM_2_DCache_FSM.sv \
	$(BUS_ARB_PATH_INTERNAL)/gen/DTE_MEM_2_ICache_FSM.sv \

BUS_ARB_SRC_FILES = \
					$(BUS_ARB_GEN_SRC_FILES)	\
					$(BUS_ARB_PATH_INTERNAL)/DTE.sv \
					$(BUS_ARB_PATH_INTERNAL)/Scheduler/Scheduler_DCachePicking.sv \
					$(BUS_ARB_PATH_INTERNAL)/Scheduler/Scheduler.sv	\
					$(BUS_ARB_PATH_INTERNAL)/BusArbitration.sv	\

BUS_ARB_PKGS = \
			   $(BUS_ARB_PATH_INTERNAL)/pkg/DTE_FSM_gen_pkg.sv	\
			   $(BUS_ARB_PATH_INTERNAL)/pkg/BusArbitration_common_pkg.sv
