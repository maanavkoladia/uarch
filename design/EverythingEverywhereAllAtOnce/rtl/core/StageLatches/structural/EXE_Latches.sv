/*

    typedef struct {
        bool valid;  //we had a br in decode
        l_address_t br_eip;
        bool br_xcl;
        bool br_pred_taken;
        l_address_t speculative_target;
    } br_info_t;

    typedef struct {
        bool ST_OP;
        exe_cs_operation_type_e OP_TYPE;
        source_selector_e alu_inputA_sel;
        source_selector_e alu_inputB_sel;
        source_selector_e branch_target_sel;
        bool shift_by_one;
        bool br_ucond;
        bool relative_branch;
        bool special_br;
        bool is_far;
        bool is_call;
        bool second_flag_needed;
        bool rep_no_zf_update;
    } exe_cs_t;

    typedef struct {
        bool ST_OP;
        bool WB_DR;
        bool WB_SR;
        bool WB_EAX;
    } wb_cs_t;

    typedef struct {
        bool valid;
        exe_cs_t cs;
        wb_cs_t wb_cs;

        logic [3:0] data_size_vec;
        logic [3:0] sr_data_size_vec;
        bool shift_sr_up;
        bool shift_sr_down;

        bool ST_XCL;
        p_address_t ST_PADDR_0;
        p_address_t ST_PADDR_1;
        bool MIO;

        br_info_t br_info;
        l_address_t br_rel_target;

        l_address_t NEIP;
        l_address_t EIP;
        uint32_t EAX;

        uint64_t imm64;

        byte_t ld_buf[EXE_BUFFER_SIZE];  //32 byte buf

        reg_ids_e sr_id;
        uint64_t  sr_data;
        reg_ids_e dr_id;
        uint64_t  dr_data;

        p_address_t ld_addy;

    } exe_latches_t;

    NOTE on enum widths:
      exe_cs_operation_type_e and source_selector_e are typedef'd without a
      base type, so per SV LRM they default to 32-bit int. That's what is used
      for OP_TYPE / alu_inputA_sel / alu_inputB_sel / branch_target_sel below.

    Flush behavior (matches non-structural reference):
      - !rst                      -> latches <= 0  (REG_RST_WE async reset)
      - flush & write_enable_i    -> latches <= 0
      - write_enable_i  (!flush)  -> latches <= nextLatches
      - !write_enable_i           -> hold
      Implementation: MUX_2 per field selecting (flush ? 0 : nextLatches),
      output fed to REG_RST_WE's d input. WE = write_enable_i in all cases.

*/

