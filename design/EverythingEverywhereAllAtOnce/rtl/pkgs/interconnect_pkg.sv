package interconnect_pkg;

    import common_pkg::*;

    localparam int numWriteBufsInMem = 8;
    localparam int NUM_DCACHE_PORTS = 4;

    localparam int MEM_BUS_SIZE = CACHE_LINES_SIZE_BITS;

    localparam int NUM_REQS = 14;

    //we can abuse the bit mapping to do fasters cmps
    typedef enum logic [NUM_REQS - 1 : 0] {

        // ===== ICACHE (highest) =====
        ICACHE_HIGH_PRI = 14,

        // ===== DCACHE =====
        DCACHE_EB_BLOCKING_BANK = 13,
        DCACHE_EB_BLOCKING_ST_OVERRIDE = 12,
        DCACHE_EB_BLOCKING_LD = 11,
        DCACHE_EB_BLOCK_ST = 10,
        DCACHE_FILL_ST_OVERRIDE = 9,
        DCACHE_FILL_LD = 8,
        DCACHE_FILL_ST = 7,
        DCACHE_EB_WR = 6,


        // ===== MIO / IO =====
        DCACHE_MIO_LD_FROM_SIMPLE = 5,
        DCACHE_MIO_WR_COMPLEX = 4,
        DCACHE_MIO_WR_SIMPLE = 3,

        // ===== ICACHE (lower) =====
        ICACHE_LOW_PRI_REQ = 2,

        //DMA WRite to mem req
        DMA_WRITE_REQ = 1,

        // ===== No request =====
        NO_REQ = 0

    } req_2_sch_t;

    //ICACHE interconnect/////////////////////////////
    //typedef enum {
    //    ICACHE_IDLE = 0,
    //    ICACHE_LOW_PRI_REQ = 1,
    //    ICACHE_HIGH_PRI = 2
    //} icache_req_types_2_scheduler_e;

    typedef struct {req_2_sch_t req;} icache_2_scheduler_t;

    typedef struct {
        bool Mem_Valid;
        bool driveAddrBus;
    } dte_2_icache_t;

    //DCACHE interconnect/////////////////////////////
    //typedef enum {
    //    DCACHE_IDLE = 0,  //no reqs
    //    DCACHE_EVICT,  //only evict, nothing else
    //    DCACHE_GET_LINE_FOR_ST,  //st present, not being blocked, causing stall
    //    DCACHE_GET_LINE_FOR_ST_BLOCKED,  //st present, blocked by eb, no stall
    //    DCACHE_GET_LINE_FOR_LD,  //ld present, cuasing stall, not being lbocked
    //    DCACHE_GET_LINE_FOR_ST_OVERRIDE,  //st present, not blocked, cuaing stall
    //    DCACHE_GET_LINE_FOR_LD_BLOCKED,  //ld present, cuaisng stall, being blocked by eb
    //    DCACHE_GET_LINE_FOR_ST_OVERRIDE_BLOCKED,  //st preesnt, override, being blocked
    //    DCACHE_GET_LINE_FOR_LD_OVERRIDE_BLOCKED //ld is present, cuasing stall, and being blocked by eb, there is a st w st ovrrid pedning ,
    //} dcache_req_types_2_scheduler_e;

    //typedef enum {
    //    DCACHE_MIO_IDLE = 0,
    //    DCACHE_MIO_LD_FROM_SIMPLE = 1,
    //    DCACHE_MIO_WR_SIMPLE = 2,
    //    DCACHE_MIO_WR_COMPLEX = 3
    //} dcache_req_types_mio_2_scheduler_e;

    typedef struct {
        req_2_sch_t req[NUM_DCACHE_PORTS];
        p_address_t evictionBufAddr[NUM_DCACHE_PORTS];

        req_2_sch_t req_mio;
    } dcache_2_scheduler_t;

    typedef struct {
        bool mem_valid[NUM_DCACHE_PORTS];
        bool permissionToDriveDataBus_evictionBuf[NUM_DCACHE_PORTS][CACHE_LINES_SIZE_BITS/DATA_BUS_WIDTH_BITS];
        //bool permissionToDriveAddrBus_eb;
        bool permissionToDriveAddrBus_Ld[NUM_DCACHE_PORTS];
        bool permissionToDriveAddrBus_eb[NUM_DCACHE_PORTS];
        bool evictionBuf_clr[NUM_DCACHE_PORTS];
        bool evictionBuf_setCommiting[NUM_DCACHE_PORTS];

        //MIO stuff
        //used to crea teh hit signal for mem
        //ld from simple, tells the mio block that the data on the bus is the
        //simple IO reg values, this can be strcanlted into a hit signal going
        //to mem stage in core
        //bool dataOnBus_MIO;

        //this says that it is complete, this will be used in write success
        //logic
        bool reqServed_mio;

        //for st_req
        //drive address and data (4 bytes) onto the bus
        bool permissionToDriveAddrBus_mio;
        bool permission2DriveDataBus_mio;
    } dte_2_dcache_t;

    //MEM interconnect//////////////////////////////
    typedef struct {bool writeBuf_V[numWriteBufsInMem];} mem_2_scheduler_t;

    typedef struct {bool mem_Ready;} mem_2_dte_t;

    typedef struct {
        bool ld_req;
        bool st_req;
        //bool start_transaction;
        bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_mem_t;


    //DMA_Controller interconnect if
    typedef struct {
        req_2_sch_t dma_req;
        p_address_t writeBuf_Address;
    } dma_controller_2_scheduler_t;

    typedef struct {
        //for driving the DataBus to write to main_mem
        bool permission2DriveDataBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
        //for driving the addr bus when writing to main mem for the st_req
        bool permission2DriveADDRBus;
        //ste signals the dma that it is about to write to the bus,
        //only happens if the dma made the req to sch, so the dma cacheline
        //should be right
        bool writeComplete;
        bool coreValOnBus;
    } dte_2_dma_controller_t;

    //DDR5 interconnect if

    typedef struct {
        //this will be the power gate value from the core
        bool newPowerGateValueFromCore;
        //when this goes high, write data onto the bus, the address
        //on the bus shoudl match the address for the temp reg 
        //when driving the bus
        bool driveDataBus;

    } dte_2_ddr5_t;

    ////////////////////////////////////////////////////////////////
    //core needs create its own internal and manage this w and assign
    typedef struct {
        bool hit;  //onyl goes high if the lines is valid
        byte_t instruction_line[CACHE_LINES_SIZE_B];
    } icache_2_core_t;

    typedef struct {
        bool icache_en;
        p_address_t p_addr;
        v_address_t v_addr_i;
        logic [$clog2(NUM_IDM_SLOTS) : 0] num_valid_IDM_slots;
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

        //for d$ arb logic, 
        bool memStage_CLR_REQ[NUM_DCACHE_PORTS];

        //for wb
        st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];

        //for MIO
        //from DC
        bool ld_addr_MIO_V;
        p_address_t ld_addr_MIO;

        bool memStage_CLR_REQ_MIO;
        //from WB
        st_q_2_dcache_t stq_info_mio;

    } core_2_dcache_t;

    typedef struct {
        //for DC Stage
        bool   reqServed_0;
        bool   reqServed_1;

        //for mem Stage
        bool   hit[NUM_DCACHE_PORTS];
        byte_t cacheline[NUM_DCACHE_PORTS][CACHE_LINES_SIZE_B];

        //for wb
        bool writeSuccess[NUM_WB_ST_QS];
        //TODO
        //
        //for MIO
        bool writeSuccess_MIO;  //for pop MIO
        bool hit_MIO;  //for ld_mem stage 
        bool reqServed_MIO;  //for dc stage 
        byte_t line_MIO[CACHE_LINES_SIZE_B];
    } dcache_2_core_t;

    typedef struct {bool intOut;} dma_controller_2_core_t;

endpackage
