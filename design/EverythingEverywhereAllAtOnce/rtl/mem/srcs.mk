MEM_SRC_FILES_BANKS = \
					  $(ROOT)/rtl/mem/Mem_Banks/mem_bank.sv \
					  $(ROOT)/rtl/mem/Mem_Banks/gen/bank_controller_fsm_logic.sv


MEM_SRC_FILES_CONTROLLER = \
						   $(ROOT)/rtl/mem/Mem_Controller/gen/mem_controller_fsm.sv	\
						   $(ROOT)/rtl/mem/Mem_Controller/mem_controller.sv \

MEM_SRC_FILES = \
				$(MEM_SRC_FILES_BANKS)	\
				$(MEM_SRC_FILES_CONTROLLER)	\
				$(ROOT)/rtl/mem/mem_TOP.sv	\

MEM_PKGS = \
		   $(ROOT)/rtl/mem/pkg/mem_common_pkg.sv 
