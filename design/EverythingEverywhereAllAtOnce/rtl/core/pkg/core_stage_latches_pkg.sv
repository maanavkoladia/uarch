package core_stage_latches_pkg;

    import Fetch_pkg::instruction_q_2_predecode_t;
    import core_common_pkg::*;
    import common_pkg::*;

    //this one is weird should
    typedef struct{
        instruction_q_2_predecode_t latches;
    }predecode_stage_latches_t;
    
    //
    typedef struct{
        
    }decode_stage_latches_t;

    typedef struct{

    }RR_stage_latches_t;

    typedef struct{

    }mem_stage_latches_t;

    typedef struct{

    }execute_stage_latches_t;
    
    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
        [1:0] DATA_SIZE;
        bool LD_FLAGS;

    }wb_cs_t;

    typedef struct{
        bool ST_XCL;
        p_address_t ST_ADDR_0;
        uint16_t ST_BIT_VEC_0;
        p_address_t ST_ADDR_1;
        uint16_t ST_BIT_VEC_1;
        byte_t res_buf [32];

        reg_ids_e sr_id;
        uint64_t sr_data;
        reg_ids_e dr_id;
        uint64_t dr_data;
        flags_t flags;

        uint32_t flags_bit_vec;

        wb_cs_t cs;
        
        bool valid;
    }wb_stage_latches_t;

    typedef struct {
        bool full;
        bool empty;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_outputs_t;
    
    typedef struct {
        bool ST_Q_Full[NUM_WB_ST_QS];
        bool ST_Q_Empty[NUM_WB_ST_QS];

        uint32_t flags;

        bool stall;

        reg_ids_e DR_0_we;
        reg_ids_e DR_0_id;
        uint64_t DR_0_data;

        reg_ids_e DR_1_we;
        reg_ids_e DR_1_id;
        uint64_t DR_1_data;
        st_q_outputs_t st_outputs[NUM_WB_ST_QS];

    } wb_outputs_t;

endpackage;
