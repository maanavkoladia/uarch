UARCH_GATES_LIB = \
		lib/Gates/lib1.v
		lib/Gates/lib2.v
		lib/Gates/lib3.v
		lib/Gates/lib4.v
		lib/Gates/lib5.v
		lib/Gates/lib6.v
		lib/Gates/time.v

COMMON_GATES_LIB = \
				   lib/LOG.v 	\
				   lib/utils.v	\

STD_CELLS_LIB = \
				lib/STDCells/reg1b.sv	\

LIB_SRC_FILES = \
				$(UARCH_GATES_LIB)	\
				$(COMMON_GATES_LIB)	\
				$(STD_CELLS_LIB) \

