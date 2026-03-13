package core_common_pkg;
    import system_bus_ifs_pkg::*;
    import common_pkg::*;
    import reg_ids_pkg::*;

    localparam int NUM_WB_ST_QS = 4;


    typedef uint32_t flags_t;

    typedef struct {
        address_t virtual_addr;
        bool write_intention;
    } tlb_inputs_t;

    typedef struct {
        address_t physical_addr;
        bool physical_addr_valid;
        bool gp_exp;
        bool pageFault;
    } tlb_outputs_t;

    typedef struct {
        icache_req_types_2_scheduler_e req_2_sch_o;
        bool lineValid;
        bool hit;
        byte_t instruction_line[CACHE_LINES_SIZE_B];
    } icache_output_t;


    //typedef struct {
    //    
    //}dc_2_dcache_t;

    //typedef struct{
    //}dcache_2_mem_t;


    typedef struct {
        bool icache_en;
        tlb_outputs_t tlb_addr_outs_i;
        v_address_t v_spc_addr_i;
    } fetch_2_icache_t;

    typedef struct {
        bool ld_meta_data;
        //this is for the cachelines, if not laoding dont want to create a mux or
        //load in X's
        bool ld_data;

        bool valid;

        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE];
    } idm_slot_req_t;

    typedef struct {idm_slot_req_t req[num_slots];} fetch_idm_ctrl_2_idm_t;

    typedef struct {
        fetch_2_icache_t fetch_2_icache;
        fetch_idm_ctrl_2_idm_t idm_reqs;
        bool exp_pipe_clear;
    } fetch_outputs_t;

    typedef struct {
        bool valid;
        bool stall;
        l_address_t eip;
        bool invalid_instruction;
    } decode_outputs_t;

    typedef struct {
        bool valid;
        bool flush;
        //outputs to decode
        bool ecx_sb;
        uint32_t ecx;
        bool set_ZF_sb;
    } rr_outputs_t;

    typedef struct {bool valid;} dc_outputs_t;

    typedef struct {bool valid;} mem_outputs_t;

    typedef struct {
        bool valid;
        bool flush;
        bool miss_prediction;
        l_address_t br_eip;
        l_address_t neip;
        l_address_t br_target;
        bool taken;  //this is the correct resolution
        bool br_XCL;
        bool clr_exp_mode;
    } exe_br_resolution_outputs_t;

    typedef struct {
        bool valid;
        bool stall;
        bool flush;

        //for fetch and decode
        execute_outputs_br_info_t br_res_out;

        //for decode
        bool  clr_ZF_sb;
        logic ZF;
    } exe_outputs_t;

    //needs to feed into dache
    typedef struct {
        bool full;
        bool empty;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_outputs_t;

    typedef struct {
        bool valid;
        bool wb_stall;

        bool DR_0_we;
        reg_ids_e DR_0_id;
        uint64_t DR_0_data;

        bool DR_1_we;
        reg_ids_e DR_1_id;  //
        uint64_t DR_1_data;  //data is supposed to be aligned
        bool st_override;
        st_q_outputs_t st_outputs[NUM_WB_ST_QS];
    } wb_outputs_t;



endpackage

