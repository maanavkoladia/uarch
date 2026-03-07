package Fetch_pkg;
    import common_pkg::*;
    import core_stage_latches_pkg::predecode_stage_latches_t;
    import core_stage_latches_pkg::byte_q_slot_info_t;
    import core_stage_latches_pkg::num_byte_q_slots;
    
    localparam int num_slots = num_byte_q_slots;

    typedef struct {
        address_t btfn_target;
        address_t spc;

        //execute info
        bool exe_br_valid;
        address_t exe_br_target;
        //address_t exe_br_eip;
        bool exe_br_taken;
        //proably not needed
        bool exe_br_hit;
    } predictor_input_t;

    typedef struct {bool taken;} predictor_output_t;

    typedef struct {
        bool   h_m;
        byte_t data[CACHE_LINES_SIZE];
    } icache_fetch_output_t;

    typedef struct {
        address_t spc;

        //execute info
        bool exe_br_valid;
        address_t exe_br_target;
        address_t exe_br_eip;
        bool exe_br_XCL;
    } btb_input_t;

    typedef struct {
        bool hit;
        address_t br_target;
        address_t br_eip;
        bool XCL;
    } btb_output_t;


    typedef struct {bool invalidate[num_slots];} q_invalidate_logic_ouput_t;

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

    } instruction_slot_req_t;

    typedef struct {instruction_slot_req_t req[num_slots];} instruction_q_input_t;

    typedef struct {
        instruction_q_input_t q_input;
        bool push_success;
    } q_ctrl_logic_output_t;

    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE_B];
    } instruction_q_slot_info_t;

    //this is comining out of instrucitno q into fetch, assuming i_q is
    //instatitated in fetch
    typedef struct {instruction_q_slot_info_t slot_info_list[num_slots];} instruction_q_2_fetch_t;


    typedef enum {
        SPC = 2'b00,
        SPC_P16 = 2'b01,
        BR_RESTORE = 2'b10,
        BTB_TARGET = 2'b11
    } spc_sel_logic_output_options_e;

    typedef struct {
        spc_sel_logic_output_options_e sel;
        bool xcl;
        address_t br_eip;
    } spc_sel_logic_output_t;

endpackage
