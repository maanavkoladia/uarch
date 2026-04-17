DEBUG_UTILS_PATH_INTERNAL := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Just the package file (for importing helper functions only)
DEBUG_PKG := $(DEBUG_UTILS_PATH_INTERNAL)/debug_pkg.sv

# Package + macro definitions (for using DEBUG_UTILS_INIT, etc.)
DEBUG_PKG_WITH_DEFS := \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debug_pkg.sv \
			 

# Full debug utilities (package + all task files)
DEBUG_UTILS := \
			 $(DEBUG_UTILS_PATH_INTERNAL)/tb_utils_defs.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsFetch.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsDecode.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsRR.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsDC.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsMEM.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsEXE.svh \
			 $(DEBUG_UTILS_PATH_INTERNAL)/debugUtils_WB.svh 
