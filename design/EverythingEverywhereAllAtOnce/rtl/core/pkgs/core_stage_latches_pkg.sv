package core_stage_latches_pkg;

    import core_common_pkg::*;
    import common_pkg::*;
    import execute_op_types_pkg::exe_cs_operation_type_e;

    localparam int num_byte_q_slots = 4;

    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];
    } byte_q_slot_info_t;

    typedef struct {byte_q_slot_info_t bytes_q[num_byte_q_slots];} predecode_stage_latches_t;

    typedef struct {
        bool br_pred_taken;
        v_address_t br_target;
        v_address_t br_eip;

        uint32_t NEIP;
        byte_t imm32[4];
        byte_t disp[4];
        uint8_t sib;
        uint8_t mod;
        uint8_t opcode;
        logic [1:0] pfs;
        logic [9:0] total_pf_vector;
        bool needr_m;
        logic [2:0] disp_size;
        logic [2:0] imm_size;
        bool sib_size;
    } decode_stage_latches_t;

    typedef struct {bool RR_OP;} rr_cs_t;

    typedef struct {
        bool valid;
        rr_cs_t cs;
    } rr_latches_t;

    typedef struct {bool DC_OP;} dc_cs_t;

    typedef struct {
        bool valid;
        dc_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned

        bool br_pred_taken;
        v_address_t br_target;
        v_address_t br_eip;

        v_address_t NEIP;

        uint32_t imm32;

        bool LD_XCL;
        p_address_t LD_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t LD_PADDR_1;  //cacheline algned
        bool swapLines;

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

    } dc_latches_t;

    typedef struct {
        bool MEM_OP;
    } mem_cs_t;

    typedef struct {
        bool valid;
        mem_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned

        bool br_pred_taken;
        v_address_t br_target;
        v_address_t br_eip;

        v_address_t NEIP;

        uint32_t imm32;

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        bool LD_XCL;
        bool swapLines;
        p_address_t LD_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t LD_PADDR_1;  //cacheline algned

    } mem_stage_latches_t;

    typedef struct {
        bool EXE_OP;
        logic [1:0] DATA_SIZE;
        exe_cs_operation_type_e OP_TYPE;
        bool xchg;
        bool cmpxchg;
        bool cmovc;
        bool mem_operand;  //if not mem, then sr
        bool ld_flags;
        uint32_t flag_modified_vector;
        bool clear_df;
        bool set_df;
    } exe_cs_t;

    typedef struct {
        bool valid;
        exe_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned

        bool br_pred_taken;
        v_address_t br_target;
        v_address_t br_eip;

        v_address_t NEIP;

        uint32_t imm32;

        byte_t ld_buf[32];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        v_address_t ld_addy;

    } execute_stage_latches_t;


    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
    } wb_cs_t;

    typedef struct {
        bool valid;
        wb_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline algned
        uint16_t ST_BIT_VEC_0;  //where to write
        p_address_t ST_PADDR_1;  //cacheline algned
        uint16_t ST_BIT_VEC_1;  //where to write

        byte_t res_buf[32];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

    } wb_stage_latches_t;

endpackage
;
