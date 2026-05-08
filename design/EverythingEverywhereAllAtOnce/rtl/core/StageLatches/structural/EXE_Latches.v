// =============================================================================
// EXE_Latches  (pure Verilog-2005 structural stage latch)
//
//   Reference SV struct (kept for documentation):
//     typedef struct {
//         bool valid;  //we had a br in decode
//         l_address_t br_eip;
//         bool br_xcl;
//         bool br_pred_taken;
//         l_address_t speculative_target;
//     } br_info_t;
//
//     typedef struct {
//         bool ST_OP;
//         exe_cs_operation_type_e OP_TYPE;
//         source_selector_e alu_inputA_sel;
//         source_selector_e alu_inputB_sel;
//         source_selector_e branch_target_sel;
//         bool shift_by_one;
//         bool br_ucond;
//         bool relative_branch;
//         bool special_br;
//         bool is_far;
//         bool is_call;
//         bool second_flag_needed;
//         bool rep_no_zf_update;
//     } exe_cs_t;
//
//     typedef struct {
//         bool ST_OP;
//         bool WB_DR;
//         bool WB_SR;
//         bool WB_EAX;
//     } wb_cs_t;
//
//     typedef struct {
//         bool valid;
//         exe_cs_t cs;
//         wb_cs_t wb_cs;
//         logic [3:0] data_size_vec;
//         logic [3:0] sr_data_size_vec;
//         bool shift_sr_up;
//         bool shift_sr_down;
//         bool ST_XCL;
//         p_address_t ST_PADDR_0;
//         p_address_t ST_PADDR_1;
//         bool MIO;
//         br_info_t br_info;
//         l_address_t br_rel_target;
//         l_address_t NEIP;
//         l_address_t EIP;
//         uint32_t EAX;
//         uint64_t imm64;
//         byte_t ld_buf[EXE_BUFFER_SIZE];   // 32 bytes -> 256-bit packed bus
//         reg_ids_e sr_id;
//         uint64_t  sr_data;
//         reg_ids_e dr_id;
//         uint64_t  dr_data;
//         p_address_t ld_addy;
//     } exe_latches_t;
//
//   NOTE on enum widths:
//     exe_cs_operation_type_e and source_selector_e default to 32-bit int;
//     OP_TYPE / alu_inputA_sel / alu_inputB_sel / branch_target_sel are 32 bits.
//
//   Flush behavior (matches non-structural reference):
//     - !rst                      -> latches <= 0  (REG_RST_WE async reset)
//     - flush & write_enable_i    -> latches <= 0
//     - write_enable_i  (!flush)  -> latches <= nextLatches
//     - !write_enable_i           -> hold
//     Implementation: MUX_2 per field selecting (flush ? 0 : nextLatches),
//     output fed to REG_RST_WE's d input. WE = write_enable_i in all cases.
//
//   - SV `import` removed; no struct/typedef/enum used.
//   - Every field is its own scalar/vector port (`.field` -> `_field`).
//   - ld_buf is a single 256-bit packed bus on the boundary
//     (byte 0 = bits [7:0], matching the SV unpacked-array byte order).
// =============================================================================

