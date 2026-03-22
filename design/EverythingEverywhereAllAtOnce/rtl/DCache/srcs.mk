DCACHE_PATH_INTERNAL = $(ROOT)/rtl/DCache/

DCACHE_GEN_SRC_FILES = \
					   $(DCACHE_PATH_INTERNAL)/gen/DCache_Bank_FSM.sv	\
					   $(DCACHE_PATH_INTERNAL)/gen/VCache_FSM.sv	\


DCACHE_SRC_FILES = \
					$(DCACHE_GEN_SRC_FILES)	\
					$(DCACHE_PATH_INTERNAL)/DCache_Bank/DCache_Bank_DataStore.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_Bank/DCache_Bank_TagStore.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_Bank/DCache_Bank.sv	\
					$(DCACHE_PATH_INTERNAL)/VCache/VCache_DataStore.sv	\
					$(DCACHE_PATH_INTERNAL)/VCache/VCache_TagStore.sv	\
					$(DCACHE_PATH_INTERNAL)/VCache/VCache.sv	\
					$(DCACHE_PATH_INTERNAL)/EvictionBuf/EvictionBuf.sv \
					$(DCACHE_PATH_INTERNAL)/DCache_Block.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_Arbitration.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_TOP.sv	\


DCACHE_PKGS = \
			  $(DCACHE_PATH_INTERNAL)/pkg/DCache_pkg.sv
