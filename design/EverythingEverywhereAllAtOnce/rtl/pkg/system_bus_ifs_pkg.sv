package system_bus_ifs_pkg;

    //ICache system wide if to the Arbitration
    import common_pkg::*;

    localparam int numWriteBufsInMem = 8;

    localparam int MEM_BUS_SIZE = CACHE_LINES_SIZE_Bits;

    typedef struct {bool Mem_Valid;} dte_2_icache_t;

    typedef enum {
        IDLE = 0,
        LOW_PRI_REQ = 1,
        HIGH_PRI = 2
    } icache_req_types_2_scheduler_e;

    typedef struct {icache_req_types_2_scheduler_e req;} icache_2_scheduler_t;


    typedef struct {logic writeBuf_V[numWriteBufsInMem];} mem_2_scheduler_t;
    typedef struct {bool mem_Ready;} mem_2_dte_t;

    typedef struct {
        bool ld_req;
        bool st_req;
        bool start_transaction;
        bool permission2DriveBus[MEM_BUS_SIZE/DATA_BUS_WIDTH_BITS];
    } dte_2_mem_t;

endpackage
