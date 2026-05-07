// =============================================================================
// MEM_Latches  (pure Verilog-2005 structural stage latch)
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
//         bool LD_OP;
//     } mem_cs_t;
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
//         mem_cs_t cs;
//         exe_cs_t exe_cs;
//         wb_cs_t wb_cs;
//         br_info_t br_info;
//         logic [3:0] data_size_vec;
//         logic [3:0] sr_data_size_vec;
//         bool shift_sr_up;
//         bool shift_sr_down;
//         bool ST_XCL;
//         p_address_t ST_PADDR_0;
//         p_address_t ST_PADDR_1;
//         bool MIO;
//         l_address_t NEIP;
//         l_address_t EIP;
//         uint32_t EAX;
//         uint64_t imm64;
//         reg_ids_e sr_id;
//         uint64_t  sr_data;
//         reg_ids_e dr_id;
//         uint64_t  dr_data;
//         bool LD_XCL;
//         bool swapLines;
//         p_address_t LD_PADDR_0;
//         p_address_t LD_PADDR_1;
//     } mem_latches_t;
//
//   Flush behavior (matches non-structural reference):
//     - !rst                           -> latches <= 0  (REG_RST_WE async reset)
//     - flush || farFlush              -> latches <= 0  (regardless of write_enable_i)
//     - write_enable_i && !any_flush   -> latches <= nextLatches
//     - !write_enable_i && !any_flush  -> hold
//     Implementation:
//       combined_flush = flush OR farFlush
//       effective_we   = write_enable_i OR combined_flush
//       per-field MUX_2 selects (combined_flush ? 0 : nextLatches), output
//       feeds REG_RST_WE.d, with we = effective_we.
//
//   - SV `import` removed; no struct/typedef/enum used.
//   - Every field is its own scalar/vector port (`.field` -> `_field`).
// =============================================================================

