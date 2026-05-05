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

# Explicit list (no glob) -- the structural folder also contains
# WB_structural.sv (the SV/struct-port reference), which must not be
# compiled alongside the flat-port WB_structural.v.
WB_STRUCTURAL_SRC_FILES = \
						  $(WB_PATH_INTERNAL)/structural/MIO_Q_structural.v \
						  $(WB_PATH_INTERNAL)/structural/ST_Q_logic_structural.v \
						  $(WB_PATH_INTERNAL)/structural/ST_Q_MIO_logic_structural.v \
						  $(WB_PATH_INTERNAL)/structural/ST_Q_structural.v \
						  $(WB_PATH_INTERNAL)/structural/WB_structural.v \
