IO_PATH_INTERNAL = $(ROOT)/rtl/io/

IO_GEN_SRC_FILES = \
				   $(IO_PATH_INTERNAL)/DMA_Controller/gen/DMA_FSM.sv	


IO_SRC_FILES = \
			   $(IO_GEN_SRC_FILES)	\
			   $(IO_PATH_INTERNAL)/DMA_Controller/DMA_Controller.sv	\
			   $(IO_PATH_INTERNAL)/DMA_Controller/DiskWrapper.sv	\
			   $(IO_PATH_INTERNAL)/ddr5/ddr5.sv \

IO_PKGS = \
		  $(IO_PATH_INTERNAL)/pkg/io_common_pkg.sv

IO_STRUCTURAL_SRC_FILES = \
			   $(IO_GEN_SRC_FILES)	\
			   $(IO_PATH_INTERNAL)/DMA_Controller/structural/DiskWrapper_Behav.v \
			   $(IO_PATH_INTERNAL)/DMA_Controller/structural/DMA_Controller_structural.v \
			   $(IO_PATH_INTERNAL)/ddr5/structural/ddr5_structural.v \
