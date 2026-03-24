package interconnect_pkg;

    import common_pkg::*;

    localparam int numWriteBufsInMem = 8;
    localparam int NUM_DCACHE_PORTS = 4;

    localparam int MEM_BUS_SIZE = CACHE_LINES_SIZE_Bits;

    //ICACHE interconnect/////////////////////////////
    typedef enum {
        ICACHE_IDLE = 0,
        ICACHE_LOW_PRI_REQ = 1,
        ICACHE_HIGH_PRI = 2
    } icache_req_types_2_scheduler_e;

    typedef struct {icache_req_types_2_scheduler_e req;} icache_2_scheduler_t;

    typedef struct {
        bool Mem_Valid;
        bool driveAddrBus;
    } dte_2_icache_t;

    //DCACHE interconnect/////////////////////////////
    typedef enum {
        DCACHE_IDLE = 0,
        DCACHE_LOW_PRI_REQ = 1,
        DCACHE_HIGH_PRI = 2
    } dcache_req_types_2_scheduler_e;

    typedef struct {
        dcache_req_types_2_scheduler_e req[NUM_DCACHE_PORTS];
        p_address_t evictionBufAddr[NUM_DCACHE_PORTS];
    } dcache_2_scheduler_t;

    typedef struct {
        bool mem_valid[NUM_DCACHE_PORTS];
        bool evictionBuf_PermissionToDriveBus[NUM_DCACHE_PORTS][MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_dcache_t;

    //MEM interconnect//////////////////////////////
    typedef struct {logic writeBuf_V[numWriteBufsInMem];} mem_2_scheduler_t;
    typedef struct {bool mem_Ready;} mem_2_dte_t;

    typedef struct {
        bool ld_req;
        bool st_req;
        bool start_transaction;
        bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_mem_t;


    //DMA_Controller interconnect if
    typedef struct {bool writeReq;} dma_controller_2_scheduler_t;

    typedef struct {
        bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
        bool start_transaction;
    } dte_2_dma_controller_t;

    //DDR5 interconnect if

    typedef struct {bool start_transaction;} dte_2_ddr5_t;

    ////////////////////////////////////////////////////////////////
    //core needs create its own internal and manage this w and assign
    typedef struct {
        bool   lineValid;
        bool   hit;
        byte_t instruction_line[CACHE_LINES_SIZE_B];
    } icache_2_core_t;

    typedef struct {
        bool icache_en;
        p_address_t p_addr;
        v_address_t v_spc_addr_i;
        uint8_t numValidIDMSlots;
    } core_2_icache_t;

    typedef struct {
        bool full;
        bool empty;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];

    } st_q_2_dcache_t;

    typedef struct {
        //outputs to D$ arb
        bool ld_addr_0_V;
        p_address_t ld_addr_0;
        bool ld_addr_1_V;
        p_address_t ld_addr_1;

        bool memStalling;

        //for wb
        st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];

    } core_2_dcache_t;

    typedef struct {
        //for mem
        //bool   valid_0;
        bool   hit_line_0;
        byte_t line_0[CACHE_LINES_SIZE_B];
        //bool   valid_1;
        bool   hit_line_1;
        byte_t line_1[CACHE_LINES_SIZE_B];

        //for wb
        bool writeSuccess[NUM_WB_ST_QS];
        bool MMIO_write;
        //
    } dcache_2_core_t;

    typedef struct {bool intOut;} dma_controller_2_core_t;

endpackage
