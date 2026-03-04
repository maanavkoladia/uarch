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
        br_info branch_info;
        uint32_t NEIP;
        byte_t imm32[4];
        byte_t disp[4];
        uint8_t sib;
        uint8_t mod;
        uint8_t opcode;
        logic[1:0] pfs;
        logic[9:0] total_pf_vector;
        bool needr_m;
        logic [2:0] disp_size;
        logic [2:0] imm_size;
        bool sib_size;
    }decode_stage_latches_t;

    typedef struct{

    }RR_stage_latches_t;

    typedef struct{

    }mem_stage_latches_t;

    typedef struct {
        bool EXE_OP;
        [1:0] DATA_SIZE;
    }exe_cs_t;

    typedef struct{
        
    }execute_stage_latches_t;
    



    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
        [1:0] DATA_SIZE;
        uint32_t FLAG_MODIFIED_VEC;
    }wb_cs_t;

    typedef struct{
        bool valid;
        wb_cs_t cs;

        bool ST_XCL;//valid bit or second set of st info if st_op
        p_address_t ST_ADDR_0;//cacheline algned
        uint16_t ST_BIT_VEC_0;//where to write
        p_address_t ST_ADDR_1;//cacheline algned
        uint16_t ST_BIT_VEC_1;//where to write

        byte_t res_buf [32];//32 byte buf

        reg_ids_e sr_id;
        uint64_t sr_data;
        reg_ids_e dr_id;
        uint64_t dr_data;
//flags from exe, these are the correct flags, shoudl be commited back normamly
        flags_t flags;
        uint32_t flag_we_vec;
    }wb_stage_latches_t;


endpackage;
