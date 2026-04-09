package RegisterRead_pkg;
    import common_pkg::*;
    import reg_ids_pkg::*;

    localparam NUM_SEG_REGS = 6;

    localparam int VPN_UB = 31;
    localparam int VPN_LB = 12;
    localparam int PAGE_OFFSET_UB = 11;
    localparam int PAGE_OFFSET_LB = 0;
    localparam int NUM_OFFSET_BITS = PAGE_OFFSET_UB - PAGE_OFFSET_LB + 1;

    typedef struct {
        uint64_t DR_data;
        uint64_t SR_data;
        uint32_t SIB_IDX_data;
        uint32_t SIB_BASE_data;
        uint32_t ECX_data;
        uint32_t EAX_data;
        uint32_t CS_data;
        uint32_t Segment0_data;
        uint32_t Segment1_data;
    } regfile_output_t;

    typedef struct {
        //bool sb; //may not need is jsut use counter as >1 == dependency
        uint8_t counter;
    } regsb_entry_t;

    typedef enum {
        CS_LIMIT_ID = 0,
        DS_LIMIT_ID = 1,
        SS_LIMIT_ID = 2,
        ES_LIMIT_ID = 3,
        FS_LIMIT_ID = 4,
        GS_LIMIT_ID = 5
    } seg_limit_reg_ids_e;

    typedef struct {
        uint32_t limit[4];           //actual limit, same as datasize 8b
          //effective limit for datasize of 00, 8b access, same as regular access
          //effective limit for datasize of 01, 16b access, limit - 1
          //effective limit for datasize of 10, 32b access, limit - 3
          //effective lmit for datasize 0f 11, 64b access, limit - 7
    } segment_limit_reg_entry_t;


endpackage
