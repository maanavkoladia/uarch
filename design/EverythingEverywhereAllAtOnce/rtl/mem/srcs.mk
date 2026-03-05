MEM_SRC_FILES_BANKS = \
					  $(ROOT)/mem/Mem_Banks/mem_bank.sv \
					  $(ROOT)/mem/Mem_Banks/gen/bank_controller_fsm_logic.sv	\


MEM_SRC_FILES_CONTROLLER = \
						   $(ROOT)/mem/Mem_Controller/mem_controller.sv \
						   $(ROOT)/mem/Mem_Controller/gen/mem_controller_fsm.sv

MEM_SRC_FILES = \
				$(ROOT)/mem/mem_TOP.sv	\
				$(MEM_SRC_FILES_BANKS)	\
				$(MEM_SRC_FILES_CONTROLLER)


MEM_PKGS = \
		   $(ROOT)/mem/pkg/mem_common_pkg.sv 
