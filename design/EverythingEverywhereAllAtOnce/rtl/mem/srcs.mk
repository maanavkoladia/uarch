MAIN_MEM_PATH_INTERNAL = $(ROOT)/rtl/mem/

MEM_SRC_FILES_GEN = \
					$(MAIN_MEM_PATH_INTERNAL)/Mem_Banks/gen/bank_controller_fsm_logic.sv \
					$(MAIN_MEM_PATH_INTERNAL)/Mem_Controller/gen/mem_controller_fsm.sv	


MEM_SRC_FILES = \
				$(MEM_SRC_FILES_GEN) \
				$(MAIN_MEM_PATH_INTERNAL)/Mem_Banks/mem_bank.sv \
				$(MAIN_MEM_PATH_INTERNAL)/Mem_Controller/mem_controller.sv \
				$(MAIN_MEM_PATH_INTERNAL)/mem_TOP.sv	\

MEM_PKGS = \
		   $(MAIN_MEM_PATH_INTERNAL)/pkg/mem_common_pkg.sv 

MEM_STRUCTURAL_SRC_FILES = \
						   $(MEM_SRC_FILES_GEN)	\
						   $(MAIN_MEM_PATH_INTERNAL)/mem_TOP_structural.v \
						   $(MAIN_MEM_PATH_INTERNAL)/Mem_Banks/structural/MemBank_Structural.v \
						   $(MAIN_MEM_PATH_INTERNAL)/Mem_Controller/structural/mem_controller_structural.v \
