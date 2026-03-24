package RegisterRead_pkg;
    import common_pkg::*;
    typedef struct {
        reg_ids_e MODRM_ID;
        reg_ids_e REG_ID;
        reg_ids_e SIB_IDX_ID;
        reg_ids_e SIB_BASE_ID;
        uint64_t DR0_data;
        uint64_t DR1_data;
        reg_ids_e DR0_ID;
        reg_ids_e DR1_ID;
        bool DR0_we;
        bool DR1_we;

        reg_ids_e Segment0_ID;
        reg_ids_e Segment1_ID;
    } regfile_input_t;

    typedef struct {
        uint64_t MODRM_data;
        uint64_t REG_data;
        uint32_t SIB_IDX_data;
        uint32_t SIB_BASE_data;
        uint32_t ECX_data;
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
        reg_ids_e reg_id;
        reg_ids_e modrm_id;
        reg_ids_e sib_base_id;
        reg_ids_e sib_idx_id;

        reg_ids_e wb_dr0_id;
        bool wb_dr0_we;
        reg_ids_e wb_dr1_id;
        bool wb_dr1_we;

        bool cs_sib_size;

        bool cs_reg_rd;
        bool cs_modrm_rd;

        bool cs_reg_wr;
        bool cs_modrm_reg_wr;
        //reg_ids_e Segment0_ID;
        //reg_ids_e Segment1_ID;
        //bool Segment1_valid;
    } regsb_inputs_t;

    typedef struct{
        //bool sb; //may not need is jsut use counter as >1 == dependency
        uint8_t counter;
    } regsb_entry_t;


endpackage
