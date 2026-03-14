IO_PATH_INTERNAL = $(ROOT)/rtl/io/

IO_GEN_SRC_FILES = \


IO_SRC_FILES = \
					$(IO_GEN_SRC_FILES)	\
					$(IO_PATH_INTERNAL)/DMA_Controller/DMA_Controller.sv	\
					$(IO_PATH_INTERNAL)/ddr5/ddr5.sv \

IO_PKGS = \
