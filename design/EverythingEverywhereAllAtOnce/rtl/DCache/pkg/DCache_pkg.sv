package DCache_pkg;

    import common::*;

    localparam NUM_BANKS = 4;

    typedef struct {
        uint16_t vec;
        byte_t st_q_data[CACHE_LINES_SIZE_B];
        p_address_t p_addr;
        bool we;
        bool oe;
    } bank_req_t;



endpackage
;
