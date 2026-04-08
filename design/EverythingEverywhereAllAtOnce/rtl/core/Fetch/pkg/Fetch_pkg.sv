package Fetch_pkg;
    import common_pkg::*;
    import core_stage_latches_pkg::*;
    import core_common_pkg::*;

    typedef struct {
        address_t btfn_target; //unused

        //from fetch
        address_t spc;
        bool btb_hit;
        //execute info
        bool exe_br_valid;
        address_t exe_br_target;
        address_t exe_br_eip;
        bool misprediction;
        bool exe_br_taken;
    } predictor_input_t;

    typedef struct {bool taken;} predictor_output_t;

    typedef struct {
        bool   h_m;
        byte_t data[CACHE_LINES_SIZE_B];
    } icache_fetch_output_t;


    typedef struct{
        bool exp_pipe_clear;
        bool int_pipe_clear;
    }exp_set_logic_output_t;


    typedef struct {
        address_t spc;

        //execute info
        bool exe_br_valid;
        address_t exe_br_target;
        address_t exe_br_eip;
        bool exe_br_XCL;
        bool exe_br_ucond;
    } btb_input_t;

    typedef struct {
        bool hit;
        address_t br_target;
        address_t br_eip;
        bool XCL;
        bool br_ucond; //doesnt go to IDM just used for masking or setting prediction
    } btb_output_t;


    typedef struct {
        fetch_idm_ctrl_2_idm_t idm_input;
        bool push_success;
    } idm_ctrl_logic_output_t;


    typedef struct {
        bool invalidate[NUM_IDM_SLOTS];
        bool no_writes; //when there is a rst flush we cant write even if we have cache hit
    } idm_invalidate_logic_output_t;

    //this is comining out of instrucitno q into fetch, assuming i_q is
    //instatitated in fetch

    typedef enum logic [1:0] {
        SPC = 2'b00,
        SPC_P16 = 2'b01,
        BR_RESTORE = 2'b10,
        BTB_TARGET = 2'b11
    } spc_sel_logic_output_options_e;

    typedef struct {
        spc_sel_logic_output_options_e sel;
        bool br_target_sel;
        address_t br_target; //same as XCL_stall
        bool flush_reg; //honestly only outputted for debugging and masking branch info (techincally not needed)
    } spc_sel_logic_output_t;


endpackage
