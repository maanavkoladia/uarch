ICACHE_PATH_INTERNAL = $(ROOT)/rtl/ICache/

ICACHE_GEN_SRC_FILES = \
					   $(ICACHE_PATH_INTERNAL)/gen/ICache_Controller_Logic.sv


ICACHE_SRC_FILES = \
					$(ICACHE_GEN_SRC_FILES)	\
					$(ICACHE_PATH_INTERNAL)/ICache_TagStore.sv	\
					$(ICACHE_PATH_INTERNAL)/ICache_DataStore.sv	\
					$(ICACHE_PATH_INTERNAL)/I_VCache.sv	\
					$(ICACHE_PATH_INTERNAL)/ICache.sv	\

ICACHE_PKGS = \
			  $(ICACHE_PATH_INTERNAL)/pkg/ICache_common_pkg.sv


#dont forget to add gen files when removing the icache sv files from the strucral build
ICACHE_STRUCTURAL_SRC_FILES = \
							  $(ICACHE_SRC_FILES)

