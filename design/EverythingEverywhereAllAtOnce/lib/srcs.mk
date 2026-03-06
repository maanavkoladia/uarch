UARCH_GATES_LIB = \
		$(ROOT)/lib/Gates/lib1.v \
		$(ROOT)/lib/Gates/lib2.v \
		$(ROOT)/lib/Gates/lib3.v \
		$(ROOT)/lib/Gates/lib4.v \
		$(ROOT)/lib/Gates/lib5.v \
		$(ROOT)/lib/Gates/lib6.v \

#$(ROOT)/lib/Gates/time.v \

COMMON_GATES_LIB = \
				   $(ROOT)/lib/Common/LOG.v \
				   $(ROOT)/lib/Common/utils.v \

STD_CELLS_LIB = \
				$(ROOT)/lib/STDCells/reg1b.sv \
				$(ROOT)/lib/STDCells/and_N.v \
				$(ROOT)/lib/STDCells/or_N.v \

LIB_SRC_FILES = \
				$(UARCH_GATES_LIB) \
				$(COMMON_GATES_LIB)	\
				$(STD_CELLS_LIB) \

