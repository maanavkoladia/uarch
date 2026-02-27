package icache_pkg;
    import common_pkg::*;

    typedef struct {
        byte_t cacheLine[CACHE_LINES_SIZE];
        logic  valid_line;
    } I_Cache_Out_t;

    typedef struct {
        address_t mem_addr;
        logic mem_reg;
    };

endpackage

