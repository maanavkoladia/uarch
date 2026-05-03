FETCH_PATH_INTERNAL = $(CORE_PATH_INTERNAL)/Fetch/

# Fetch packages (must be compiled before modules)
FETCH_PKGS = \
	$(FETCH_PATH_INTERNAL)/pkg/Fetch_pkg.sv \
	$(FETCH_PATH_INTERNAL)/Predictor/Predictor_pkg.sv \

# Fetch source files
FETCH_SRC_FILES = \
	$(FETCH_PATH_INTERNAL)/Predictor/GShare.sv \
	$(FETCH_PATH_INTERNAL)/Predictor/two_bit_sat_count.sv \
	$(FETCH_PATH_INTERNAL)/Predictor/Predictor.sv \
	$(FETCH_PATH_INTERNAL)/BTB.sv \
	$(FETCH_PATH_INTERNAL)/SegmentTranslation.sv \
	$(FETCH_PATH_INTERNAL)/SPC_Sel_Logic.sv \
	$(FETCH_PATH_INTERNAL)/IDM_Ctrl_Logic.sv \
	$(FETCH_PATH_INTERNAL)/IDM_Invalidate_Logic.sv \
	$(FETCH_PATH_INTERNAL)/EXP_Set_logic.sv \
	$(FETCH_PATH_INTERNAL)/EXP_Ctrl_ROMS.sv \
	$(FETCH_PATH_INTERNAL)/ICache_En_Logic.sv \
	$(FETCH_PATH_INTERNAL)/Fetch.sv \

FETCH_STRUCTURAL_SRC_FILES = \
	$(FETCH_PATH_INTERNAL)/structural/*.sv
