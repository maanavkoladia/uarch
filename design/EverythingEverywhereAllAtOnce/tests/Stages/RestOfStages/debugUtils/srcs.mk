DEBUG_UTILS_PATH_INTERNAL := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

DEBUG_UTILS= \
		$(DEBUG_UTILS_PATH_INTERNAL)/debug_pkg.sv \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsFetch.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsDecode.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsRR.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsDC.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsMEM.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtilsEXE.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/debugUtils_WB.svh \
		$(DEBUG_UTILS_PATH_INTERNAL)/defs.svh \
