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
        bool alu_inputA_override;
        bool alu_inputB_override;
        source_selector_e alu_inputA_override_sel;
        source_selector_e alu_inputB_override_sel;
    } modrm_processor_outs_t;

endpackage
