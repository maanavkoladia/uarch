UARCH_GATES_LIB = \
		$(ROOT)/lib/Gates/lib1.v \
		$(ROOT)/lib/Gates/lib2.v \
		$(ROOT)/lib/Gates/lib4.v \
		$(ROOT)/lib/Gates/lib5.v \
		$(ROOT)/lib/Gates/lib3.v \
		$(ROOT)/lib/Gates/lib6.v \

#$(ROOT)/lib/Gates/time.v \

COMMON_GATES_LIB = \
				   $(ROOT)/lib/Common/LOG.v \
				   $(ROOT)/lib/Common/utils.v 

STD_CELLS_LIB = \
			$(ROOT)/lib/STDCells/MUX_Multi.v \
			$(ROOT)/lib/STDCells/NAND_N_NOR_N.v \
			$(ROOT)/lib/STDCells/AND_multi.v \
			$(ROOT)/lib/STDCells/OR_multi.v \
			$(ROOT)/lib/STDCells/AND_N.v \
			$(ROOT)/lib/STDCells/OR_N.v \
			$(ROOT)/lib/STDCells/MUX_N.v \
			$(ROOT)/lib/STDCells/decoder_N.v \
			$(ROOT)/lib/STDCells/UniqueLib.v \
			$(ROOT)/lib/STDCells/REG_N.v \
			$(ROOT)/lib/STDCells/STDCell_Macros.vh	\
			$(ROOT)/lib/STDCells/triple_adder.v \
			$(ROOT)/lib/STDCells/KoggeStone.v \
			$(ROOT)/lib/STDCells/KoggeStone_r4.v \

			#$(ROOT)/lib/STDCells/4_2_pendcoder.v 

LIB_SRC_FILES = \
				$(UARCH_GATES_LIB) \
				$(COMMON_GATES_LIB)	\
				$(STD_CELLS_LIB) 