module EXE_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,
    input wire flush,

    // ----- nextLatches_i (unrolled) -----
    input wire        nextLatches_valid_i,

    // exe_cs_t cs
    input wire        nextLatches_cs_ST_OP_i,
    input wire [5:0]  nextLatches_cs_OP_TYPE_i,
    input wire [4:0]  nextLatches_cs_alu_inputA_sel_i,
    input wire [4:0]  nextLatches_cs_alu_inputB_sel_i,
    input wire [4:0]  nextLatches_cs_branch_target_sel_i,
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
    output wire [5:0]  latches_cs_OP_TYPE_o,
    // 3-way replicated outputs for high-fanout selects.  Each replica is a
    // bit-identical flop driven by the same D / WE / clk / rst, but its Q
    // drives a distinct EXE input port so per-port fanout (1536/3 = 512)
    // stays below STAGES=2 territory and lets each port use a single
    // bufferH1024$ (0.60 ns) instead of a deeper cascade.
    output wire [4:0]  latches_cs_alu_inputA_sel_o,    // -> alu_input_sel_crit
    output wire [4:0]  latches_cs_alu_inputA_sel_b_o,  // -> alu_input_sel_arith
    output wire [4:0]  latches_cs_alu_inputA_sel_c_o,  // -> alu_input_sel_ctrl
    output wire [4:0]  latches_cs_alu_inputB_sel_o,
    output wire [4:0]  latches_cs_alu_inputB_sel_b_o,
    output wire [4:0]  latches_cs_alu_inputB_sel_c_o,
    output wire [4:0]  latches_cs_branch_target_sel_o,
    output wire [4:0]  latches_cs_branch_target_sel_b_o,
    output wire [4:0]  latches_cs_branch_target_sel_c_o,
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
    // 3-way replicated shift selects (one per alu_input_sel replica)
    output wire        latches_shift_sr_up_o,
    output wire        latches_shift_sr_up_b_o,
    output wire        latches_shift_sr_up_c_o,
    output wire        latches_shift_sr_down_o,
    output wire        latches_shift_sr_down_b_o,
    output wire        latches_shift_sr_down_c_o,

    output wire        latches_ST_XCL_o,
    // 3-way replicated ST_PADDR_0 (a -> bit_vec_logic, b -> res_buf_logic,
    // c -> output ports)
    output wire [14:0] latches_ST_PADDR_0_o,
    output wire [14:0] latches_ST_PADDR_0_b_o,
    output wire [14:0] latches_ST_PADDR_0_c_o,
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

    // 3-way replicated sr_id (a -> u_mux_sr_data, b -> xchg_op, c -> reg_wb)
    output wire [4:0]  latches_sr_id_o,
    output wire [4:0]  latches_sr_id_b_o,
    output wire [4:0]  latches_sr_id_c_o,
    output wire [63:0] latches_sr_data_o,
    // 3-way replicated dr_id (a -> u_mux_dr_data, b -> xchg_op, c -> reg_wb)
    output wire [4:0]  latches_dr_id_o,
    output wire [4:0]  latches_dr_id_b_o,
    output wire [4:0]  latches_dr_id_c_o,
    output wire [63:0] latches_dr_data_o,

    // 3-way replicated ld_addy (a/b/c -> alu_input_sel_crit/arith/ctrl)
    output wire [14:0] latches_ld_addy_o,
    output wire [14:0] latches_ld_addy_b_o,
    output wire [14:0] latches_ld_addy_c_o
);

    // ============================================================
    // Flush-gated data wires (input to each REG_RST_WE)
    //   <field>_d = (flush) ? 0 : nextLatches_<field>_i
    // implemented with MUX_2 macros (sel = flush, in0 = data, in1 = 0).
    // ============================================================

    wire        valid_d;

    wire        cs_ST_OP_d;
    wire [5:0]  cs_OP_TYPE_d;
    wire [4:0]  cs_alu_inputA_sel_d;
    wire [4:0]  cs_alu_inputB_sel_d;
    wire [4:0]  cs_branch_target_sel_d;
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

    assign cs_ST_OP_d = nextLatches_cs_ST_OP_i;
    assign cs_OP_TYPE_d = nextLatches_cs_OP_TYPE_i;
    assign cs_alu_inputA_sel_d = nextLatches_cs_alu_inputA_sel_i;
    assign cs_alu_inputB_sel_d = nextLatches_cs_alu_inputB_sel_i;
    assign cs_branch_target_sel_d = nextLatches_cs_branch_target_sel_i;
    assign cs_shift_by_one_d = nextLatches_cs_shift_by_one_i;
    assign cs_br_ucond_d = nextLatches_cs_br_ucond_i;
    assign cs_relative_branch_d = nextLatches_cs_relative_branch_i;
    assign cs_special_br_d = nextLatches_cs_special_br_i;
    assign cs_is_far_d = nextLatches_cs_is_far_i;
    assign cs_is_call_d = nextLatches_cs_is_call_i;
    assign cs_second_flag_needed_d = nextLatches_cs_second_flag_needed_i;
    assign cs_rep_no_zf_update_d = nextLatches_cs_rep_no_zf_update_i;
    assign wb_cs_ST_OP_d = nextLatches_wb_cs_ST_OP_i;
    assign wb_cs_WB_DR_d = nextLatches_wb_cs_WB_DR_i;
    assign wb_cs_WB_SR_d = nextLatches_wb_cs_WB_SR_i;
    assign wb_cs_WB_EAX_d = nextLatches_wb_cs_WB_EAX_i;
    assign data_size_vec_d = nextLatches_data_size_vec_i;
    assign sr_data_size_vec_d = nextLatches_sr_data_size_vec_i;
    assign shift_sr_up_d = nextLatches_shift_sr_up_i;
    assign shift_sr_down_d = nextLatches_shift_sr_down_i;
    assign ST_XCL_d = nextLatches_ST_XCL_i;
    assign ST_PADDR_0_d = nextLatches_ST_PADDR_0_i;
    assign ST_PADDR_1_d = nextLatches_ST_PADDR_1_i;
    assign MIO_d = nextLatches_MIO_i;
    assign br_info_valid_d = nextLatches_br_info_valid_i;
    assign br_info_br_eip_d = nextLatches_br_info_br_eip_i;
    assign br_info_br_xcl_d = nextLatches_br_info_br_xcl_i;
    assign br_info_br_pred_taken_d = nextLatches_br_info_br_pred_taken_i;
    assign br_info_speculative_target_d = nextLatches_br_info_speculative_target_i;
    assign br_rel_target_d = nextLatches_br_rel_target_i;
    assign NEIP_d = nextLatches_NEIP_i;
    assign EIP_d = nextLatches_EIP_i;
    assign EAX_d = nextLatches_EAX_i;
    assign imm64_d = nextLatches_imm64_i;
    assign ld_buf_d = nextLatches_ld_buf_i;
    assign sr_id_d = nextLatches_sr_id_i;
    assign sr_data_d = nextLatches_sr_data_i;
    assign dr_id_d = nextLatches_dr_id_i;
    assign dr_data_d = nextLatches_dr_data_i;
    assign ld_addy_d = nextLatches_ld_addy_i;

    // ============================================================
    // REG_RST_WE per field + per-flop output buffer
    //
    // Each violating flop's Q is now driven into a `_q_raw` intermediate wire,
    // and a buffer cell (sized per the load) drives the actual `_o` output
    // port.  reg64e$ Q has weak natural drive; without explicit buffers any
    // fanout > ~16 is flagged.
    //
    // Buffer sizing (rated load):
    //   bufferH16$ : ≤16, 0.24 ns
    //   bufferH64$ : ≤64, 0.30 ns
    //   bufferH256$: ≤256, 0.54 ns  (used only where replication doesn't help)
    //
    // Replication strategy:
    //   shift_sr_up/down: 3-way (one per alu_input_sel replica)
    //   sr_id, dr_id    : 3-way (a -> sr_data MUX, b -> xchg, c -> reg_wb)
    //   ST_PADDR_0      : 3-way (a -> bit_vec_logic, b -> res_buf_logic,
    //                            c -> output ports)
    //   ld_addy         : 3-way (a/b/c -> alu_input_sel_crit/arith/ctrl)
    // ============================================================

    // ---- Q-raw wires for buffered outputs ----
    wire [4:0]   alu_inputA_sel_a_q,  alu_inputA_sel_b_q,  alu_inputA_sel_c_q;
    wire [4:0]   alu_inputB_sel_a_q,  alu_inputB_sel_b_q,  alu_inputB_sel_c_q;
    wire [4:0]   branch_target_a_q,   branch_target_b_q,   branch_target_c_q;
    wire         shift_by_one_q;
    wire         br_ucond_q;
    wire         relative_branch_q;
    wire         special_br_q;
    wire         wb_cs_WB_DR_q, wb_cs_WB_SR_q, wb_cs_WB_EAX_q;
    wire [3:0]   data_size_vec_q;
    wire [3:0]   sr_data_size_vec_q;
    wire         shift_sr_up_a_q, shift_sr_up_b_q, shift_sr_up_c_q;
    wire         shift_sr_down_a_q, shift_sr_down_b_q, shift_sr_down_c_q;
    wire         ST_XCL_q;
    wire [14:0]  ST_PADDR_0_a_q, ST_PADDR_0_b_q, ST_PADDR_0_c_q;
    wire [31:0]  br_info_br_eip_q;
    wire         br_info_br_xcl_q;
    wire [31:0]  NEIP_q, EIP_q;
    wire [63:0]  imm64_q;
    wire [4:0]   sr_id_a_q, sr_id_b_q, sr_id_c_q;
    wire [4:0]   dr_id_a_q, dr_id_b_q, dr_id_c_q;
    wire [14:0]  ld_addy_a_q, ld_addy_b_q, ld_addy_c_q;

    // ---- Flops (Q -> _q wires; non-violating flops still write directly to _o) ----

    wire valid_q;
    `REG_RST_WE(exe_latches_valid,                    1,   clk, rst, write_enable_i, valid_d,                    valid_q);
    bufferH16$ u_attach_valid_0 (.out(latches_valid_o), .in(valid_q)); // fanout
    `REG_RST_WE(exe_latches_cs_ST_OP,                 1,   clk, rst, write_enable_i, cs_ST_OP_d,                 latches_cs_ST_OP_o);
    `REG_RST_WE(exe_latches_cs_OP_TYPE,               6,   clk, rst, write_enable_i, cs_OP_TYPE_d,               latches_cs_OP_TYPE_o);

    // 3-way replicated alu_inputA/B_sel + branch_target_sel (Q's via `_q`):
    `REG_RST_WE(exe_latches_cs_alu_inputA_sel,        5,   clk, rst, write_enable_i, cs_alu_inputA_sel_d,        alu_inputA_sel_a_q);
    `REG_RST_WE(exe_latches_cs_alu_inputA_sel_b,      5,   clk, rst, write_enable_i, cs_alu_inputA_sel_d,        alu_inputA_sel_b_q);
    `REG_RST_WE(exe_latches_cs_alu_inputA_sel_c,      5,   clk, rst, write_enable_i, cs_alu_inputA_sel_d,        alu_inputA_sel_c_q);
    `REG_RST_WE(exe_latches_cs_alu_inputB_sel,        5,   clk, rst, write_enable_i, cs_alu_inputB_sel_d,        alu_inputB_sel_a_q);
    `REG_RST_WE(exe_latches_cs_alu_inputB_sel_b,      5,   clk, rst, write_enable_i, cs_alu_inputB_sel_d,        alu_inputB_sel_b_q);
    `REG_RST_WE(exe_latches_cs_alu_inputB_sel_c,      5,   clk, rst, write_enable_i, cs_alu_inputB_sel_d,        alu_inputB_sel_c_q);
    `REG_RST_WE(exe_latches_cs_branch_target_sel,     5,   clk, rst, write_enable_i, cs_branch_target_sel_d,     branch_target_a_q);
    `REG_RST_WE(exe_latches_cs_branch_target_sel_b,   5,   clk, rst, write_enable_i, cs_branch_target_sel_d,     branch_target_b_q);
    `REG_RST_WE(exe_latches_cs_branch_target_sel_c,   5,   clk, rst, write_enable_i, cs_branch_target_sel_d,     branch_target_c_q);

    `REG_RST_WE(exe_latches_cs_shift_by_one,          1,   clk, rst, write_enable_i, cs_shift_by_one_d,          shift_by_one_q);
    `REG_RST_WE(exe_latches_cs_br_ucond,              1,   clk, rst, write_enable_i, cs_br_ucond_d,              br_ucond_q);
    `REG_RST_WE(exe_latches_cs_relative_branch,       1,   clk, rst, write_enable_i, cs_relative_branch_d,       relative_branch_q);
    `REG_RST_WE(exe_latches_cs_special_br,            1,   clk, rst, write_enable_i, cs_special_br_d,            special_br_q);
    `REG_RST_WE(exe_latches_cs_is_far,                1,   clk, rst, write_enable_i, cs_is_far_d,                latches_cs_is_far_o);
    `REG_RST_WE(exe_latches_cs_is_call,               1,   clk, rst, write_enable_i, cs_is_call_d,               latches_cs_is_call_o);
    `REG_RST_WE(exe_latches_cs_second_flag_needed,    1,   clk, rst, write_enable_i, cs_second_flag_needed_d,    latches_cs_second_flag_needed_o);
    `REG_RST_WE(exe_latches_cs_rep_no_zf_update,      1,   clk, rst, write_enable_i, cs_rep_no_zf_update_d,      latches_cs_rep_no_zf_update_o);

    `REG_RST_WE(exe_latches_wb_cs_ST_OP,              1,   clk, rst, write_enable_i, wb_cs_ST_OP_d,              latches_wb_cs_ST_OP_o);
    `REG_RST_WE(exe_latches_wb_cs_WB_DR,              1,   clk, rst, write_enable_i, wb_cs_WB_DR_d,              wb_cs_WB_DR_q);
    `REG_RST_WE(exe_latches_wb_cs_WB_SR,              1,   clk, rst, write_enable_i, wb_cs_WB_SR_d,              wb_cs_WB_SR_q);
    `REG_RST_WE(exe_latches_wb_cs_WB_EAX,             1,   clk, rst, write_enable_i, wb_cs_WB_EAX_d,             wb_cs_WB_EAX_q);

    `REG_RST_WE(exe_latches_data_size_vec,            4,   clk, rst, write_enable_i, data_size_vec_d,            data_size_vec_q);
    `REG_RST_WE(exe_latches_sr_data_size_vec,         4,   clk, rst, write_enable_i, sr_data_size_vec_d,         sr_data_size_vec_q);

    // 3-way replicated shift_sr_up/down
    `REG_RST_WE(exe_latches_shift_sr_up_a,            1,   clk, rst, write_enable_i, shift_sr_up_d,              shift_sr_up_a_q);
    `REG_RST_WE(exe_latches_shift_sr_up_b,            1,   clk, rst, write_enable_i, shift_sr_up_d,              shift_sr_up_b_q);
    `REG_RST_WE(exe_latches_shift_sr_up_c,            1,   clk, rst, write_enable_i, shift_sr_up_d,              shift_sr_up_c_q);
    `REG_RST_WE(exe_latches_shift_sr_down_a,          1,   clk, rst, write_enable_i, shift_sr_down_d,            shift_sr_down_a_q);
    `REG_RST_WE(exe_latches_shift_sr_down_b,          1,   clk, rst, write_enable_i, shift_sr_down_d,            shift_sr_down_b_q);
    `REG_RST_WE(exe_latches_shift_sr_down_c,          1,   clk, rst, write_enable_i, shift_sr_down_d,            shift_sr_down_c_q);

    `REG_RST_WE(exe_latches_ST_XCL,                   1,   clk, rst, write_enable_i, ST_XCL_d,                   ST_XCL_q);

    // 3-way replicated ST_PADDR_0
    `REG_RST_WE(exe_latches_ST_PADDR_0_a,             15,  clk, rst, write_enable_i, ST_PADDR_0_d,               ST_PADDR_0_a_q);
    `REG_RST_WE(exe_latches_ST_PADDR_0_b,             15,  clk, rst, write_enable_i, ST_PADDR_0_d,               ST_PADDR_0_b_q);
    `REG_RST_WE(exe_latches_ST_PADDR_0_c,             15,  clk, rst, write_enable_i, ST_PADDR_0_d,               ST_PADDR_0_c_q);

    `REG_RST_WE(exe_latches_ST_PADDR_1,               15,  clk, rst, write_enable_i, ST_PADDR_1_d,               latches_ST_PADDR_1_o);
    `REG_RST_WE(exe_latches_MIO,                      1,   clk, rst, write_enable_i, MIO_d,                      latches_MIO_o);

    `REG_RST_WE(exe_latches_br_info_valid,            1,   clk, rst, write_enable_i, br_info_valid_d,            latches_br_info_valid_o);
    `REG_RST_WE(exe_latches_br_info_br_eip,           32,  clk, rst, write_enable_i, br_info_br_eip_d,           br_info_br_eip_q);
    `REG_RST_WE(exe_latches_br_info_br_xcl,           1,   clk, rst, write_enable_i, br_info_br_xcl_d,           br_info_br_xcl_q);
    `REG_RST_WE(exe_latches_br_info_br_pred_taken,    1,   clk, rst, write_enable_i, br_info_br_pred_taken_d,    latches_br_info_br_pred_taken_o);
    `REG_RST_WE(exe_latches_br_info_speculative_target, 32, clk, rst, write_enable_i, br_info_speculative_target_d, latches_br_info_speculative_target_o);

    `REG_RST_WE(exe_latches_br_rel_target,            32,  clk, rst, write_enable_i, br_rel_target_d,            latches_br_rel_target_o);

    `REG_RST_WE(exe_latches_NEIP,                     32,  clk, rst, write_enable_i, NEIP_d,                     NEIP_q);
    `REG_RST_WE(exe_latches_EIP,                      32,  clk, rst, write_enable_i, EIP_d,                      EIP_q);
    `REG_RST_WE(exe_latches_EAX,                      32,  clk, rst, write_enable_i, EAX_d,                      latches_EAX_o);

    `REG_RST_WE(exe_latches_imm64,                    64,  clk, rst, write_enable_i, imm64_d,                    imm64_q);

    wire [255:0] ld_buf_q;
    `REG_RST_WE(exe_latches_ld_buf,                   256, clk, rst, write_enable_i, ld_buf_d,                   ld_buf_q);
    // ld_buf q-bit attach: 63,127,191 -> bufferH64$; 239 -> bufferH16$; rest passthrough
    bufferH64$ u_attach_ldbuf_63  (.out(latches_ld_buf_o[63]),  .in(ld_buf_q[63]));  // fanout
    bufferH64$ u_attach_ldbuf_127 (.out(latches_ld_buf_o[127]), .in(ld_buf_q[127])); // fanout
    bufferH64$ u_attach_ldbuf_191 (.out(latches_ld_buf_o[191]), .in(ld_buf_q[191])); // fanout
    bufferH16$ u_attach_ldbuf_239 (.out(latches_ld_buf_o[239]), .in(ld_buf_q[239])); // fanout
    assign latches_ld_buf_o[62:0]    = ld_buf_q[62:0];
    assign latches_ld_buf_o[126:64]  = ld_buf_q[126:64];
    assign latches_ld_buf_o[190:128] = ld_buf_q[190:128];
    assign latches_ld_buf_o[238:192] = ld_buf_q[238:192];
    assign latches_ld_buf_o[255:240] = ld_buf_q[255:240];

    // 3-way replicated sr_id, dr_id
    `REG_RST_WE(exe_latches_sr_id_a,                  5,   clk, rst, write_enable_i, sr_id_d,                    sr_id_a_q);
    `REG_RST_WE(exe_latches_sr_id_b,                  5,   clk, rst, write_enable_i, sr_id_d,                    sr_id_b_q);
    `REG_RST_WE(exe_latches_sr_id_c,                  5,   clk, rst, write_enable_i, sr_id_d,                    sr_id_c_q);
    `REG_RST_WE(exe_latches_sr_data,                  64,  clk, rst, write_enable_i, sr_data_d,                  latches_sr_data_o);
    `REG_RST_WE(exe_latches_dr_id_a,                  5,   clk, rst, write_enable_i, dr_id_d,                    dr_id_a_q);
    `REG_RST_WE(exe_latches_dr_id_b,                  5,   clk, rst, write_enable_i, dr_id_d,                    dr_id_b_q);
    `REG_RST_WE(exe_latches_dr_id_c,                  5,   clk, rst, write_enable_i, dr_id_d,                    dr_id_c_q);
    `REG_RST_WE(exe_latches_dr_data,                  64,  clk, rst, write_enable_i, dr_data_d,                  latches_dr_data_o);

    // 3-way replicated ld_addy
    `REG_RST_WE(exe_latches_ld_addy_a,                15,  clk, rst, write_enable_i, ld_addy_d,                  ld_addy_a_q);
    `REG_RST_WE(exe_latches_ld_addy_b,                15,  clk, rst, write_enable_i, ld_addy_d,                  ld_addy_b_q);
    `REG_RST_WE(exe_latches_ld_addy_c,                15,  clk, rst, write_enable_i, ld_addy_d,                  ld_addy_c_q);

    // ============================================================
    // Output buffers (Q -> port)
    // ============================================================

    // alu_inputA/B_sel + branch_target_sel staging buses (fanout attach below)
    wire [4:0] _pre_inA_a, _pre_inA_b, _pre_inA_c;
    wire [4:0] _pre_inB_a, _pre_inB_b, _pre_inB_c;
    wire [4:0] _pre_brT_a, _pre_brT_b, _pre_brT_c;

    genvar gi_a5;
    generate
        for (gi_a5 = 0; gi_a5 < 5; gi_a5 = gi_a5 + 1) begin : g_a5_buf
            bufferH64$ u_buf_inA_a (.out(_pre_inA_a[gi_a5]), .in(alu_inputA_sel_a_q[gi_a5]));
            bufferH64$ u_buf_inA_b (.out(_pre_inA_b[gi_a5]), .in(alu_inputA_sel_b_q[gi_a5]));
            bufferH64$ u_buf_inA_c (.out(_pre_inA_c[gi_a5]), .in(alu_inputA_sel_c_q[gi_a5]));
            bufferH64$ u_buf_inB_a (.out(_pre_inB_a[gi_a5]), .in(alu_inputB_sel_a_q[gi_a5]));
            bufferH64$ u_buf_inB_b (.out(_pre_inB_b[gi_a5]), .in(alu_inputB_sel_b_q[gi_a5]));
            bufferH64$ u_buf_inB_c (.out(_pre_inB_c[gi_a5]), .in(alu_inputB_sel_c_q[gi_a5]));
            bufferH64$ u_buf_brT_a (.out(_pre_brT_a[gi_a5]), .in(branch_target_a_q[gi_a5]));
            bufferH64$ u_buf_brT_b (.out(_pre_brT_b[gi_a5]), .in(branch_target_b_q[gi_a5]));
            bufferH64$ u_buf_brT_c (.out(_pre_brT_c[gi_a5]), .in(branch_target_c_q[gi_a5]));
        end
    endgenerate

    // per-bit attached buffers per fanout report (alu_inputA_sel a/b/c: bits 0,1=1024; 2,3=256; 4 passthrough)
    bufferH1024$ u_attach_inA_a_0 (.out(latches_cs_alu_inputA_sel_o[0]), .in(_pre_inA_a[0])); // fanout
    bufferH1024$ u_attach_inA_a_1 (.out(latches_cs_alu_inputA_sel_o[1]), .in(_pre_inA_a[1])); // fanout
    bufferH256$  u_attach_inA_a_2 (.out(latches_cs_alu_inputA_sel_o[2]), .in(_pre_inA_a[2])); // fanout
    bufferH256$  u_attach_inA_a_3 (.out(latches_cs_alu_inputA_sel_o[3]), .in(_pre_inA_a[3])); // fanout
    assign latches_cs_alu_inputA_sel_o[4] = _pre_inA_a[4];

    bufferH1024$ u_attach_inA_b_0 (.out(latches_cs_alu_inputA_sel_b_o[0]), .in(_pre_inA_b[0])); // fanout
    bufferH1024$ u_attach_inA_b_1 (.out(latches_cs_alu_inputA_sel_b_o[1]), .in(_pre_inA_b[1])); // fanout
    bufferH256$  u_attach_inA_b_2 (.out(latches_cs_alu_inputA_sel_b_o[2]), .in(_pre_inA_b[2])); // fanout
    bufferH256$  u_attach_inA_b_3 (.out(latches_cs_alu_inputA_sel_b_o[3]), .in(_pre_inA_b[3])); // fanout
    assign latches_cs_alu_inputA_sel_b_o[4] = _pre_inA_b[4];

    bufferH1024$ u_attach_inA_c_0 (.out(latches_cs_alu_inputA_sel_c_o[0]), .in(_pre_inA_c[0])); // fanout
    bufferH1024$ u_attach_inA_c_1 (.out(latches_cs_alu_inputA_sel_c_o[1]), .in(_pre_inA_c[1])); // fanout
    bufferH256$  u_attach_inA_c_2 (.out(latches_cs_alu_inputA_sel_c_o[2]), .in(_pre_inA_c[2])); // fanout
    bufferH256$  u_attach_inA_c_3 (.out(latches_cs_alu_inputA_sel_c_o[3]), .in(_pre_inA_c[3])); // fanout
    assign latches_cs_alu_inputA_sel_c_o[4] = _pre_inA_c[4];

    bufferH1024$ u_attach_inB_a_0 (.out(latches_cs_alu_inputB_sel_o[0]), .in(_pre_inB_a[0])); // fanout
    bufferH1024$ u_attach_inB_a_1 (.out(latches_cs_alu_inputB_sel_o[1]), .in(_pre_inB_a[1])); // fanout
    bufferH256$  u_attach_inB_a_2 (.out(latches_cs_alu_inputB_sel_o[2]), .in(_pre_inB_a[2])); // fanout
    bufferH256$  u_attach_inB_a_3 (.out(latches_cs_alu_inputB_sel_o[3]), .in(_pre_inB_a[3])); // fanout
    assign latches_cs_alu_inputB_sel_o[4] = _pre_inB_a[4];

    bufferH1024$ u_attach_inB_b_0 (.out(latches_cs_alu_inputB_sel_b_o[0]), .in(_pre_inB_b[0])); // fanout
    bufferH1024$ u_attach_inB_b_1 (.out(latches_cs_alu_inputB_sel_b_o[1]), .in(_pre_inB_b[1])); // fanout
    bufferH256$  u_attach_inB_b_2 (.out(latches_cs_alu_inputB_sel_b_o[2]), .in(_pre_inB_b[2])); // fanout
    bufferH256$  u_attach_inB_b_3 (.out(latches_cs_alu_inputB_sel_b_o[3]), .in(_pre_inB_b[3])); // fanout
    assign latches_cs_alu_inputB_sel_b_o[4] = _pre_inB_b[4];

    bufferH1024$ u_attach_inB_c_0 (.out(latches_cs_alu_inputB_sel_c_o[0]), .in(_pre_inB_c[0])); // fanout
    bufferH1024$ u_attach_inB_c_1 (.out(latches_cs_alu_inputB_sel_c_o[1]), .in(_pre_inB_c[1])); // fanout
    bufferH256$  u_attach_inB_c_2 (.out(latches_cs_alu_inputB_sel_c_o[2]), .in(_pre_inB_c[2])); // fanout
    bufferH256$  u_attach_inB_c_3 (.out(latches_cs_alu_inputB_sel_c_o[3]), .in(_pre_inB_c[3])); // fanout
    assign latches_cs_alu_inputB_sel_c_o[4] = _pre_inB_c[4];

    // branch_target_sel a/b/c: bits 0,1=256; 2,3,4 passthrough
    bufferH256$ u_attach_brT_a_0 (.out(latches_cs_branch_target_sel_o[0]), .in(_pre_brT_a[0])); // fanout
    bufferH256$ u_attach_brT_a_1 (.out(latches_cs_branch_target_sel_o[1]), .in(_pre_brT_a[1])); // fanout
    assign latches_cs_branch_target_sel_o[2] = _pre_brT_a[2];
    assign latches_cs_branch_target_sel_o[3] = _pre_brT_a[3];
    assign latches_cs_branch_target_sel_o[4] = _pre_brT_a[4];

    bufferH256$ u_attach_brT_b_0 (.out(latches_cs_branch_target_sel_b_o[0]), .in(_pre_brT_b[0])); // fanout
    bufferH256$ u_attach_brT_b_1 (.out(latches_cs_branch_target_sel_b_o[1]), .in(_pre_brT_b[1])); // fanout
    assign latches_cs_branch_target_sel_b_o[2] = _pre_brT_b[2];
    assign latches_cs_branch_target_sel_b_o[3] = _pre_brT_b[3];
    assign latches_cs_branch_target_sel_b_o[4] = _pre_brT_b[4];

    bufferH256$ u_attach_brT_c_0 (.out(latches_cs_branch_target_sel_c_o[0]), .in(_pre_brT_c[0])); // fanout
    bufferH256$ u_attach_brT_c_1 (.out(latches_cs_branch_target_sel_c_o[1]), .in(_pre_brT_c[1])); // fanout
    assign latches_cs_branch_target_sel_c_o[2] = _pre_brT_c[2];
    assign latches_cs_branch_target_sel_c_o[3] = _pre_brT_c[3];
    assign latches_cs_branch_target_sel_c_o[4] = _pre_brT_c[4];

    // 1-bit signals (sized per fanout)
    bufferH16$  u_buf_shift_by_one  (.out(latches_cs_shift_by_one_o),     .in(shift_by_one_q));
    bufferH256$ u_buf_br_ucond      (.out(latches_cs_br_ucond_o),         .in(br_ucond_q));      // fanout 65
    bufferH64$  u_buf_relative_br   (.out(latches_cs_relative_branch_o),  .in(relative_branch_q));
    bufferH64$  u_buf_special_br    (.out(latches_cs_special_br_o),       .in(special_br_q));
    bufferH256$ u_buf_wb_dr         (.out(latches_wb_cs_WB_DR_o),         .in(wb_cs_WB_DR_q));    // fanout 66
    bufferH256$ u_buf_wb_sr         (.out(latches_wb_cs_WB_SR_o),         .in(wb_cs_WB_SR_q));    // fanout 66
    bufferH256$ u_buf_wb_eax        (.out(latches_wb_cs_WB_EAX_o),        .in(wb_cs_WB_EAX_q));   // fanout 75
    bufferH64$  u_buf_ST_XCL        (.out(latches_ST_XCL_o),              .in(ST_XCL_q));
    bufferH64$  u_buf_br_xcl        (.out(latches_br_info_br_xcl_o),      .in(br_info_br_xcl_q));

    // shift_sr_up/down 3 replicas, each fanout 64 -> bufferH64$
    bufferH64$  u_buf_ssup_a   (.out(latches_shift_sr_up_o),     .in(shift_sr_up_a_q));
    bufferH64$  u_buf_ssup_b   (.out(latches_shift_sr_up_b_o),   .in(shift_sr_up_b_q));
    bufferH64$  u_buf_ssup_c   (.out(latches_shift_sr_up_c_o),   .in(shift_sr_up_c_q));
    bufferH64$  u_buf_ssdn_a   (.out(latches_shift_sr_down_o),   .in(shift_sr_down_a_q));
    bufferH64$  u_buf_ssdn_b   (.out(latches_shift_sr_down_b_o), .in(shift_sr_down_b_q));
    bufferH64$  u_buf_ssdn_c   (.out(latches_shift_sr_down_c_o), .in(shift_sr_down_c_q));

    // data_size_vec (fanout 6) bufferH16$ per bit; sr_data_size_vec (fanout 32) bufferH64$ per bit
    genvar gi_dsz4;
    generate
        for (gi_dsz4 = 0; gi_dsz4 < 4; gi_dsz4 = gi_dsz4 + 1) begin : g_dsz4_buf
            bufferH16$  u_buf_dsv  (.out(latches_data_size_vec_o[gi_dsz4]),    .in(data_size_vec_q[gi_dsz4]));
            bufferH64$  u_buf_srdsv(.out(latches_sr_data_size_vec_o[gi_dsz4]), .in(sr_data_size_vec_q[gi_dsz4]));
        end
    endgenerate

    // ST_PADDR_0 3 replicas; b-replica bits 0,1 need bufferH1024$ attach
    wire [14:0] _pre_paddr_b;
    genvar gi_paddr;
    generate
        for (gi_paddr = 0; gi_paddr < 15; gi_paddr = gi_paddr + 1) begin : g_paddr_buf
            bufferH256$ u_buf_paddr_a (.out(latches_ST_PADDR_0_o[gi_paddr]),   .in(ST_PADDR_0_a_q[gi_paddr]));
            bufferH256$ u_buf_paddr_b (.out(_pre_paddr_b[gi_paddr]),           .in(ST_PADDR_0_b_q[gi_paddr]));
            bufferH256$ u_buf_paddr_c (.out(latches_ST_PADDR_0_c_o[gi_paddr]), .in(ST_PADDR_0_c_q[gi_paddr]));
        end
    endgenerate

    // ST_PADDR_0_b: bits 0,1 -> bufferH1024$ attach; rest passthrough
    bufferH1024$ u_attach_paddr_b_0 (.out(latches_ST_PADDR_0_b_o[0]), .in(_pre_paddr_b[0])); // fanout
    bufferH1024$ u_attach_paddr_b_1 (.out(latches_ST_PADDR_0_b_o[1]), .in(_pre_paddr_b[1])); // fanout
    assign latches_ST_PADDR_0_b_o[14:2] = _pre_paddr_b[14:2];

    // br_info_br_eip (32-bit, fanout 128) -> bufferH256$ per bit
    genvar gi_br_eip;
    generate
        for (gi_br_eip = 0; gi_br_eip < 32; gi_br_eip = gi_br_eip + 1) begin : g_breip_buf
            bufferH256$ u_buf_breip (.out(latches_br_info_br_eip_o[gi_br_eip]), .in(br_info_br_eip_q[gi_br_eip]));
        end
    endgenerate

    // NEIP (fanout 11), EIP (fanout 7) -> bufferH16$ per bit (small fanout)
    genvar gi_neip;
    generate
        for (gi_neip = 0; gi_neip < 32; gi_neip = gi_neip + 1) begin : g_neip_buf
            bufferH16$ u_buf_neip (.out(latches_NEIP_o[gi_neip]), .in(NEIP_q[gi_neip]));
            bufferH16$ u_buf_eip  (.out(latches_EIP_o[gi_neip]),  .in(EIP_q[gi_neip]));
        end
    endgenerate

    // imm64: bits 0..6 need bufferH64$ attach; bit 7 needs bufferH256$; rest passthrough
    wire [63:0] _pre_imm;
    genvar gi_imm;
    generate
        for (gi_imm = 0; gi_imm < 64; gi_imm = gi_imm + 1) begin : g_imm_buf
            bufferH16$ u_buf_imm (.out(_pre_imm[gi_imm]), .in(imm64_q[gi_imm]));
        end
    endgenerate

    bufferH64$  u_attach_imm_0 (.out(latches_imm64_o[0]), .in(_pre_imm[0])); // fanout
    bufferH64$  u_attach_imm_1 (.out(latches_imm64_o[1]), .in(_pre_imm[1])); // fanout
    bufferH64$  u_attach_imm_2 (.out(latches_imm64_o[2]), .in(_pre_imm[2])); // fanout
    bufferH64$  u_attach_imm_3 (.out(latches_imm64_o[3]), .in(_pre_imm[3])); // fanout
    bufferH64$  u_attach_imm_4 (.out(latches_imm64_o[4]), .in(_pre_imm[4])); // fanout
    bufferH64$  u_attach_imm_5 (.out(latches_imm64_o[5]), .in(_pre_imm[5])); // fanout
    bufferH64$  u_attach_imm_6 (.out(latches_imm64_o[6]), .in(_pre_imm[6])); // fanout
    bufferH256$ u_attach_imm_7 (.out(latches_imm64_o[7]), .in(_pre_imm[7])); // fanout
    assign latches_imm64_o[63:8] = _pre_imm[63:8];

    // sr_id, dr_id 3 replicas; sr_a / dr_a need attach: bits 0,1 -> 1024; bits 2,3,4 -> 256
    wire [4:0] _pre_sr_a, _pre_dr_a;
    generate
        for (gi_a5 = 0; gi_a5 < 5; gi_a5 = gi_a5 + 1) begin : g_id_buf
            bufferH64$ u_buf_sr_a (.out(_pre_sr_a[gi_a5]),         .in(sr_id_a_q[gi_a5]));
            bufferH64$ u_buf_sr_b (.out(latches_sr_id_b_o[gi_a5]), .in(sr_id_b_q[gi_a5]));
            bufferH64$ u_buf_sr_c (.out(latches_sr_id_c_o[gi_a5]), .in(sr_id_c_q[gi_a5]));
            bufferH64$ u_buf_dr_a (.out(_pre_dr_a[gi_a5]),         .in(dr_id_a_q[gi_a5]));
            bufferH64$ u_buf_dr_b (.out(latches_dr_id_b_o[gi_a5]), .in(dr_id_b_q[gi_a5]));
            bufferH64$ u_buf_dr_c (.out(latches_dr_id_c_o[gi_a5]), .in(dr_id_c_q[gi_a5]));
        end
    endgenerate

    bufferH1024$ u_attach_sr_a_0 (.out(latches_sr_id_o[0]), .in(_pre_sr_a[0])); // fanout
    bufferH1024$ u_attach_sr_a_1 (.out(latches_sr_id_o[1]), .in(_pre_sr_a[1])); // fanout
    bufferH256$  u_attach_sr_a_2 (.out(latches_sr_id_o[2]), .in(_pre_sr_a[2])); // fanout
    bufferH256$  u_attach_sr_a_3 (.out(latches_sr_id_o[3]), .in(_pre_sr_a[3])); // fanout
    bufferH256$  u_attach_sr_a_4 (.out(latches_sr_id_o[4]), .in(_pre_sr_a[4])); // fanout

    bufferH1024$ u_attach_dr_a_0 (.out(latches_dr_id_o[0]), .in(_pre_dr_a[0])); // fanout
    bufferH1024$ u_attach_dr_a_1 (.out(latches_dr_id_o[1]), .in(_pre_dr_a[1])); // fanout
    bufferH256$  u_attach_dr_a_2 (.out(latches_dr_id_o[2]), .in(_pre_dr_a[2])); // fanout
    bufferH256$  u_attach_dr_a_3 (.out(latches_dr_id_o[3]), .in(_pre_dr_a[3])); // fanout
    bufferH256$  u_attach_dr_a_4 (.out(latches_dr_id_o[4]), .in(_pre_dr_a[4])); // fanout

    // ld_addy 3 replicas; bits 0,1 of each replica need bufferH1024$ attach
    wire [14:0] _pre_ldy_a, _pre_ldy_b, _pre_ldy_c;
    genvar gi_ldy;
    generate
        for (gi_ldy = 0; gi_ldy < 15; gi_ldy = gi_ldy + 1) begin : g_ldy_buf
            bufferH256$ u_buf_ldy_a (.out(_pre_ldy_a[gi_ldy]), .in(ld_addy_a_q[gi_ldy]));
            bufferH256$ u_buf_ldy_b (.out(_pre_ldy_b[gi_ldy]), .in(ld_addy_b_q[gi_ldy]));
            bufferH256$ u_buf_ldy_c (.out(_pre_ldy_c[gi_ldy]), .in(ld_addy_c_q[gi_ldy]));
        end
    endgenerate

    bufferH1024$ u_attach_ldy_a_0 (.out(latches_ld_addy_o[0]), .in(_pre_ldy_a[0])); // fanout
    bufferH1024$ u_attach_ldy_a_1 (.out(latches_ld_addy_o[1]), .in(_pre_ldy_a[1])); // fanout
    assign latches_ld_addy_o[14:2] = _pre_ldy_a[14:2];

    bufferH1024$ u_attach_ldy_b_0 (.out(latches_ld_addy_b_o[0]), .in(_pre_ldy_b[0])); // fanout
    bufferH1024$ u_attach_ldy_b_1 (.out(latches_ld_addy_b_o[1]), .in(_pre_ldy_b[1])); // fanout
    assign latches_ld_addy_b_o[14:2] = _pre_ldy_b[14:2];

    bufferH1024$ u_attach_ldy_c_0 (.out(latches_ld_addy_c_o[0]), .in(_pre_ldy_c[0])); // fanout
    bufferH1024$ u_attach_ldy_c_1 (.out(latches_ld_addy_c_o[1]), .in(_pre_ldy_c[1])); // fanout
    assign latches_ld_addy_c_o[14:2] = _pre_ldy_c[14:2];

endmodule
