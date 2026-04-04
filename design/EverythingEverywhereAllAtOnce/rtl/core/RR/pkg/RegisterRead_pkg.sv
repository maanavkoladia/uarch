package RegisterRead_pkg;
    import common_pkg::*;
    import reg_ids_pkg::*;

    typedef struct {
        reg_ids_e DR_ID;
        reg_ids_e SR_ID;
        reg_ids_e SIB_IDX_ID;
        reg_ids_e SIB_BASE_ID;
        uint64_t WB_DR0_data;
        uint64_t WB_DR1_data;
        reg_ids_e WB_DR0_ID;
        reg_ids_e WB_DR1_ID;
        bool WB_DR0_we;
        bool WB_DR1_we;

        reg_ids_e Segment0_ID;
        reg_ids_e Segment1_ID;
    } regfile_input_t;

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
        bool gp0_exception;
        bool pf0_exception;
        bool gp1_exception;
        bool pf1_exception;
        bool valid_mem_op;
        p_address_t paddy_aligned;
        bool bank_hi;
        bool xcl;
        p_address_t paddy;
    } neuralnet_outputs_t;


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


endpackage
