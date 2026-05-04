WB_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/WB/

# WB packages (must be compiled before modules)
WB_PKGS = \
	$(WB_PATH_INTERNAL)/pkg/WriteBack_pkg.sv \

# WB source files
WB_SRC_FILES = \
	$(WB_PATH_INTERNAL)/ST_Q.sv \
	$(WB_PATH_INTERNAL)/ST_Q_logic.sv \
	$(WB_PATH_INTERNAL)/ST_Q_MIO_logic.sv \
    $(WB_PATH_INTERNAL)/MIO_Q.sv \
	$(WB_PATH_INTERNAL)/WB.sv \

#$(WB_PATH_INTERNAL)/reg_wb_logic.sv

WB_STRUCTURAL_SRC_FILES = \
						  $(WB_PATH_INTERNAL)/structural/*.v \
						  $(WB_PATH_INTERNAL)/structural/WB_structural.sv
