package core_common_pkg;

    //update the interconnect_pkg imports only we needs
    import common_pkg::*;
    import reg_ids_pkg::*;
    import interconnect_pkg::*;

    typedef uint32_t flags_t;

    typedef struct {
        v_address_t virtual_addr;
        bool write_intention;
    } tlb_inputs_t;

    typedef struct {
        p_address_t physical_addr;
        bool physical_addr_valid;
        bool gp_exp;
        bool pageFault;
        bool MIO;  //
    } tlb_outputs_t;

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
        byte_t data[CACHE_LINES_SIZE_B];
    } idm_slot_req_t;

    typedef struct {idm_slot_req_t req[NUM_IDM_SLOTS];} fetch_idm_ctrl_2_idm_t;

    typedef struct {
        core_2_icache_t fetch_2_icache;
        fetch_idm_ctrl_2_idm_t idm_reqs;
        bool exp_pipe_clear;
    } fetch_outputs_t;

    typedef struct {
        bool valid;
        bool stall;
        l_address_t eip;
        bool invalid_instruction;
        bool decode_gp;  //instruciton crossing segment line
        bool rr_stage_latch_we;
    } decode_outputs_t;

    typedef struct {
        bool valid;
        bool stall;  //dep stall or exp present
        bool exp_present;  //if present and not pf, then gp
        bool exp_pf;

        //outputs to decode
        bool ecx_sb;
        uint32_t ecx;
        uint32_t eax;
        bool set_ZF_sb;

        bool codeSeg_sb;  //needed for far brs, the sb will disable the i cache
        uint32_t codeSeg_data;  //used for translation from spc to phyiscial addr
        uint32_t codeSeg_limit;

        bool dc_stage_latch_we;
    } rr_outputs_t;

    typedef struct {
        bool valid;

        bool stall;  //dep stall or req rejected

        //outputs to D$ arb
        bool ld_addr_0_V;
        p_address_t ld_addr_0;
        bool ld_addr_1_V;
        p_address_t ld_addr_1;

        //mio stuf
        bool ld_addr_MIO_V;
        p_address_t ld_addr_MIO;
        bool mem_stage_latch_we;
    } dc_outputs_t;

    typedef struct {
        bool valid;
        bool stall;  //dep stall
        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned
        bool ST_OP;
        bool clr_dcache_arb_latches[NUM_DCACHE_PORTS];
        bool clr_dcache_mio_latch;
        bool exe_stage_latch_we;
    } mem_outputs_t;

    typedef struct {
        bool valid;  //is this valid
        bool flush;  //do we need to flush
        //jacob, when generating this make sure its only on valid
        //we don't want to cause unsesirde flusheds ie nuclear output signals when not valid
        bool farFlush;  //need ot generate using cs_isFar if farflush
        bool miss_prediction;  //was there a miss predict
        l_address_t br_eip;  //where is the br, this is for btb entries
        l_address_t neip;//for when we miss predict on a taken and we need to fall thrhough on a flush in decode(EIP) and fetch (SPC)
        l_address_t br_target;//actual target if we need to flush and we miss predicted on a not taken, also for comparision to br_info from stage latches 
        bool taken;  //this is the correct resolution
        bool br_XCL;  //this is for btb entry
        bool clr_exp_mode;  //for the special exp br in the rom, to clear exp mode in fetch
        bool br_ucond;  //3/17 adding this for btb info on on if branch was unconditional - Jacob
    } exe_br_resolution_outputs_t;

    typedef struct {
        bool valid;
        //for fetch and decode
        exe_br_resolution_outputs_t br_res_out;

        //for decode for rep engine
        bool  clr_ZF_sb;
        logic ZF;

        //store dep check
        bool ST_OP;
        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline unalgned, ie actual addr
        p_address_t ST_PADDR_1;  //cacheline algned

        bool wb_stage_latch_we;
    } exe_outputs_t;

    typedef struct {
        bool valid;
        p_address_t address;
    } mem_dep_check_info_t;

    typedef struct {
        //all 4 store queue
        mem_dep_check_info_t entries[NUM_WB_ST_QS * ST_Q_DEPTH];
    } st_q_2_dep_check_outputs_t;

    typedef struct {
        bool valid;
        bool wb_stall;

        //to RR
        bool DR_0_we;
        reg_ids_e DR_0_id;
        uint64_t DR_0_data;

        bool DR_1_we;
        reg_ids_e DR_1_id;  //
        uint64_t DR_1_data;  //data is supposed to be aligned

        //to dcache
        st_q_2_dcache_t stq_heads[NUM_WB_ST_QS];
        st_q_2_dcache_t mio_head;

        //to  DC
        st_q_2_dep_check_outputs_t dep_check;

        //store dep check
        bool ST_OP;
        bool ST_XCL;  //valid bit or second set of st info if st_op
        p_address_t ST_PADDR_0;  //cacheline algned
        p_address_t ST_PADDR_1;  //cacheline algned


    } wb_outputs_t;


endpackage

