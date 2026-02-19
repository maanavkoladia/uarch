package icache_pkg;
    import common_pkg::*;

    typedef struct {
        byte_t cacheLine[CACHE_LINES_SIZE];
        logic  valid_line;
    } icache_2_qctrl_if_t;

    typedef struct {
        address_t mem_addr;
        logic mem_reg;
    } icache_2_mem_if_t;

endpackage

