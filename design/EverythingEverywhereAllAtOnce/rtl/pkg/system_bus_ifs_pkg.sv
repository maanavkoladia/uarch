package system_bus_ifs_pkg;

    //ICache system wide if to the Arbitration

    typedef struct {bool Mem_Valid;} dte_2_icache_t;

    typedef enum {
        IDLE = 0,
        LOW_PRI_REQ = 1,
        HIGH_PRI = 2
    } icache_req_types_2_scheduler_e;

    typedef struct {icache_req_types_2_scheduler_e req;} icache_2_scheduler_t;

endpackage
