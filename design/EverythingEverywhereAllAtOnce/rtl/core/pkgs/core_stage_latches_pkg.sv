package core_stage_latches_pkg;

    import common_pkg::*;
    import reg_ids_pkg::*;
    import core_common_pkg::*;
    import control_store_pkg::*;

    localparam int EXE_BUFFER_SIZE = 32;

    typedef struct {
    
        //real info on branch
        bool valid;  //we had a br in decode
        l_address_t br_eip;  //for btb entries going back to fetch during br resolution in execute
        bool br_xcl;
 
        //specualtive info on branch 
        bool br_pred_taken;  //if fetch said taken, then high, else low
        l_address_t speculative_target;  //needed bc target can change if in mem or reg, this is NOT the same as the actual target in EXE res
        //rn assuming if br_pred_not taken speculative_target is filled with garbage
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

    typedef struct {
        idm_slot_info_t idm_slots[NUM_IDM_SLOTS];
        logic [2:0] valid_slots;
    } idm_outputs_t;

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

    typedef struct{
        bool REP;
        bool MODRM_NEEDED;
        bool RM_IS_DR;
        bool REG_IS_DR;
        bool HARDCODED_DR;
        reg_ids_e HARDCODED_DR_ID;
        bool HARDCODED_SR;
        bool HARDCODED_SR_ID;      //ik this is a bool rn, but cs has it as bool rn, will hcnage later
        bool HARDCODED_DR_RD;
        bool HARDCODED_SR_RD;
        bool OP_IN_MODRM;
        reg_ids_e dr_id;
        reg_ids_e sr_id;
        logic [2:0] DATA_SIZE;
    } decode_cs_t;

    typedef struct {
        bool HARDCODED_DR_RD;
        bool HARDCODED_SR_RD;
        bool ST_SEL;
        bool MODRM_NEEDED;
        bool RM_IS_DR;
        bool LD_OP;
        bool ST_OP;
        reg_ids_e dr_id;
        reg_ids_e sr_id;
        bool dr_rd;
        bool sr_rd;
        bool dr_wr;
        bool sr_wr;

        logic [2:0] datasize; //0=8b, 1=16b, 2=32b, 3=64b

        bool will_mod_zf;       //need this for zf scoreboard to check during rep instructions
    } rr_cs_t;

    typedef struct {
        bool LD_OP;
        bool ST_OP;
        bool upper8;
        logic [1:0] data_size;
    } dc_cs_t;

    typedef struct {
        bool ST_OP;
        bool LD_OP;
    } mem_cs_t;

    typedef struct {
        bool ST_OP;
        exe_cs_operation_type_e OP_TYPE;

        source_selector_e alu_inputA_sel;
        source_selector_e alu_inputB_sel;
        source_selector_e branch_target_sel;

        //branch cs
        bool br_ucond;
        bool relative_branch; //1 indicates I add it to NEIP 0 means Its an absolute jmp
        bool special_br; //for exp and int
        bool is_far;  //need to flush
       //I think for most branches its ZF then CF.
       //I will always assume ZF if second flag is set then ill also use CF
       //hard coded in br_res logic
        bool second_flag_needed;
    } exe_cs_t;


    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
    } wb_cs_t;

    typedef struct {
        bool valid;
        rr_cs_t cs;
        //added
        dc_cs_t dc_cs;
        mem_cs_t mem_cs;
        exe_cs_t exe_cs;
        wb_cs_t wb_cs;

        br_info_t br_info;
        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;

        uint64_t imm64;
        reg_ids_e sib_idx_id;
        reg_ids_e sib_base_id;
        bool sib_needed;
        uint8_t sib_scale;  //0,2,4,8
        bool disp_needed;
        bool disp_size; //8 or 32, 0 determined by DISP_NEEDED
        uint32_t displacement;
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
        bool valid;
        //this is how we will pass down cs
        dc_cs_t cs;
        mem_cs_t mem_cs;
        exe_cs_t exe_cs;
        wb_cs_t wb_cs;

        br_info_t br_info;

        // bool ST_XCL;  //valid bit or second set of st info if st_op
        // p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        // p_address_t ST_PADDR_1;  //cacheline algned
        // bool MIO;  //this a write to mem_io

        // bool LD_XCL;
        // p_address_t LD_PADDR_0;  //cacheline unalgned, ie actual addr
        // p_address_t LD_PADDR_1;  //cacheline algned
        // bool swapLines;

        //these are for limit checking for gp
        v_address_t ld_vaddy;
        uint32_t seg0_limit_w_datasize;
        v_address_t actual_st_vaddy;
        uint32_t seg1_limit_w_datasize;


        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;

        uint64_t imm64;

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;
    } dc_latches_t;

    typedef struct {
        bool valid;
        mem_cs_t cs;
        exe_cs_t exe_cs;
        wb_cs_t wb_cs;
        br_info_t br_info;

        logic [3:0] data_size_vec;
        bool rh_into_mem;
        bool mem_into_rh;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned
        bool MIO;

        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;

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
        bool valid;
        exe_cs_t cs;
        wb_cs_t wb_cs;

        logic [3:0] data_size_vec;
        bool rh_into_mem;
        bool mem_into_rh;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned
        bool MIO;

        br_info_t br_info;

        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;


        uint64_t imm64;

        byte_t ld_buf[EXE_BUFFER_SIZE];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        p_address_t ld_addy;  //not cache aligned. Only use index bits to find start 

    } exe_latches_t;

    typedef struct {
        bool valid;
        wb_cs_t cs;

        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline algned
        uint16_t ST_BIT_VEC_0;  //where to write
        p_address_t ST_PADDR_1;  //cacheline algned
        uint16_t ST_BIT_VEC_1;  //where to write
        bool MIO;

        byte_t res_buf[CACHE_LINES_SIZE_B*2];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

    } wb_latches_t;

endpackage

