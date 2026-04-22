RTL_ROOT_PATH_INTERNAL = $(ROOT)/rtl/

include $(RTL_ROOT_PATH_INTERNAL)/core/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/mem/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/DCache/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/ICache/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/BusArbitration/srcs.mk
include $(RTL_ROOT_PATH_INTERNAL)/io/srcs.mk


RTL_DESIGN_SRC_FILES = \
					   $(MEM_SRC_FILES)	\
					   $(ICACHE_SRC_FILES)	\
					   $(DCACHE_SRC_FILES) \
					   $(BUS_ARB_SRC_FILES)	\
					   $(IO_SRC_FILES)	\
					   $(CORE_SRC_FILES) \
 					   $(RTL_ROOT_PATH_INTERNAL)/Everywhere_TOP.sv \
 					   $(RTL_ROOT_PATH_INTERNAL)/AllAtOnce_TOP.sv \

RTL_DESIGN_TOP_LEVEL_PKGS = \
				  $(RTL_ROOT_PATH_INTERNAL)/pkgs/common_pkg.sv \
				  $(RTL_ROOT_PATH_INTERNAL)/pkgs/interconnect_pkg.sv	\


RTL_DESIGN_PKGS = \
				  $(RTL_DESIGN_TOP_LEVEL_PKGS)	\
				  $(CORE_PKGS)	\
				  $(ICACHE_PKGS)	\
				  $(MEM_PKGS) \
				  $(BUS_ARB_PKGS)	\
				  $(IO_PKGS)	\
				  $(DCACHE_PKGS)

RTL_DESIGN_STRUCTURAL_SRC_FILES = \
					   $(MEM_STRUCTURAL_SRC_FILES)	\
					   $(ICACHE_STRUCTURAL_SRC_FILES)	\
					   $(DCACHE_STRUCTURAL_SRC_FILES) \
					   $(BUS_ARB_STRUCTURAL_SRC_FILES)	\
					   $(IO_STRUCTURAL_SRC_FILES)	\
					   $(CORE_STRUCTURAL_SRC_FILES) \
					   $(RTL_ROOT_PATH_INTERNAL)/structural/Everywhere_TOP_structural.v \
					   $(RTL_ROOT_PATH_INTERNAL)/AllAtOnce_TOP.sv \

RTL_DESIGN_STRUCTURAL_HEADERS = \
								$(RTL_ROOT_PATH_INTERNAL)/defines/common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/interconnect_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/BusArbitration_common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/core_stage_latches_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/DCache_common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/DTE_FSM_gen_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/ICache_common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/io_common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/mem_common_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/reg_ids_define.vh \
								$(RTL_ROOT_PATH_INTERNAL)/defines/TLB_define.vh



