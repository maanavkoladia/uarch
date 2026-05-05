DCACHE_PATH_INTERNAL = $(ROOT)/rtl/DCache/


DCACHE_GEN_SRC_FILES = \
					   $(DCACHE_PATH_INTERNAL)/gen/DCache_Bank_FSM.sv	\
					   $(DCACHE_PATH_INTERNAL)/gen/VCache_FSM.sv	\


DCACHE_SRC_FILES = \
					$(DCACHE_GEN_SRC_FILES)	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/DCache_Bank/DCache_Bank_DataStore.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/DCache_Bank/DCache_Bank_TagStore.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/DCache_Bank/DCache_Bank.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/VCache/LRU.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/VCache/VCache_DataStore.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/VCache/VCache_TagStore.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/VCache/VCache.sv	\
					$(DCACHE_PATH_INTERNAL)DCache_Block/EvictionBuf/EvictionBuf.sv \
					$(DCACHE_PATH_INTERNAL)DCache_Block/DCache_Block.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_Arbitration.sv	\
					$(DCACHE_PATH_INTERNAL)/DCache_TOP.sv	\
					$(DCACHE_PATH_INTERNAL)/MIO/MIO_Block.sv	\


DCACHE_PKGS = \
			  $(DCACHE_PATH_INTERNAL)/pkg/DCache_common_pkg.sv

DCACHE_STRUCTURAL_SRC_FILES = \
			  $(DCACHE_GEN_SRC_FILES) \
			  $(DCACHE_PATH_INTERNAL)/structural/fanout/*.*v						  
