`define IDM_OUTPUTS


    // ---- idm_outputs_t : IDM.idm_outs_* (driven by IDM) ----

    // ---- idm_slots[0..3] : per-slot idm_slot_t ----
    wire        idm_outputs_idm_slots_0_valid;
    wire        idm_outputs_idm_slots_0_br_valid;
    wire [31:0] idm_outputs_idm_slots_0_br_eip;
    wire [31:0] idm_outputs_idm_slots_0_br_btb_target;
    wire        idm_outputs_idm_slots_0_br_xcl;
    wire [127:0] idm_outputs_idm_slots_0_data;

    wire        idm_outputs_idm_slots_1_valid;
    wire        idm_outputs_idm_slots_1_br_valid;
    wire [31:0] idm_outputs_idm_slots_1_br_eip;
    wire [31:0] idm_outputs_idm_slots_1_br_btb_target;
    wire        idm_outputs_idm_slots_1_br_xcl;
    wire [127:0] idm_outputs_idm_slots_1_data;

    wire        idm_outputs_idm_slots_2_valid;
    wire        idm_outputs_idm_slots_2_br_valid;
    wire [31:0] idm_outputs_idm_slots_2_br_eip;
    wire [31:0] idm_outputs_idm_slots_2_br_btb_target;
    wire        idm_outputs_idm_slots_2_br_xcl;
    wire [127:0] idm_outputs_idm_slots_2_data;

    wire        idm_outputs_idm_slots_3_valid;
    wire        idm_outputs_idm_slots_3_br_valid;
    wire [31:0] idm_outputs_idm_slots_3_br_eip;
    wire [31:0] idm_outputs_idm_slots_3_br_btb_target;
    wire        idm_outputs_idm_slots_3_br_xcl;
    wire [127:0] idm_outputs_idm_slots_3_data;

    // ---- valid_slots : popcount of slot valids ----
    wire [2:0]  idm_outputs_valid_slots;
