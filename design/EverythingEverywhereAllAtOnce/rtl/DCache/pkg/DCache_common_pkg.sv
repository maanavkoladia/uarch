package DCache_common_pkg;

    import common_pkg::*;
    import interconnect_pkg::*;

    localparam int DCACHE_NUM_BLOCKS = 4;

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
    localparam int V_CACHE_OFFSET_UB = 3;
    localparam int V_CACHE_OFFSET_LB = 0;

    localparam int V_CACHE_TAG_WIDTH = (V_CACHE_TAG_UB - V_CACHE_TAG_LB + 1);  // = 7
    localparam int V_CACHE_BANK_WIDTH = (V_CACHE_BANK_UB - V_CACHE_BANK_LB + 1);  // = 2
    localparam int V_CACHE_OFFSET_WIDTH = (V_CACHE_OFFSET_UB - V_CACHE_OFFSET_LB + 1);

    localparam int DCACHE_BANK_NUM_LINES = 1 << DCACHE_BANK_INDEX_WIDTH;
    localparam int VCACHE_NUM_LINES = 4;

    typedef struct {
        logic [DCACHE_BANK_TAG_WIDTH-1:0]    tag;
        logic [DCACHE_BANK_INDEX_WIDTH-1:0]  index;
        logic [DCACHE_BANK_BANK_WIDTH-1:0]   bank;
        logic [DCACHE_BANK_OFFSET_WIDTH-1:0] offset;
    } p_addr_dcache_fields_t;

    typedef struct {
        logic [V_CACHE_TAG_WIDTH-1:0]    tag;
        logic [V_CACHE_BANK_WIDTH-1:0]   bank;
        logic [V_CACHE_OFFSET_WIDTH-1:0] offset;
    } p_addr_vcache_fields_t;

    //im assuming no valid bit bc, the T/D store
    //logic revolves around oe and we which should only go LOW
    //when they are needed, i think that we are safe to drive 
    //address always
    typedef struct {
        bool oe;  //doing a ld_req,
        bool we;  //reg sayin were doigng a write at p_addr
        p_address_t p_addr;
        uint16_t vec;  //which bytes to wrte into
        byte_t st_q_data[CACHE_LINES_SIZE_B];  //data to write from st_q_head
    } block_req_t;

    typedef struct {
        byte_t dataLineOut[CACHE_LINES_SIZE_B];
        bool hit_o;
        //byte_t eb_V_o;
        p_address_t eb_addr;
        //byte_t eb_line_O[CACHE_LINES_SIZE_B];
        req_2_sch_t req_2_sch;
    } dcache_block_outputs_t;

    typedef struct {
        bool oe;  //doing a ld_req,
        bool we;  //reg sayin were doigng a write at p_addr
        p_address_t p_addr;
        byte_t st_q_data[CACHE_LINES_SIZE_B];  //data to write from st_q_head
    } block_req_mio_t;

    //out 2 core
    typedef struct {
        bool writeSuccess;
        bool hit_o;
        byte_t dataLineOut[CACHE_LINES_SIZE_B];
        req_2_sch_t req_2_sch;
        bool req_rejected;
    } mio_block_outputs_t;

    typedef struct {
        bool valid;
        bool dirty;
        p_address_t lineAddr;
        byte_t line[CACHE_LINES_SIZE_B];
    } swap_buf_t;

    typedef struct {
        bool hit;
        //we fucked up
        //bool miss;
        swap_buf_t dcache_swapBuf;
        //not needed
        bool V_Cache_swapBuf_valid_clr;
        bool D_will_evict;
        bool busy;
        byte_t data_lineOut[CACHE_LINES_SIZE_B];
        bool MakeReq;
        bool eb_stalling;
    } d_cache_bank_outputs_t;

    typedef struct {
        //bool valid;  //probably not needed
        bool hit;   // needed for block 
        bool miss;  //needed for d$ fsm

        swap_buf_t vcache_swapBuf;

        bool D_Cache_swapBuf_valid_clr;
        bool LD_EB;
        bool busy;
        bool beingBlocked;
        byte_t lineOut[CACHE_LINES_SIZE_B];
        p_address_t addrOut;  //for eb
    } v_cache_outputs_t;

    typedef struct {
        bool valid;  //probably not needed, i lied this is fucking needed for vcache fsm, holy shit what was i smkoking
        bool commiting;
        p_address_t addr;
        byte_t lineOut[CACHE_LINES_SIZE_B];
        bool reqHit;
    } eb_outputs_t;


    // Total number of states = 10
    localparam int NUM_DCACHE_BANK_FSM_STATES = 10;

    // 4 bits needed to encode 10 states
    typedef enum logic [$clog2(
NUM_DCACHE_BANK_FSM_STATES
)-1:0] {
        DCACHE_BANK_IDLE         = 4'd0,  // 0000
        DCACHE_BANK_EB_BLOCKING  = 4'd1,  // 0001
        DCACHE_BANK_EVICTING     = 4'd2,  // 0010
        DCACHE_BANK_REQ0         = 4'd3,  // 0011
        DCACHE_BANK_REQ1         = 4'd4,  // 0100
        DCACHE_BANK_REQ2         = 4'd5,  // 0101
        DCACHE_BANK_REQ3         = 4'd6,  // 0110
        DCACHE_BANK_SWAPPING_LD  = 4'd7,  // 0111
        DCACHE_BANK_SWAPPING_ST0 = 4'd8,  // 1000
        DCACHE_BANK_ERROR        = 4'd9   // 1001
    } dcache_bank_fsm_states_e;



    // Total number of states = 6
    localparam int NUM_VCACHE_STATES = 5;

    // 3 bits required (matches spec)
    typedef enum logic [$clog2(
NUM_VCACHE_STATES
)-1:0] {
        VCACHE_IDLE       = 3'd0,  // 000
        VCACHE_LD_VC_SWAP = 3'd1,  // 001
        VCACHE_WAITEVICT  = 3'd2,  // 010
        WRITE_2_VCACHE    = 3'd3,  // 011
        VCACHE_ERROR      = 3'd4   // 101
    } vcache_fsm_states_e;

endpackage

