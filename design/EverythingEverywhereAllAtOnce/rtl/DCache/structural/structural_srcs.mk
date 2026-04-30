DCACHE_STRUCT_PATH = $(ROOT)/rtl/DCache/structural/

# Compile order: leaf modules first, then composites.
DCACHE_STRUCTURAL_SRC_FILES = \
    $(DCACHE_PATH_INTERNAL)/gen/DCache_Bank_FSM.sv \
    $(DCACHE_PATH_INTERNAL)/gen/VCache_FSM.sv \
    $(DCACHE_STRUCT_PATH)LRU.v \
    $(DCACHE_STRUCT_PATH)EvictionBuf.v \
    $(DCACHE_STRUCT_PATH)DCache_Bank_TagStore.v \
    $(DCACHE_STRUCT_PATH)DCache_Bank_DataStore.v \
    $(DCACHE_STRUCT_PATH)DCache_Bank.v \
    $(DCACHE_STRUCT_PATH)VCache_TagStore.v \
    $(DCACHE_STRUCT_PATH)VCache_DataStore.v \
    $(DCACHE_STRUCT_PATH)VCache.v \
    $(DCACHE_STRUCT_PATH)DCache_Block.v \
    $(DCACHE_STRUCT_PATH)DCache_Arbitration.v \
    $(DCACHE_STRUCT_PATH)MIO_Block.v \
    $(DCACHE_STRUCT_PATH)DCache_TOP.v
