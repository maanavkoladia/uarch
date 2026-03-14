package core_stage_latches_pkg;

    import core_common_pkg::*;
    import common_pkg::*;
    import execute_op_types_pkg::exe_cs_operation_type_e;

    localparam int NUM_IDM_SLOTS = 4;
    localparam int EXE_BUFFER_SIZE = 32;

    typedef struct {
        bool valid;  //we had a br in decode
        bool isFar;  //need to flush fuck it
        bool br_pred_taken;  //if fetch said taken, then high, else low
        l_address_t br_btb_target;  //needed bc target can change if in mem or reg, this is NOT the same as the actual target in EXE res
        l_address_t br_eip;  //for btb entries going back to fetch during br resolution in execute
        //neip not needed ready being sent in latches
    } br_info_t;

    typedef struct {
        bool valid;
        //the br was predecited taken in fetch
        bool br_valid;
        l_address_t br_eip;
        l_address_t br_btb_target;  //this is the btbs predicted target, 
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];
    } idm_slot_info_t;

    typedef struct {idm_slot_info_t idm_slots[NUM_IDM_SLOTS];} idm_outputs_t;

    //typedef struct {
    //    bool br_pred_taken;
    //    v_address_t br_target;
    //    v_address_t br_eip;

    //    uint32_t NEIP;
    //    byte_t imm32[4];
    //    byte_t disp[4];
    //    uint8_t sib;
    //    uint8_t mod;
    //    uint8_t opcode;
    //    logic [1:0] pfs;
    //    logic [9:0] total_pf_vector;
    //    bool needr_m;
    //    logic [2:0] disp_size;
    //    logic [2:0] imm_size;
    //    bool sib_size;
    //} decode_stage_latches_t;

    typedef struct {
        bool RR_OP;  //r we doing an rr op, this one might be trivial be fick it

        bool REG_RD; //are we reading the REG reg, ie are we gonna access the reg file w the id in the latches, check sb 
        bool MOD_RM_RD;  //same as REG reg
        bool SIB_NEEDED;  //are we going to use the SIB byte, 
        bool SIB_DISP_SIZE;  //for using displacement in sib tranlstion logic
        bool WE_REG;  //for makring the sb
        bool WE_MOD_RM;  //

        bool ST_SEL;//this is for selecting addr gen out or for slection between reg data or mod rm data
        bool DR_SEL;  //this doe sthe sel between mod_rm dr, or reg dr

        bool LD_OP;
        bool ST_OP;

    } rr_cs_t;

    typedef struct {
        bool valid;
        rr_cs_t cs;
        br_info_t br_info;
        l_address_t NEIP;
        uint64_t imm64;
        reg_ids_e mod_rm_id;
        reg_ids_e reg_id;
        reg_ids_e sib_idx_id;
        reg_ids_e sib_base_id;
        uint8_t sib_scale;  //0,2,4,8
        uint32_t displacment;
        bool seg_1_valid;  //need two beacuse two segs for movs etc, 
        reg_ids_e seg_0_id;
        reg_ids_e seg_1_id;
    } rr_latches_general_t;

    typedef struct {
        rr_latches_general_t normal_latches;
        rr_latches_general_t rep_latches;
        bool useRep;
    } rr_latches_t;

    typedef struct {
        bool DC_OP;
        bool LD_OP;  //if req to dcache is needed and if dep checking is needed
    } dc_cs_t;

    typedef struct {
        bool valid;
        dc_cs_t cs;

        br_info_t br_info;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned
        bool MIO;  //this a write to mem_io

        l_address_t NEIP;

        uint64_t imm64;

        bool LD_XCL;
        p_address_t LD_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t LD_PADDR_1;  //cacheline algned
        bool swapLines;

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;
    } dc_latches_t;

    typedef struct {bool MEM_OP;} mem_cs_t;

    typedef struct {
        bool valid;
        mem_cs_t cs;

        br_info_t br_info;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned
        bool MIO;

        l_address_t NEIP;

        uint64_t imm64;

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        bool LD_XCL;
        bool swapLines;
        p_address_t LD_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t LD_PADDR_1;  //cacheline algned

    } mem_latches_t;

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
        bool MIO;

        br_info_t br_info;

        l_address_t NEIP;

        uint64_t imm64;

        byte_t ld_buf[EXE_BUFFER_SIZE];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        v_address_t ld_addy;  //not cache aligned. Only use index bits to find start 

    } execute_latches_t;


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
        bool MIO;

        byte_t res_buf[32];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

    } wb_latches_t;

endpackage
;
