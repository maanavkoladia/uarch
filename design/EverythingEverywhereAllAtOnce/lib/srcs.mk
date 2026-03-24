UARCH_GATES_LIB = \
		$(ROOT)/lib/Gates/lib1.v \
		$(ROOT)/lib/Gates/lib2.v \
		$(ROOT)/lib/Gates/lib4.v \
		$(ROOT)/lib/Gates/lib5.v \
		$(ROOT)/lib/Gates/lib3.v \
		$(ROOT)/lib/Gates/lib6.v \

#$(ROOT)/lib/Gates/time.v \

STD_CELL_LIB_GEN = $(ROOT)/lib/STDCells/gen/three_input_adder.sv

COMMON_GATES_LIB = \
				   $(ROOT)/lib/Common/LOG.v \
				   $(ROOT)/lib/Common/utils.v 

STD_CELLS_LIB = \
				$(ROOT)/lib/STDCells/triple_adder.v \
				$(ROOT)/lib/STDCells/and_N.v \
				$(ROOT)/lib/STDCells/mux2_10.v \
				$(ROOT)/lib/STDCells/mux2_3.v \
				$(ROOT)/lib/STDCells/mux4_4.v \
				$(ROOT)/lib/STDCells/mux64_8.v \
				$(ROOT)/lib/STDCells/or_N.v \
				$(ROOT)/lib/STDCells/reg1b.v \
				$(ROOT)/lib/STDCells/KoggeStone.v \

LIB_SRC_FILES = \
				$(UARCH_GATES_LIB) \
				$(STD_CELL_LIB_GEN)	\
				$(COMMON_GATES_LIB)	\
				$(STD_CELLS_LIB) 

