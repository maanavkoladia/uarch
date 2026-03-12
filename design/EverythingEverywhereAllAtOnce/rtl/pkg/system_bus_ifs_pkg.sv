package system_bus_ifs_pkg;

    //ICache system wide if to the Arbitration
    import common_pkg::*;

    localparam int numWriteBufsInMem = 8;
    localparam int NUM_DCACHE_PORTS = 4;

    localparam int MEM_BUS_SIZE = CACHE_LINES_SIZE_Bits;

    typedef struct {bool Mem_Valid;} dte_2_icache_t;

    typedef enum {
        ICACHE_IDLE = 0,
        ICACHE_LOW_PRI_REQ = 1,
        ICACHE_HIGH_PRI = 2
    } icache_req_types_2_scheduler_e;

    typedef struct {icache_req_types_2_scheduler_e req;} icache_2_scheduler_t;

    typedef enum {
        DCACHE_IDLE = 0,
        DCACHE_LOW_PRI_REQ = 1,
        DCACHE_HIGH_PRI = 2
    } dcache_req_types_2_scheduler_e;

    typedef struct {
        dcache_req_types_2_scheduler_e req[NUM_DCACHE_PORTS];
        bool evictionBuf_st_req[NUM_DCACHE_PORTS];
        bool evictionBuf_p_addr[NUM_DCACHE_PORTS];
    } dcache_2_scheduler_t;

    typedef struct {
        bool mem_valid[NUM_DCACHE_PORTS];
        bool evictionBuf_PermissionToDriveBus[NUM_DCACHE_PORTS][MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_dcache_t;



    typedef struct {logic writeBuf_V[numWriteBufsInMem];} mem_2_scheduler_t;
    typedef struct {bool mem_Ready;} mem_2_dte_t;

    typedef struct {
        bool ld_req;
        bool st_req;
        bool start_transaction;
        bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_mem_t;





endpackage