module MEM_Latches (
    input wire clk,
    input wire rst,
    input wire write_enable_i,
    input wire flush,
    input wire farFlush,

    // ----- nextLatches_i (unrolled) -----
    input wire        nextLatches_valid_i,

    // mem_cs_t cs
    input wire        nextLatches_cs_ST_OP_i,
    input wire        nextLatches_cs_LD_OP_i,

    // exe_cs_t exe_cs
    input wire        nextLatches_exe_cs_ST_OP_i,
    input wire [5:0]  nextLatches_exe_cs_OP_TYPE_i,
    input wire [4:0]  nextLatches_exe_cs_alu_inputA_sel_i,
    input wire [4:0]  nextLatches_exe_cs_alu_inputB_sel_i,
    input wire [4:0]  nextLatches_exe_cs_branch_target_sel_i,
    input wire        nextLatches_exe_cs_shift_by_one_i,
    input wire        nextLatches_exe_cs_br_ucond_i,
    input wire        nextLatches_exe_cs_relative_branch_i,
    input wire        nextLatches_exe_cs_special_br_i,
    input wire        nextLatches_exe_cs_is_far_i,
    input wire        nextLatches_exe_cs_is_call_i,
    input wire        nextLatches_exe_cs_second_flag_needed_i,
    input wire        nextLatches_exe_cs_rep_no_zf_update_i,

    // wb_cs_t wb_cs
    input wire        nextLatches_wb_cs_ST_OP_i,
    input wire        nextLatches_wb_cs_WB_DR_i,
    input wire        nextLatches_wb_cs_WB_SR_i,
    input wire        nextLatches_wb_cs_WB_EAX_i,

    // br_info_t br_info
    input wire        nextLatches_br_info_valid_i,
    input wire [31:0] nextLatches_br_info_br_eip_i,
    input wire        nextLatches_br_info_br_xcl_i,
    input wire        nextLatches_br_info_br_pred_taken_i,
    input wire [31:0] nextLatches_br_info_speculative_target_i,

    input wire [3:0]  nextLatches_data_size_vec_i,
    input wire [3:0]  nextLatches_sr_data_size_vec_i,
    input wire        nextLatches_shift_sr_up_i,
    input wire        nextLatches_shift_sr_down_i,

    input wire        nextLatches_ST_XCL_i,
    input wire [14:0] nextLatches_ST_PADDR_0_i,
    input wire [14:0] nextLatches_ST_PADDR_1_i,
    input wire        nextLatches_MIO_i,

    input wire [31:0] nextLatches_NEIP_i,
    input wire [31:0] nextLatches_EIP_i,
    input wire [31:0] nextLatches_EAX_i,

    input wire [63:0] nextLatches_imm64_i,

    input wire [4:0]  nextLatches_sr_id_i,
    input wire [63:0] nextLatches_sr_data_i,
    input wire [4:0]  nextLatches_dr_id_i,
    input wire [63:0] nextLatches_dr_data_i,

    input wire        nextLatches_LD_XCL_i,
    input wire        nextLatches_swapLines_i,
    input wire [14:0] nextLatches_LD_PADDR_0_i,
    input wire [14:0] nextLatches_LD_PADDR_1_i,

    // ----- latches_o (unrolled) -----
    output wire        latches_valid_o,

    output wire        latches_cs_ST_OP_o,
    output wire        latches_cs_LD_OP_o,

    output wire        latches_exe_cs_ST_OP_o,
    output wire [5:0]  latches_exe_cs_OP_TYPE_o,
    output wire [4:0]  latches_exe_cs_alu_inputA_sel_o,
    output wire [4:0]  latches_exe_cs_alu_inputB_sel_o,
    output wire [4:0]  latches_exe_cs_branch_target_sel_o,
    output wire        latches_exe_cs_shift_by_one_o,
    output wire        latches_exe_cs_br_ucond_o,
    output wire        latches_exe_cs_relative_branch_o,
    output wire        latches_exe_cs_special_br_o,
    output wire        latches_exe_cs_is_far_o,
    output wire        latches_exe_cs_is_call_o,
    output wire        latches_exe_cs_second_flag_needed_o,
    output wire        latches_exe_cs_rep_no_zf_update_o,

    output wire        latches_wb_cs_ST_OP_o,
    output wire        latches_wb_cs_WB_DR_o,
    output wire        latches_wb_cs_WB_SR_o,
    output wire        latches_wb_cs_WB_EAX_o,

    output wire        latches_br_info_valid_o,
    output wire [31:0] latches_br_info_br_eip_o,
    output wire        latches_br_info_br_xcl_o,
    output wire        latches_br_info_br_pred_taken_o,
    output wire [31:0] latches_br_info_speculative_target_o,

    output wire [3:0]  latches_data_size_vec_o,
    output wire [3:0]  latches_sr_data_size_vec_o,
    output wire        latches_shift_sr_up_o,
    output wire        latches_shift_sr_down_o,

    output wire        latches_ST_XCL_o,
    output wire [14:0] latches_ST_PADDR_0_o,
    output wire [14:0] latches_ST_PADDR_1_o,
    output wire        latches_MIO_o,

    output wire [31:0] latches_NEIP_o,
    output wire [31:0] latches_EIP_o,
    output wire [31:0] latches_EAX_o,

    output wire [63:0] latches_imm64_o,

    output wire [4:0]  latches_sr_id_o,
    output wire [63:0] latches_sr_data_o,
    output wire [4:0]  latches_dr_id_o,
    output wire [63:0] latches_dr_data_o,

    output wire        latches_LD_XCL_o,
    output wire        latches_swapLines_o,
    output wire [14:0] latches_LD_PADDR_0_o,
    output wire [14:0] latches_LD_PADDR_1_o
);

    // ============================================================
    // Combined flush + effective WE
    //   combined_flush = flush  OR farFlush
    //   effective_we   = write_enable_i OR combined_flush
    // ============================================================

    wire combined_flush = flush;
    wire effective_we;

    //`OR_2(u_mem_combined_flush, 1, combined_flush, flush,           farFlush);
    `OR_2(u_mem_effective_we,   1, effective_we,  write_enable_i,  combined_flush);

    // ============================================================
    // Flush-gated data wires (input to each REG_RST_WE)
    //   <field>_d = (combined_flush) ? 0 : nextLatches_<field>_i
    // ============================================================

    wire        valid_d;

    wire        cs_ST_OP_d;
    wire        cs_LD_OP_d;

    wire        exe_cs_ST_OP_d;
    wire [5:0]  exe_cs_OP_TYPE_d;
    wire [4:0]  exe_cs_alu_inputA_sel_d;
    wire [4:0]  exe_cs_alu_inputB_sel_d;
    wire [4:0]  exe_cs_branch_target_sel_d;
    wire        exe_cs_shift_by_one_d;
    wire        exe_cs_br_ucond_d;
    wire        exe_cs_relative_branch_d;
    wire        exe_cs_special_br_d;
    wire        exe_cs_is_far_d;
    wire        exe_cs_is_call_d;
    wire        exe_cs_second_flag_needed_d;
    wire        exe_cs_rep_no_zf_update_d;

    wire        wb_cs_ST_OP_d;
    wire        wb_cs_WB_DR_d;
    wire        wb_cs_WB_SR_d;
    wire        wb_cs_WB_EAX_d;

    wire        br_info_valid_d;
    wire [31:0] br_info_br_eip_d;
    wire        br_info_br_xcl_d;
    wire        br_info_br_pred_taken_d;
    wire [31:0] br_info_speculative_target_d;

    wire [3:0]  data_size_vec_d;
    wire [3:0]  sr_data_size_vec_d;
    wire        shift_sr_up_d;
    wire        shift_sr_down_d;

    wire        ST_XCL_d;
    wire [14:0] ST_PADDR_0_d;
    wire [14:0] ST_PADDR_1_d;
    wire        MIO_d;

    wire [31:0] NEIP_d;
    wire [31:0] EIP_d;
    wire [31:0] EAX_d;

    wire [63:0] imm64_d;

    wire [4:0]  sr_id_d;
    wire [63:0] sr_data_d;
    wire [4:0]  dr_id_d;
    wire [63:0] dr_data_d;

    wire        LD_XCL_d;
    wire        swapLines_d;
    wire [14:0] LD_PADDR_0_d;
    wire [14:0] LD_PADDR_1_d;

    // -------- flush MUX per field (in1 = 0, sel = combined_flush) --------

    assign valid_d = nextLatches_valid_i;
    assign cs_ST_OP_d = nextLatches_cs_ST_OP_i;
    assign cs_LD_OP_d = nextLatches_cs_LD_OP_i;
    assign exe_cs_ST_OP_d = nextLatches_exe_cs_ST_OP_i;
    assign exe_cs_OP_TYPE_d = nextLatches_exe_cs_OP_TYPE_i;
    assign exe_cs_alu_inputA_sel_d = nextLatches_exe_cs_alu_inputA_sel_i;
    assign exe_cs_alu_inputB_sel_d = nextLatches_exe_cs_alu_inputB_sel_i;
    assign exe_cs_branch_target_sel_d = nextLatches_exe_cs_branch_target_sel_i;
    assign exe_cs_shift_by_one_d = nextLatches_exe_cs_shift_by_one_i;
    assign exe_cs_br_ucond_d = nextLatches_exe_cs_br_ucond_i;
    assign exe_cs_relative_branch_d = nextLatches_exe_cs_relative_branch_i;
    assign exe_cs_special_br_d = nextLatches_exe_cs_special_br_i;
    assign exe_cs_is_far_d = nextLatches_exe_cs_is_far_i;
    assign exe_cs_is_call_d = nextLatches_exe_cs_is_call_i;
    assign exe_cs_second_flag_needed_d = nextLatches_exe_cs_second_flag_needed_i;
    assign exe_cs_rep_no_zf_update_d = nextLatches_exe_cs_rep_no_zf_update_i;
    assign wb_cs_ST_OP_d = nextLatches_wb_cs_ST_OP_i;
    assign wb_cs_WB_DR_d = nextLatches_wb_cs_WB_DR_i;
    assign wb_cs_WB_SR_d = nextLatches_wb_cs_WB_SR_i;
    assign wb_cs_WB_EAX_d = nextLatches_wb_cs_WB_EAX_i;
    assign br_info_valid_d = nextLatches_br_info_valid_i;
    assign br_info_br_eip_d = nextLatches_br_info_br_eip_i;
    assign br_info_br_xcl_d = nextLatches_br_info_br_xcl_i;
    assign br_info_br_pred_taken_d = nextLatches_br_info_br_pred_taken_i;
    assign br_info_speculative_target_d = nextLatches_br_info_speculative_target_i;
    assign data_size_vec_d = nextLatches_data_size_vec_i;
    assign sr_data_size_vec_d = nextLatches_sr_data_size_vec_i;
    assign shift_sr_up_d = nextLatches_shift_sr_up_i;
    assign shift_sr_down_d = nextLatches_shift_sr_down_i;
    assign ST_XCL_d = nextLatches_ST_XCL_i;
    assign ST_PADDR_0_d = nextLatches_ST_PADDR_0_i;
    assign ST_PADDR_1_d = nextLatches_ST_PADDR_1_i;
    assign MIO_d = nextLatches_MIO_i;
    assign NEIP_d = nextLatches_NEIP_i;
    assign EIP_d = nextLatches_EIP_i;
    assign EAX_d = nextLatches_EAX_i;
    assign imm64_d = nextLatches_imm64_i;
    assign sr_id_d = nextLatches_sr_id_i;
    assign sr_data_d = nextLatches_sr_data_i;
    assign dr_id_d = nextLatches_dr_id_i;
    assign dr_data_d = nextLatches_dr_data_i;
    assign LD_XCL_d = nextLatches_LD_XCL_i;
    assign swapLines_d = nextLatches_swapLines_i;
    assign LD_PADDR_0_d = nextLatches_LD_PADDR_0_i;
    assign LD_PADDR_1_d = nextLatches_LD_PADDR_1_i;

    // ============================================================
    // REG_RST_WE per field (we = effective_we)
    // `REG_RST_WE(__unitName__, __width__, __clk__, __rst__, __we__, __din__, __dout__)
    //   active async low rst
    // ============================================================

    `REG_RST_WE(mem_latches_valid,                          1,   clk, rst, effective_we, valid_d,                          latches_valid_o);

    `REG_RST_WE(mem_latches_cs_ST_OP,                       1,   clk, rst, effective_we, cs_ST_OP_d,                       latches_cs_ST_OP_o);
    `REG_RST_WE(mem_latches_cs_LD_OP,                       1,   clk, rst, effective_we, cs_LD_OP_d,                       latches_cs_LD_OP_o);

    `REG_RST_WE(mem_latches_exe_cs_ST_OP,                   1,   clk, rst, effective_we, exe_cs_ST_OP_d,                   latches_exe_cs_ST_OP_o);
    `REG_RST_WE(mem_latches_exe_cs_OP_TYPE,                 6,   clk, rst, effective_we, exe_cs_OP_TYPE_d,                 latches_exe_cs_OP_TYPE_o);
    `REG_RST_WE(mem_latches_exe_cs_alu_inputA_sel,          5,   clk, rst, effective_we, exe_cs_alu_inputA_sel_d,          latches_exe_cs_alu_inputA_sel_o);
    `REG_RST_WE(mem_latches_exe_cs_alu_inputB_sel,          5,   clk, rst, effective_we, exe_cs_alu_inputB_sel_d,          latches_exe_cs_alu_inputB_sel_o);
    `REG_RST_WE(mem_latches_exe_cs_branch_target_sel,       5,   clk, rst, effective_we, exe_cs_branch_target_sel_d,       latches_exe_cs_branch_target_sel_o);
    `REG_RST_WE(mem_latches_exe_cs_shift_by_one,            1,   clk, rst, effective_we, exe_cs_shift_by_one_d,            latches_exe_cs_shift_by_one_o);
    `REG_RST_WE(mem_latches_exe_cs_br_ucond,                1,   clk, rst, effective_we, exe_cs_br_ucond_d,                latches_exe_cs_br_ucond_o);
    `REG_RST_WE(mem_latches_exe_cs_relative_branch,         1,   clk, rst, effective_we, exe_cs_relative_branch_d,         latches_exe_cs_relative_branch_o);
    `REG_RST_WE(mem_latches_exe_cs_special_br,              1,   clk, rst, effective_we, exe_cs_special_br_d,              latches_exe_cs_special_br_o);
    `REG_RST_WE(mem_latches_exe_cs_is_far,                  1,   clk, rst, effective_we, exe_cs_is_far_d,                  latches_exe_cs_is_far_o);
    `REG_RST_WE(mem_latches_exe_cs_is_call,                 1,   clk, rst, effective_we, exe_cs_is_call_d,                 latches_exe_cs_is_call_o);
    `REG_RST_WE(mem_latches_exe_cs_second_flag_needed,      1,   clk, rst, effective_we, exe_cs_second_flag_needed_d,      latches_exe_cs_second_flag_needed_o);
    `REG_RST_WE(mem_latches_exe_cs_rep_no_zf_update,        1,   clk, rst, effective_we, exe_cs_rep_no_zf_update_d,        latches_exe_cs_rep_no_zf_update_o);

    `REG_RST_WE(mem_latches_wb_cs_ST_OP,                    1,   clk, rst, effective_we, wb_cs_ST_OP_d,                    latches_wb_cs_ST_OP_o);
    `REG_RST_WE(mem_latches_wb_cs_WB_DR,                    1,   clk, rst, effective_we, wb_cs_WB_DR_d,                    latches_wb_cs_WB_DR_o);
    `REG_RST_WE(mem_latches_wb_cs_WB_SR,                    1,   clk, rst, effective_we, wb_cs_WB_SR_d,                    latches_wb_cs_WB_SR_o);
    `REG_RST_WE(mem_latches_wb_cs_WB_EAX,                   1,   clk, rst, effective_we, wb_cs_WB_EAX_d,                   latches_wb_cs_WB_EAX_o);

    `REG_RST_WE(mem_latches_br_info_valid,                  1,   clk, rst, effective_we, br_info_valid_d,                  latches_br_info_valid_o);
    `REG_RST_WE(mem_latches_br_info_br_eip,                 32,  clk, rst, effective_we, br_info_br_eip_d,                 latches_br_info_br_eip_o);
    `REG_RST_WE(mem_latches_br_info_br_xcl,                 1,   clk, rst, effective_we, br_info_br_xcl_d,                 latches_br_info_br_xcl_o);
    `REG_RST_WE(mem_latches_br_info_br_pred_taken,          1,   clk, rst, effective_we, br_info_br_pred_taken_d,          latches_br_info_br_pred_taken_o);
    `REG_RST_WE(mem_latches_br_info_speculative_target,     32,  clk, rst, effective_we, br_info_speculative_target_d,     latches_br_info_speculative_target_o);

    `REG_RST_WE(mem_latches_data_size_vec,                  4,   clk, rst, effective_we, data_size_vec_d,                  latches_data_size_vec_o);
    `REG_RST_WE(mem_latches_sr_data_size_vec,               4,   clk, rst, effective_we, sr_data_size_vec_d,               latches_sr_data_size_vec_o);
    `REG_RST_WE(mem_latches_shift_sr_up,                    1,   clk, rst, effective_we, shift_sr_up_d,                    latches_shift_sr_up_o);
    `REG_RST_WE(mem_latches_shift_sr_down,                  1,   clk, rst, effective_we, shift_sr_down_d,                  latches_shift_sr_down_o);

    `REG_RST_WE(mem_latches_ST_XCL,                         1,   clk, rst, effective_we, ST_XCL_d,                         latches_ST_XCL_o);
    `REG_RST_WE(mem_latches_ST_PADDR_0,                     15,  clk, rst, effective_we, ST_PADDR_0_d,                     latches_ST_PADDR_0_o);
    `REG_RST_WE(mem_latches_ST_PADDR_1,                     15,  clk, rst, effective_we, ST_PADDR_1_d,                     latches_ST_PADDR_1_o);
    `REG_RST_WE(mem_latches_MIO,                            1,   clk, rst, effective_we, MIO_d,                            latches_MIO_o);

    `REG_RST_WE(mem_latches_NEIP,                           32,  clk, rst, effective_we, NEIP_d,                           latches_NEIP_o);
    `REG_RST_WE(mem_latches_EIP,                            32,  clk, rst, effective_we, EIP_d,                            latches_EIP_o);
    `REG_RST_WE(mem_latches_EAX,                            32,  clk, rst, effective_we, EAX_d,                            latches_EAX_o);

    `REG_RST_WE(mem_latches_imm64,                          64,  clk, rst, effective_we, imm64_d,                          latches_imm64_o);

    `REG_RST_WE(mem_latches_sr_id,                          5,   clk, rst, effective_we, sr_id_d,                          latches_sr_id_o);
    `REG_RST_WE(mem_latches_sr_data,                        64,  clk, rst, effective_we, sr_data_d,                        latches_sr_data_o);
    `REG_RST_WE(mem_latches_dr_id,                          5,   clk, rst, effective_we, dr_id_d,                          latches_dr_id_o);
    `REG_RST_WE(mem_latches_dr_data,                        64,  clk, rst, effective_we, dr_data_d,                        latches_dr_data_o);

    `REG_RST_WE(mem_latches_LD_XCL,                         1,   clk, rst, effective_we, LD_XCL_d,                         latches_LD_XCL_o);
    `REG_RST_WE(mem_latches_swapLines,                      1,   clk, rst, effective_we, swapLines_d,                      latches_swapLines_o);
    `REG_RST_WE(mem_latches_LD_PADDR_0,                     15,  clk, rst, effective_we, LD_PADDR_0_d,                     latches_LD_PADDR_0_o);
    `REG_RST_WE(mem_latches_LD_PADDR_1,                     15,  clk, rst, effective_we, LD_PADDR_1_d,                     latches_LD_PADDR_1_o);

endmodule
