include $(ROOT)/rtl/mem/srcs.mk
include $(ROOT)/rtl/core/srcs.mk

RTL_DESIGN_SRC_FILES = \
					   $(CORE_SRC_FILES)	\
					   $(MEM_SRC_FILES)	\

RTL_DESIGN_TOP_LEVEL_PKGS = \
				  $(ROOT)rtl/pkgs/common_pkg.sv \
				  $(ROOT)rtl/pkgs/types_pkg.sv	\
				  $(ROOT)rtl/pkgs/interconnect_pkg.sv	\


RTL_DESIGN_PKGS = \
				  $(RTL_DESIGN_TOP_LEVEL_PKGS)	\
				  $(MEM_PKGS) \
				  $(CORE_PKGS)

