RTL_ROOT_PATH_INTERNAL = $(ROOT)/rtl/

include $(RTL_ROOT_PATH_INTERNAL)/core/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/mem/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/DCache/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/ICache/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/BusArbitration/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/io/srcs.mk


RTL_DESIGN_SRC_FILES = \
					   $(ICACHE_SRC_FILES)	\
					   $(MEM_SRC_FILES)	\
					   $(DCACHE_SRC_FILES) \
					   $(BUS_ARB_SRC_FILES)	\
					   $(IO_SRC_FILES)	\
					   $(CORE_SRC_FILES)	\
					   $(RTL_ROOT_PATH_INTERNAL)/TOP.sv	\


RTL_DESIGN_TOP_LEVEL_PKGS = \
				  $(RTL_ROOT_PATH_INTERNAL)/pkgs/common_pkg.sv \
				  $(RTL_ROOT_PATH_INTERNAL)/pkgs/types_pkg.sv	\
				  $(RTL_ROOT_PATH_INTERNAL)/pkgs/interconnect_pkg.sv	\


RTL_DESIGN_PKGS = \
				  $(RTL_DESIGN_TOP_LEVEL_PKGS)	\
				  $(CORE_PKGS)	\
				  $(ICACHE_PKGS)	\
				  $(MEM_PKGS) \
				  $(BUS_ARB_PKGS)	\
				  $(IO_PKGS)	\
				  $(DCACHE_PKGS)
