package ICache_common_pkg;

    import common_pkg::*;

    // Bit ranges
    localparam int ICACHE_TAG_UB = 14;
    localparam int ICACHE_TAG_LB = 8;
    localparam int ICACHE_INDEX_UB = 7;
    localparam int ICACHE_INDEX_LB = 4;
    localparam int ICACHE_OFFSET_UB = 3;
    localparam int ICACHE_OFFSET_LB = 0;

    // WIDTHS (fixed to use ICACHE_* consistently)
    localparam int ICACHE_TAG_WIDTH = (ICACHE_TAG_UB - ICACHE_TAG_LB + 1);
    localparam int ICACHE_INDEX_WIDTH = (ICACHE_INDEX_UB - ICACHE_INDEX_LB + 1);
    localparam int ICACHE_OFFSET_WIDTH = (ICACHE_OFFSET_UB - ICACHE_OFFSET_LB + 1);

    localparam int I_VCACHE_TAG_UB = 14;
    localparam int I_VCACHE_TAG_LB = 4;
    localparam int I_VCACHE_OFFSET_UB = 3;
    localparam int I_VCACHE_OFFSET_LB = 0;

    // WIDTHS (fixed to use ICACHE_* consistently)
    localparam int I_VCACHE_TAG_WIDTH = (I_VCACHE_TAG_UB - I_VCACHE_TAG_LB + 1);
    localparam int I_VCACHE_OFFSET_WIDTH = (I_VCACHE_OFFSET_UB - I_VCACHE_OFFSET_LB + 1);

    localparam int NUM_ICACHE_LINES = 16;
    localparam int NUM_I_VCACHE_LINES = 4;

    typedef struct {
        bool valid;
        p_address_t lineAddr;
        byte_t line[CACHE_LINES_SIZE_B];
    } ICache_swap_buf_t;


    typedef struct {
        logic [ICACHE_TAG_WIDTH - 1 : 0] tag;
        logic [ICACHE_INDEX_WIDTH - 1 : 0] index;
        logic [ICACHE_OFFSET_WIDTH - 1 : 0] offset;
    } p_addr_icache_fields_t;

    typedef struct {
        logic [I_VCACHE_TAG_WIDTH - 1 : 0] tag;
        logic [I_VCACHE_OFFSET_WIDTH - 1 : 0] offset;
    } p_addr_ivcache_fields_t;

    localparam int NUM_ICACHE_CONTROLLER_STATES = 7;
    typedef enum logic [$clog2(
NUM_ICACHE_CONTROLLER_STATES
) - 1 : 0] {
        IDLE  = 0,
        Fill0 = 1,
        Fill1 = 2,
        Fill2 = 3,
        Fill3 = 4,
        SWAP  = 5,
        ERROR = 6
    } icache_controller_fsm_states_e;

endpackage
