package Decode_pkg;
    import common_pkg::*;
    import reg_ids_pkg::*;
    import control_store_pkg::*;

    typedef struct{
        reg_ids_e dr_id;
        reg_ids_e sr_id;
        bool dr_rd;
        bool sr_rd;
        bool dr_wr;
        bool sr_wr;
        bool st_op;
        bool ld_op;
        bool dr_high8;
        bool sr_high8;
        bool alu_inputA_override;
        bool alu_inputB_override;
        source_selector_e alu_inputA_override_sel;
        source_selector_e alu_inputB_override_sel;
        bool special_modrm_bs;
    } modrm_processor_outs_t;

    localparam REP_FSM_NUM_STATES = 6;
    typedef enum logic [$clog2(REP_FSM_NUM_STATES) - 1 : 0] {
        REP_IDLE                         = 0,  // IDLE (reset state)
        REP_CMP                          = 1,
        REP_FUCK_ME                      = 2,
        REP_MOVS                         = 3,
        REP_WAIT                         = 4,
        REP_ERROR                        = 5  // ERROR (trap state), synthesised
    } rep_fsm_states_e;

    localparam REP_MOVS_FSM_NUM_STATES = 6;
    typedef enum logic [$clog2(REP_MOVS_FSM_NUM_STATES) - 1 : 0] {
        MOVS_IDLE                           = 0,  // IDLE (reset state)
        MOVS_DEC_ECX_MOV                    = 1,
        MOVS_FUCK_ME                        = 2,
        MOVS_MOVS                           = 3,
        MOVS_MOVS_OP                        = 4,
        MOVS_ERROR                          = 5  // ERROR (trap state), synthesised
    } rep_movs_fsm_states_e;

    localparam REP_CMP_FSM_NUM_STATES = 6;
    typedef enum logic [$clog2(REP_CMP_FSM_NUM_STATES) - 1 : 0] {
        CMP_IDLE                           = 0,  // IDLE (reset state)
        CMP_CMP                            = 1,
        CMP_CMP0                           = 2,
        CMP_CMP1                           = 3,
        CMP_CMP2                           = 4,
        CMP_CMP3                           = 5,
        CMP_DEC_ECX_CMP                    = 6,
        CMP_ERROR                          = 7 // ERROR (trap state), synthesised
    } rep_cmp_fsm_states_e;



endpackage
