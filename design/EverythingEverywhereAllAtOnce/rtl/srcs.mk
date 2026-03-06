include $(ROOT)/rtl/mem/srcs.mk

RTL_DESIGN_SRC_FILES = $(MEM_SRC_FILES)

RTL_DESIGN_TOP_LEVEL_PKGS = \
				  $(ROOT)rtl/pkg/common_pkg.sv \
				  $(ROOT)rtl/pkg/system_bus_ifs_pkg.sv \
				  $(ROOT)rtl/pkg/types_pkg.sv \

RTL_DESIGN_PKGS = \
				  $(RTL_DESIGN_TOP_LEVEL_PKGS)	\
				  $(MEM_PKGS) \