`define STRUCTURAL_EXE_STAGE_LATCHES

`ifdef STRUCTURAL_EXE_STAGE_LATCHES
//fully unrolled stage latch, every field of exe_latches_t gets its own port.
//ld_buf is flattened to EXE_BUFFER_SIZE*8 = 256 bits.
module EXE_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,
    input wire flush,

    // ----- nextLatches_i (unrolled) -----
    input wire        nextLatches_valid_i,

    // exe_cs_t cs
    input wire        nextLatches_cs_ST_OP_i,
    input wire [31:0] nextLatches_cs_OP_TYPE_i,
    input wire [31:0] nextLatches_cs_alu_inputA_sel_i,
    input wire [31:0] nextLatches_cs_alu_inputB_sel_i,
    input wire [31:0] nextLatches_cs_branch_target_sel_i,
    input wire        nextLatches_cs_shift_by_one_i,
    input wire        nextLatches_cs_br_ucond_i,
    input wire        nextLatches_cs_relative_branch_i,
    input wire        nextLatches_cs_special_br_i,
    input wire        nextLatches_cs_is_far_i,
    input wire        nextLatches_cs_is_call_i,
    input wire        nextLatches_cs_second_flag_needed_i,
    input wire        nextLatches_cs_rep_no_zf_update_i,

    // wb_cs_t wb_cs
    input wire        nextLatches_wb_cs_ST_OP_i,
    input wire        nextLatches_wb_cs_WB_DR_i,
    input wire        nextLatches_wb_cs_WB_SR_i,
    input wire        nextLatches_wb_cs_WB_EAX_i,

    input wire [3:0]  nextLatches_data_size_vec_i,
    input wire [3:0]  nextLatches_sr_data_size_vec_i,
    input wire        nextLatches_shift_sr_up_i,
    input wire        nextLatches_shift_sr_down_i,

    input wire        nextLatches_ST_XCL_i,
    input wire [14:0] nextLatches_ST_PADDR_0_i,
    input wire [14:0] nextLatches_ST_PADDR_1_i,
    input wire        nextLatches_MIO_i,

    // br_info_t br_info
    input wire        nextLatches_br_info_valid_i,
    input wire [31:0] nextLatches_br_info_br_eip_i,
    input wire        nextLatches_br_info_br_xcl_i,
    input wire        nextLatches_br_info_br_pred_taken_i,
    input wire [31:0] nextLatches_br_info_speculative_target_i,

    input wire [31:0] nextLatches_br_rel_target_i,

    input wire [31:0] nextLatches_NEIP_i,
    input wire [31:0] nextLatches_EIP_i,
    input wire [31:0] nextLatches_EAX_i,

    input wire [63:0] nextLatches_imm64_i,

    input wire [255:0] nextLatches_ld_buf_i,

    input wire [4:0]  nextLatches_sr_id_i,
    input wire [63:0] nextLatches_sr_data_i,
    input wire [4:0]  nextLatches_dr_id_i,
    input wire [63:0] nextLatches_dr_data_i,

    input wire [14:0] nextLatches_ld_addy_i,

    // ----- latches_o (unrolled) -----
    output wire        latches_valid_o,

    output wire        latches_cs_ST_OP_o,
    output wire [31:0] latches_cs_OP_TYPE_o,
    output wire [31:0] latches_cs_alu_inputA_sel_o,
    output wire [31:0] latches_cs_alu_inputB_sel_o,
    output wire [31:0] latches_cs_branch_target_sel_o,
    output wire        latches_cs_shift_by_one_o,
    output wire        latches_cs_br_ucond_o,
    output wire        latches_cs_relative_branch_o,
    output wire        latches_cs_special_br_o,
    output wire        latches_cs_is_far_o,
    output wire        latches_cs_is_call_o,
    output wire        latches_cs_second_flag_needed_o,
    output wire        latches_cs_rep_no_zf_update_o,

    output wire        latches_wb_cs_ST_OP_o,
    output wire        latches_wb_cs_WB_DR_o,
    output wire        latches_wb_cs_WB_SR_o,
    output wire        latches_wb_cs_WB_EAX_o,

    output wire [3:0]  latches_data_size_vec_o,
    output wire [3:0]  latches_sr_data_size_vec_o,
    output wire        latches_shift_sr_up_o,
    output wire        latches_shift_sr_down_o,

    output wire        latches_ST_XCL_o,
    output wire [14:0] latches_ST_PADDR_0_o,
    output wire [14:0] latches_ST_PADDR_1_o,
    output wire        latches_MIO_o,

    output wire        latches_br_info_valid_o,
    output wire [31:0] latches_br_info_br_eip_o,
    output wire        latches_br_info_br_xcl_o,
    output wire        latches_br_info_br_pred_taken_o,
    output wire [31:0] latches_br_info_speculative_target_o,

    output wire [31:0] latches_br_rel_target_o,

    output wire [31:0] latches_NEIP_o,
    output wire [31:0] latches_EIP_o,
    output wire [31:0] latches_EAX_o,

    output wire [63:0] latches_imm64_o,

    output wire [255:0] latches_ld_buf_o,

    output wire [4:0]  latches_sr_id_o,
    output wire [63:0] latches_sr_data_o,
    output wire [4:0]  latches_dr_id_o,
    output wire [63:0] latches_dr_data_o,

    output wire [14:0] latches_ld_addy_o
);
`else
module EXE_Latches (
    input wire clk,
    input wire rst,
    input exe_latches_t nextLatches_i,
    input wire write_enable_i,
    input wire flush,
    output exe_latches_t latches_o
);

    // ---- alias wires (same names as the unrolled-port version) ----
    wire        nextLatches_valid_i;

    wire        nextLatches_cs_ST_OP_i;
    wire [31:0] nextLatches_cs_OP_TYPE_i;
    wire [31:0] nextLatches_cs_alu_inputA_sel_i;
    wire [31:0] nextLatches_cs_alu_inputB_sel_i;
    wire [31:0] nextLatches_cs_branch_target_sel_i;
    wire        nextLatches_cs_shift_by_one_i;
    wire        nextLatches_cs_br_ucond_i;
    wire        nextLatches_cs_relative_branch_i;
    wire        nextLatches_cs_special_br_i;
    wire        nextLatches_cs_is_far_i;
    wire        nextLatches_cs_is_call_i;
    wire        nextLatches_cs_second_flag_needed_i;
    wire        nextLatches_cs_rep_no_zf_update_i;

    wire        nextLatches_wb_cs_ST_OP_i;
    wire        nextLatches_wb_cs_WB_DR_i;
    wire        nextLatches_wb_cs_WB_SR_i;
    wire        nextLatches_wb_cs_WB_EAX_i;

    wire [3:0]  nextLatches_data_size_vec_i;
    wire [3:0]  nextLatches_sr_data_size_vec_i;
    wire        nextLatches_shift_sr_up_i;
    wire        nextLatches_shift_sr_down_i;

    wire        nextLatches_ST_XCL_i;
    wire [14:0] nextLatches_ST_PADDR_0_i;
    wire [14:0] nextLatches_ST_PADDR_1_i;
    wire        nextLatches_MIO_i;

    wire        nextLatches_br_info_valid_i;
    wire [31:0] nextLatches_br_info_br_eip_i;
    wire        nextLatches_br_info_br_xcl_i;
    wire        nextLatches_br_info_br_pred_taken_i;
    wire [31:0] nextLatches_br_info_speculative_target_i;

    wire [31:0] nextLatches_br_rel_target_i;

    wire [31:0] nextLatches_NEIP_i;
    wire [31:0] nextLatches_EIP_i;
    wire [31:0] nextLatches_EAX_i;

    wire [63:0] nextLatches_imm64_i;

    wire [255:0] nextLatches_ld_buf_i;

    wire [4:0]  nextLatches_sr_id_i;
    wire [63:0] nextLatches_sr_data_i;
    wire [4:0]  nextLatches_dr_id_i;
    wire [63:0] nextLatches_dr_data_i;

    wire [14:0] nextLatches_ld_addy_i;

    wire        latches_valid_o;

    wire        latches_cs_ST_OP_o;
    wire [31:0] latches_cs_OP_TYPE_o;
    wire [31:0] latches_cs_alu_inputA_sel_o;
    wire [31:0] latches_cs_alu_inputB_sel_o;
    wire [31:0] latches_cs_branch_target_sel_o;
    wire        latches_cs_shift_by_one_o;
    wire        latches_cs_br_ucond_o;
    wire        latches_cs_relative_branch_o;
    wire        latches_cs_special_br_o;
    wire        latches_cs_is_far_o;
    wire        latches_cs_is_call_o;
    wire        latches_cs_second_flag_needed_o;
    wire        latches_cs_rep_no_zf_update_o;

    wire        latches_wb_cs_ST_OP_o;
    wire        latches_wb_cs_WB_DR_o;
    wire        latches_wb_cs_WB_SR_o;
    wire        latches_wb_cs_WB_EAX_o;

    wire [3:0]  latches_data_size_vec_o;
    wire [3:0]  latches_sr_data_size_vec_o;
    wire        latches_shift_sr_up_o;
    wire        latches_shift_sr_down_o;

    wire        latches_ST_XCL_o;
    wire [14:0] latches_ST_PADDR_0_o;
    wire [14:0] latches_ST_PADDR_1_o;
    wire        latches_MIO_o;

    wire        latches_br_info_valid_o;
    wire [31:0] latches_br_info_br_eip_o;
    wire        latches_br_info_br_xcl_o;
    wire        latches_br_info_br_pred_taken_o;
    wire [31:0] latches_br_info_speculative_target_o;

    wire [31:0] latches_br_rel_target_o;

    wire [31:0] latches_NEIP_o;
    wire [31:0] latches_EIP_o;
    wire [31:0] latches_EAX_o;

    wire [63:0] latches_imm64_o;

    wire [255:0] latches_ld_buf_o;

    wire [4:0]  latches_sr_id_o;
    wire [63:0] latches_sr_data_o;
    wire [4:0]  latches_dr_id_o;
    wire [63:0] latches_dr_data_o;

    wire [14:0] latches_ld_addy_o;

    // ---- bridge SV struct fields -> alias wires ----
    assign nextLatches_valid_i                    = nextLatches_i.valid;

    assign nextLatches_cs_ST_OP_i                 = nextLatches_i.cs.ST_OP;
    assign nextLatches_cs_OP_TYPE_i               = nextLatches_i.cs.OP_TYPE;
    assign nextLatches_cs_alu_inputA_sel_i        = nextLatches_i.cs.alu_inputA_sel;
    assign nextLatches_cs_alu_inputB_sel_i        = nextLatches_i.cs.alu_inputB_sel;
    assign nextLatches_cs_branch_target_sel_i     = nextLatches_i.cs.branch_target_sel;
    assign nextLatches_cs_shift_by_one_i          = nextLatches_i.cs.shift_by_one;
    assign nextLatches_cs_br_ucond_i              = nextLatches_i.cs.br_ucond;
    assign nextLatches_cs_relative_branch_i       = nextLatches_i.cs.relative_branch;
    assign nextLatches_cs_special_br_i            = nextLatches_i.cs.special_br;
    assign nextLatches_cs_is_far_i                = nextLatches_i.cs.is_far;
    assign nextLatches_cs_is_call_i               = nextLatches_i.cs.is_call;
    assign nextLatches_cs_second_flag_needed_i    = nextLatches_i.cs.second_flag_needed;
    assign nextLatches_cs_rep_no_zf_update_i      = nextLatches_i.cs.rep_no_zf_update;

    assign nextLatches_wb_cs_ST_OP_i              = nextLatches_i.wb_cs.ST_OP;
    assign nextLatches_wb_cs_WB_DR_i              = nextLatches_i.wb_cs.WB_DR;
    assign nextLatches_wb_cs_WB_SR_i              = nextLatches_i.wb_cs.WB_SR;
    assign nextLatches_wb_cs_WB_EAX_i             = nextLatches_i.wb_cs.WB_EAX;

    assign nextLatches_data_size_vec_i            = nextLatches_i.data_size_vec;
    assign nextLatches_sr_data_size_vec_i         = nextLatches_i.sr_data_size_vec;
    assign nextLatches_shift_sr_up_i              = nextLatches_i.shift_sr_up;
    assign nextLatches_shift_sr_down_i            = nextLatches_i.shift_sr_down;

    assign nextLatches_ST_XCL_i                   = nextLatches_i.ST_XCL;
    assign nextLatches_ST_PADDR_0_i               = nextLatches_i.ST_PADDR_0;
    assign nextLatches_ST_PADDR_1_i               = nextLatches_i.ST_PADDR_1;
    assign nextLatches_MIO_i                      = nextLatches_i.MIO;

    assign nextLatches_br_info_valid_i            = nextLatches_i.br_info.valid;
    assign nextLatches_br_info_br_eip_i           = nextLatches_i.br_info.br_eip;
    assign nextLatches_br_info_br_xcl_i           = nextLatches_i.br_info.br_xcl;
    assign nextLatches_br_info_br_pred_taken_i    = nextLatches_i.br_info.br_pred_taken;
    assign nextLatches_br_info_speculative_target_i = nextLatches_i.br_info.speculative_target;

    assign nextLatches_br_rel_target_i            = nextLatches_i.br_rel_target;

    assign nextLatches_NEIP_i                     = nextLatches_i.NEIP;
    assign nextLatches_EIP_i                      = nextLatches_i.EIP;
    assign nextLatches_EAX_i                      = nextLatches_i.EAX;

    assign nextLatches_imm64_i                    = nextLatches_i.imm64;

    assign nextLatches_sr_id_i                    = nextLatches_i.sr_id;
    assign nextLatches_sr_data_i                  = nextLatches_i.sr_data;
    assign nextLatches_dr_id_i                    = nextLatches_i.dr_id;
    assign nextLatches_dr_data_i                  = nextLatches_i.dr_data;

    assign nextLatches_ld_addy_i                  = nextLatches_i.ld_addy;

    assign latches_o.valid                        = latches_valid_o;

    assign latches_o.cs.ST_OP                     = latches_cs_ST_OP_o;
    assign latches_o.cs.OP_TYPE                   = exe_cs_operation_type_e'(latches_cs_OP_TYPE_o);
    assign latches_o.cs.alu_inputA_sel            = source_selector_e'(latches_cs_alu_inputA_sel_o);
    assign latches_o.cs.alu_inputB_sel            = source_selector_e'(latches_cs_alu_inputB_sel_o);
    assign latches_o.cs.branch_target_sel         = source_selector_e'(latches_cs_branch_target_sel_o);
    assign latches_o.cs.shift_by_one              = latches_cs_shift_by_one_o;
    assign latches_o.cs.br_ucond                  = latches_cs_br_ucond_o;
    assign latches_o.cs.relative_branch           = latches_cs_relative_branch_o;
    assign latches_o.cs.special_br                = latches_cs_special_br_o;
    assign latches_o.cs.is_far                    = latches_cs_is_far_o;
    assign latches_o.cs.is_call                   = latches_cs_is_call_o;
    assign latches_o.cs.second_flag_needed        = latches_cs_second_flag_needed_o;
    assign latches_o.cs.rep_no_zf_update          = latches_cs_rep_no_zf_update_o;

    assign latches_o.wb_cs.ST_OP                  = latches_wb_cs_ST_OP_o;
    assign latches_o.wb_cs.WB_DR                  = latches_wb_cs_WB_DR_o;
    assign latches_o.wb_cs.WB_SR                  = latches_wb_cs_WB_SR_o;
    assign latches_o.wb_cs.WB_EAX                 = latches_wb_cs_WB_EAX_o;

    assign latches_o.data_size_vec                = latches_data_size_vec_o;
    assign latches_o.sr_data_size_vec             = latches_sr_data_size_vec_o;
    assign latches_o.shift_sr_up                  = latches_shift_sr_up_o;
    assign latches_o.shift_sr_down                = latches_shift_sr_down_o;

    assign latches_o.ST_XCL                       = latches_ST_XCL_o;
    assign latches_o.ST_PADDR_0                   = latches_ST_PADDR_0_o;
    assign latches_o.ST_PADDR_1                   = latches_ST_PADDR_1_o;
    assign latches_o.MIO                          = latches_MIO_o;

    assign latches_o.br_info.valid                = latches_br_info_valid_o;
    assign latches_o.br_info.br_eip               = latches_br_info_br_eip_o;
    assign latches_o.br_info.br_xcl               = latches_br_info_br_xcl_o;
    assign latches_o.br_info.br_pred_taken        = latches_br_info_br_pred_taken_o;
    assign latches_o.br_info.speculative_target   = latches_br_info_speculative_target_o;

    assign latches_o.br_rel_target                = latches_br_rel_target_o;

    assign latches_o.NEIP                         = latches_NEIP_o;
    assign latches_o.EIP                          = latches_EIP_o;
    assign latches_o.EAX                          = latches_EAX_o;

    assign latches_o.imm64                        = latches_imm64_o;

    assign latches_o.sr_id                        = reg_ids_e'(latches_sr_id_o);
    assign latches_o.sr_data                      = latches_sr_data_o;
    assign latches_o.dr_id                        = reg_ids_e'(latches_dr_id_o);
    assign latches_o.dr_data                      = latches_dr_data_o;

    assign latches_o.ld_addy                      = latches_ld_addy_o;

    // pack/unpack the ld_buf unpacked byte array <-> 256-bit flat wire
    genvar gi;
    generate
        for (gi = 0; gi < 32; gi = gi + 1) begin : g_pack_ld_buf
            assign nextLatches_ld_buf_i[gi*8 +: 8] = nextLatches_i.ld_buf[gi];
            assign latches_o.ld_buf[gi]            = latches_ld_buf_o[gi*8 +: 8];
        end
    endgenerate

`endif

    // ============================================================
    // Flush-gated data wires (input to each REG_RST_WE)
    //   <field>_d = (flush) ? 0 : nextLatches_<field>_i
    // implemented with MUX_2 macros (sel = flush, in0 = data, in1 = 0).
    // ============================================================

    wire        valid_d;

    wire        cs_ST_OP_d;
    wire [31:0] cs_OP_TYPE_d;
    wire [31:0] cs_alu_inputA_sel_d;
    wire [31:0] cs_alu_inputB_sel_d;
    wire [31:0] cs_branch_target_sel_d;
    wire        cs_shift_by_one_d;
    wire        cs_br_ucond_d;
    wire        cs_relative_branch_d;
    wire        cs_special_br_d;
    wire        cs_is_far_d;
    wire        cs_is_call_d;
    wire        cs_second_flag_needed_d;
    wire        cs_rep_no_zf_update_d;

    wire        wb_cs_ST_OP_d;
    wire        wb_cs_WB_DR_d;
    wire        wb_cs_WB_SR_d;
    wire        wb_cs_WB_EAX_d;

    wire [3:0]  data_size_vec_d;
    wire [3:0]  sr_data_size_vec_d;
    wire        shift_sr_up_d;
    wire        shift_sr_down_d;

    wire        ST_XCL_d;
    wire [14:0] ST_PADDR_0_d;
    wire [14:0] ST_PADDR_1_d;
    wire        MIO_d;

    wire        br_info_valid_d;
    wire [31:0] br_info_br_eip_d;
    wire        br_info_br_xcl_d;
    wire        br_info_br_pred_taken_d;
    wire [31:0] br_info_speculative_target_d;

    wire [31:0] br_rel_target_d;

    wire [31:0] NEIP_d;
    wire [31:0] EIP_d;
    wire [31:0] EAX_d;

    wire [63:0] imm64_d;

    wire [255:0] ld_buf_d;

    wire [4:0]  sr_id_d;
    wire [63:0] sr_data_d;
    wire [4:0]  dr_id_d;
    wire [63:0] dr_data_d;

    wire [14:0] ld_addy_d;

    // -------- flush MUX per field (in1 = 0, sel = flush) --------

    `MUX_2(u_exe_mux_valid,                    1,   valid_d,                    nextLatches_valid_i,                    1'b0,         flush);

    `MUX_2(u_exe_mux_cs_ST_OP,                 1,   cs_ST_OP_d,                 nextLatches_cs_ST_OP_i,                 1'b0,         flush);
    `MUX_2(u_exe_mux_cs_OP_TYPE,               32,  cs_OP_TYPE_d,               nextLatches_cs_OP_TYPE_i,               32'b0,        flush);
    `MUX_2(u_exe_mux_cs_alu_inputA_sel,        32,  cs_alu_inputA_sel_d,        nextLatches_cs_alu_inputA_sel_i,        32'b0,        flush);
    `MUX_2(u_exe_mux_cs_alu_inputB_sel,        32,  cs_alu_inputB_sel_d,        nextLatches_cs_alu_inputB_sel_i,        32'b0,        flush);
    `MUX_2(u_exe_mux_cs_branch_target_sel,     32,  cs_branch_target_sel_d,     nextLatches_cs_branch_target_sel_i,     32'b0,        flush);
    `MUX_2(u_exe_mux_cs_shift_by_one,          1,   cs_shift_by_one_d,          nextLatches_cs_shift_by_one_i,          1'b0,         flush);
    `MUX_2(u_exe_mux_cs_br_ucond,              1,   cs_br_ucond_d,              nextLatches_cs_br_ucond_i,              1'b0,         flush);
    `MUX_2(u_exe_mux_cs_relative_branch,       1,   cs_relative_branch_d,       nextLatches_cs_relative_branch_i,       1'b0,         flush);
    `MUX_2(u_exe_mux_cs_special_br,            1,   cs_special_br_d,            nextLatches_cs_special_br_i,            1'b0,         flush);
    `MUX_2(u_exe_mux_cs_is_far,                1,   cs_is_far_d,                nextLatches_cs_is_far_i,                1'b0,         flush);
    `MUX_2(u_exe_mux_cs_is_call,               1,   cs_is_call_d,               nextLatches_cs_is_call_i,               1'b0,         flush);
    `MUX_2(u_exe_mux_cs_second_flag_needed,    1,   cs_second_flag_needed_d,    nextLatches_cs_second_flag_needed_i,    1'b0,         flush);
    `MUX_2(u_exe_mux_cs_rep_no_zf_update,      1,   cs_rep_no_zf_update_d,      nextLatches_cs_rep_no_zf_update_i,      1'b0,         flush);

    `MUX_2(u_exe_mux_wb_cs_ST_OP,              1,   wb_cs_ST_OP_d,              nextLatches_wb_cs_ST_OP_i,              1'b0,         flush);
    `MUX_2(u_exe_mux_wb_cs_WB_DR,              1,   wb_cs_WB_DR_d,              nextLatches_wb_cs_WB_DR_i,              1'b0,         flush);
    `MUX_2(u_exe_mux_wb_cs_WB_SR,              1,   wb_cs_WB_SR_d,              nextLatches_wb_cs_WB_SR_i,              1'b0,         flush);
    `MUX_2(u_exe_mux_wb_cs_WB_EAX,             1,   wb_cs_WB_EAX_d,             nextLatches_wb_cs_WB_EAX_i,             1'b0,         flush);

    `MUX_2(u_exe_mux_data_size_vec,            4,   data_size_vec_d,            nextLatches_data_size_vec_i,            4'b0,         flush);
    `MUX_2(u_exe_mux_sr_data_size_vec,         4,   sr_data_size_vec_d,         nextLatches_sr_data_size_vec_i,         4'b0,         flush);
    `MUX_2(u_exe_mux_shift_sr_up,              1,   shift_sr_up_d,              nextLatches_shift_sr_up_i,              1'b0,         flush);
    `MUX_2(u_exe_mux_shift_sr_down,            1,   shift_sr_down_d,            nextLatches_shift_sr_down_i,            1'b0,         flush);

    `MUX_2(u_exe_mux_ST_XCL,                   1,   ST_XCL_d,                   nextLatches_ST_XCL_i,                   1'b0,         flush);
    `MUX_2(u_exe_mux_ST_PADDR_0,               15,  ST_PADDR_0_d,               nextLatches_ST_PADDR_0_i,               15'b0,        flush);
    `MUX_2(u_exe_mux_ST_PADDR_1,               15,  ST_PADDR_1_d,               nextLatches_ST_PADDR_1_i,               15'b0,        flush);
    `MUX_2(u_exe_mux_MIO,                      1,   MIO_d,                      nextLatches_MIO_i,                      1'b0,         flush);

    `MUX_2(u_exe_mux_br_info_valid,            1,   br_info_valid_d,            nextLatches_br_info_valid_i,            1'b0,         flush);
    `MUX_2(u_exe_mux_br_info_br_eip,           32,  br_info_br_eip_d,           nextLatches_br_info_br_eip_i,           32'b0,        flush);
    `MUX_2(u_exe_mux_br_info_br_xcl,           1,   br_info_br_xcl_d,           nextLatches_br_info_br_xcl_i,           1'b0,         flush);
    `MUX_2(u_exe_mux_br_info_br_pred_taken,    1,   br_info_br_pred_taken_d,    nextLatches_br_info_br_pred_taken_i,    1'b0,         flush);
    `MUX_2(u_exe_mux_br_info_speculative_target, 32, br_info_speculative_target_d, nextLatches_br_info_speculative_target_i, 32'b0, flush);

    `MUX_2(u_exe_mux_br_rel_target,            32,  br_rel_target_d,            nextLatches_br_rel_target_i,            32'b0,        flush);

    `MUX_2(u_exe_mux_NEIP,                     32,  NEIP_d,                     nextLatches_NEIP_i,                     32'b0,        flush);
    `MUX_2(u_exe_mux_EIP,                      32,  EIP_d,                      nextLatches_EIP_i,                      32'b0,        flush);
    `MUX_2(u_exe_mux_EAX,                      32,  EAX_d,                      nextLatches_EAX_i,                      32'b0,        flush);

    `MUX_2(u_exe_mux_imm64,                    64,  imm64_d,                    nextLatches_imm64_i,                    64'b0,        flush);

    `MUX_2(u_exe_mux_ld_buf,                   256, ld_buf_d,                   nextLatches_ld_buf_i,                   256'b0,       flush);

    `MUX_2(u_exe_mux_sr_id,                    5,   sr_id_d,                    nextLatches_sr_id_i,                    5'b0,         flush);
    `MUX_2(u_exe_mux_sr_data,                  64,  sr_data_d,                  nextLatches_sr_data_i,                  64'b0,        flush);
    `MUX_2(u_exe_mux_dr_id,                    5,   dr_id_d,                    nextLatches_dr_id_i,                    5'b0,         flush);
    `MUX_2(u_exe_mux_dr_data,                  64,  dr_data_d,                  nextLatches_dr_data_i,                  64'b0,        flush);

    `MUX_2(u_exe_mux_ld_addy,                  15,  ld_addy_d,                  nextLatches_ld_addy_i,                  15'b0,        flush);

    // ============================================================
    // REG_RST_WE per field
    // `REG_RST_WE(__unitName__, __width__, __clk__, __rst__, __we__, __din__, __dout__)
    //   active async low rst
    // ============================================================

    `REG_RST_WE(exe_latches_valid,                    1,   clk, rst, write_enable_i, valid_d,                    latches_valid_o);

    `REG_RST_WE(exe_latches_cs_ST_OP,                 1,   clk, rst, write_enable_i, cs_ST_OP_d,                 latches_cs_ST_OP_o);
    `REG_RST_WE(exe_latches_cs_OP_TYPE,               32,  clk, rst, write_enable_i, cs_OP_TYPE_d,               latches_cs_OP_TYPE_o);
    `REG_RST_WE(exe_latches_cs_alu_inputA_sel,        32,  clk, rst, write_enable_i, cs_alu_inputA_sel_d,        latches_cs_alu_inputA_sel_o);
    `REG_RST_WE(exe_latches_cs_alu_inputB_sel,        32,  clk, rst, write_enable_i, cs_alu_inputB_sel_d,        latches_cs_alu_inputB_sel_o);
    `REG_RST_WE(exe_latches_cs_branch_target_sel,     32,  clk, rst, write_enable_i, cs_branch_target_sel_d,     latches_cs_branch_target_sel_o);
    `REG_RST_WE(exe_latches_cs_shift_by_one,          1,   clk, rst, write_enable_i, cs_shift_by_one_d,          latches_cs_shift_by_one_o);
    `REG_RST_WE(exe_latches_cs_br_ucond,              1,   clk, rst, write_enable_i, cs_br_ucond_d,              latches_cs_br_ucond_o);
    `REG_RST_WE(exe_latches_cs_relative_branch,       1,   clk, rst, write_enable_i, cs_relative_branch_d,       latches_cs_relative_branch_o);
    `REG_RST_WE(exe_latches_cs_special_br,            1,   clk, rst, write_enable_i, cs_special_br_d,            latches_cs_special_br_o);
    `REG_RST_WE(exe_latches_cs_is_far,                1,   clk, rst, write_enable_i, cs_is_far_d,                latches_cs_is_far_o);
    `REG_RST_WE(exe_latches_cs_is_call,               1,   clk, rst, write_enable_i, cs_is_call_d,               latches_cs_is_call_o);
    `REG_RST_WE(exe_latches_cs_second_flag_needed,    1,   clk, rst, write_enable_i, cs_second_flag_needed_d,    latches_cs_second_flag_needed_o);
    `REG_RST_WE(exe_latches_cs_rep_no_zf_update,      1,   clk, rst, write_enable_i, cs_rep_no_zf_update_d,      latches_cs_rep_no_zf_update_o);

    `REG_RST_WE(exe_latches_wb_cs_ST_OP,              1,   clk, rst, write_enable_i, wb_cs_ST_OP_d,              latches_wb_cs_ST_OP_o);
    `REG_RST_WE(exe_latches_wb_cs_WB_DR,              1,   clk, rst, write_enable_i, wb_cs_WB_DR_d,              latches_wb_cs_WB_DR_o);
    `REG_RST_WE(exe_latches_wb_cs_WB_SR,              1,   clk, rst, write_enable_i, wb_cs_WB_SR_d,              latches_wb_cs_WB_SR_o);
    `REG_RST_WE(exe_latches_wb_cs_WB_EAX,             1,   clk, rst, write_enable_i, wb_cs_WB_EAX_d,             latches_wb_cs_WB_EAX_o);

    `REG_RST_WE(exe_latches_data_size_vec,            4,   clk, rst, write_enable_i, data_size_vec_d,            latches_data_size_vec_o);
    `REG_RST_WE(exe_latches_sr_data_size_vec,         4,   clk, rst, write_enable_i, sr_data_size_vec_d,         latches_sr_data_size_vec_o);
    `REG_RST_WE(exe_latches_shift_sr_up,              1,   clk, rst, write_enable_i, shift_sr_up_d,              latches_shift_sr_up_o);
    `REG_RST_WE(exe_latches_shift_sr_down,            1,   clk, rst, write_enable_i, shift_sr_down_d,            latches_shift_sr_down_o);

    `REG_RST_WE(exe_latches_ST_XCL,                   1,   clk, rst, write_enable_i, ST_XCL_d,                   latches_ST_XCL_o);
    `REG_RST_WE(exe_latches_ST_PADDR_0,               15,  clk, rst, write_enable_i, ST_PADDR_0_d,               latches_ST_PADDR_0_o);
    `REG_RST_WE(exe_latches_ST_PADDR_1,               15,  clk, rst, write_enable_i, ST_PADDR_1_d,               latches_ST_PADDR_1_o);
    `REG_RST_WE(exe_latches_MIO,                      1,   clk, rst, write_enable_i, MIO_d,                      latches_MIO_o);

    `REG_RST_WE(exe_latches_br_info_valid,            1,   clk, rst, write_enable_i, br_info_valid_d,            latches_br_info_valid_o);
    `REG_RST_WE(exe_latches_br_info_br_eip,           32,  clk, rst, write_enable_i, br_info_br_eip_d,           latches_br_info_br_eip_o);
    `REG_RST_WE(exe_latches_br_info_br_xcl,           1,   clk, rst, write_enable_i, br_info_br_xcl_d,           latches_br_info_br_xcl_o);
    `REG_RST_WE(exe_latches_br_info_br_pred_taken,    1,   clk, rst, write_enable_i, br_info_br_pred_taken_d,    latches_br_info_br_pred_taken_o);
    `REG_RST_WE(exe_latches_br_info_speculative_target, 32, clk, rst, write_enable_i, br_info_speculative_target_d, latches_br_info_speculative_target_o);

    `REG_RST_WE(exe_latches_br_rel_target,            32,  clk, rst, write_enable_i, br_rel_target_d,            latches_br_rel_target_o);

    `REG_RST_WE(exe_latches_NEIP,                     32,  clk, rst, write_enable_i, NEIP_d,                     latches_NEIP_o);
    `REG_RST_WE(exe_latches_EIP,                      32,  clk, rst, write_enable_i, EIP_d,                      latches_EIP_o);
    `REG_RST_WE(exe_latches_EAX,                      32,  clk, rst, write_enable_i, EAX_d,                      latches_EAX_o);

    `REG_RST_WE(exe_latches_imm64,                    64,  clk, rst, write_enable_i, imm64_d,                    latches_imm64_o);

    `REG_RST_WE(exe_latches_ld_buf,                   256, clk, rst, write_enable_i, ld_buf_d,                   latches_ld_buf_o);

    `REG_RST_WE(exe_latches_sr_id,                    5,   clk, rst, write_enable_i, sr_id_d,                    latches_sr_id_o);
    `REG_RST_WE(exe_latches_sr_data,                  64,  clk, rst, write_enable_i, sr_data_d,                  latches_sr_data_o);
    `REG_RST_WE(exe_latches_dr_id,                    5,   clk, rst, write_enable_i, dr_id_d,                    latches_dr_id_o);
    `REG_RST_WE(exe_latches_dr_data,                  64,  clk, rst, write_enable_i, dr_data_d,                  latches_dr_data_o);

    `REG_RST_WE(exe_latches_ld_addy,                  15,  clk, rst, write_enable_i, ld_addy_d,                  latches_ld_addy_o);

endmodule
