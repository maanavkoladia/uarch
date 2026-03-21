package DCache_common_pkg;

    import common_pkg::*;

    localparam int DCACHE_NUM_BLOCKS = 4;

    localparam int DCACHE_NUM_LINES = 1 << INDEX_WIDTH;

    // Bit ranges
    localparam int DCACHE_BANK_TAG_UB = 14;
    localparam int DCACHE_BANK_TAG_LB = 9;
    localparam int DCACHE_BANK_INDEX_UB = 8;
    localparam int DCACHE_BANK_INDEX_LB = 6;
    localparam int DCACHE_BANK_BANK_UB = 5;
    localparam int DCACHE_BANK_BANK_LB = 4;
    localparam int DCACHE_BANK_OFFSET_UB = 3;
    localparam int DCACHE_BANK_OFFSET_LB = 0;

    // WIDTHS (fixed to use DCACHE_BANK_* consistently)
    localparam int DCACHE_BANK_TAG_WIDTH = (DCACHE_BANK_TAG_UB - DCACHE_BANK_TAG_LB + 1);
    localparam int DCACHE_BANK_INDEX_WIDTH = (DCACHE_BANK_INDEX_UB - DCACHE_BANK_INDEX_LB + 1);
    localparam int DCACHE_BANK_BANK_WIDTH = (DCACHE_BANK_BANK_UB - DCACHE_BANK_BANK_LB + 1);
    localparam int DCACHE_BANK_OFFSET_WIDTH = (DCACHE_BANK_OFFSET_UB - DCACHE_BANK_OFFSET_LB + 1);

    localparam int V_CACHE_TAG_UB = 14;
    localparam int V_CACHE_TAG_LB = 6;
    localparam int V_CACHE_BANK_UB = 5;
    localparam int V_CACHE_BANK_LB = 4;
    localparam int V_CACHE_L_UB = 3;
    localparam int V_CACHE_L_LB = 0;

    localparam int V_CACHE_TAG_WIDTH = (V_CACHE_TAG_UB - V_CACHE_TAG_LB + 1);  // = 9
    localparam int V_CACHE_BANK_WIDTH = (V_CACHE_BANK_UB - V_CACHE_BANK_LB + 1);  // = 2
    localparam int V_CACHE_L_WIDTH = (V_CACHE_L_UB - V_CACHE_LB + 1);  // = 4

    typedef struct {
        logic [DCACHE_BANK_TAG_WIDTH-1:0]    tag;
        logic [DCACHE_BANK_INDEX_WIDTH-1:0]  index;
        logic [DCACHE_BANK_BANK_WIDTH-1:0]   bank;
        logic [DCACHE_BANK_OFFSET_WIDTH-1:0] offset;
    } p_addr_fields_t;

    //im assuming no valid bit bc, the T/D store
    //logic revolves around oe and we which should only go LOW
    //when they are needed, i think that we are safe to drive 
    //address always
    typedef struct {
        p_address_t p_addr;
        bool oe;  //doing a ld_req,
        bool we;  //reg sayin were doigng a write at p_addr
        uint16_t vec;  //which bytes to wrte into
        byte_t st_q_data[CACHE_LINES_SIZE_B];  //data to write from st_q_head
    } block_req_t;

    typedef struct {
        byte_t line[CACHE_LINES_SIZE_B];
        p_addr lineAddr;
        bool   valid;
        bool   dirty;
    } swap_buf_t;

    typedef struct {
        byte_t data_lineOut[CACHE_LINES_SIZE_B];
        bool hit;
        bool miss;
        swap_buf_t dcache_swapBuf;
        bool V_Cache_swapBuf_valid_clr;
    } d_cache_outputs_t;

    typedef struct {
        bool valid;  //probably not needed
        byte_t lineOut[CACHE_LINES_SIZE_B];
        bool hit;
        bool miss;
        swap_buf_t vcache_swapBuf;
        bool D_Cache_swapBuf_valid_clr;
    } v_cache_outputs_t;

    typedef struct {
        bool valid;  //probably not needed
        byte_t lineOut[CACHE_LINES_SIZE_B];
        bool hit;
        bool miss;
    } eb_cache_outputs_t;

    localparam int NUM_DCACHE_BANK_FSM_STATES = 7;
    typedef enum logic [$clog2(
NUM_DCACHE_BANK_FSM_STATES
) - 1 : 0] {
        IDLE     = 3'd0,
        EVICTING = 3'd1,
        Req0     = 3'd2,
        Req1     = 3'd3,
        Req2     = 3'd4,
        Req3     = 3'd5,
        SWAPPING = 3'd6
    } dcache_bank_fsm_states_e;

endpackage
;
