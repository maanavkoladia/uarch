MEM_SRC_FILES_BANKS = \
					  rtl/mem/Mem_Banks/mem_bank.sv \
					  rtl/mem/Mem_Banks/gen/bank_controller_fsm_logic.sv	\


MEM_SRC_FILES_CONTROLLER = \
						   rtl/mem/Mem_Controller/mem_controller.sv \
						   rtl/mem/Mem_Controller/gen/mem_controller_fsm.sv

MEM_SRC_FILES = \
				rtl/mem/mem_TOP.sv	\
				$(MEM_SRC_FILES_BANKS)	\
				$(MEM_SRC_FILES_CONTROLLER)


