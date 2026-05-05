
module rep_controller (
    input wire clk, rst,
    input wire rep_latch,
    input wire mov_inst,
    input wire cmp_inst,
    input wire clear_zf, external_set_zf,
    input wire [31:0] ecx,
    input wire ecx_sb,
    input wire zf_flag,
    input wire stall,
    input wire flush,
    input wire exp_pipe_clear,
    input wire [`REG_ID_W-1:0] saved_segment0,
    input wire                 saved_segment_override,
    input wire [31:0]          saved_rep_eip,
    input wire [1:0]           saved_datasize,
    // rep_latches (rr_latches_general_t) unrolled
    output wire        rep_latches_valid,
    output wire        rep_latches_cs_ST_SEL,
    output wire        rep_latches_cs_MODRM_NEEDED,
    output wire        rep_latches_cs_RM_IS_DR,
    output wire        rep_latches_cs_SWITCH_LD_ADDY,
    output wire        rep_latches_cs_LD_OP,
    output wire        rep_latches_cs_ST_OP,
    output wire [`REG_ID_W-1:0] rep_latches_cs_dr_id,
    output wire [`REG_ID_W-1:0] rep_latches_cs_sr_id,
    output wire        rep_latches_cs_dr_rd,
    output wire        rep_latches_cs_sr_rd,
    output wire        rep_latches_cs_eax_rd,
    output wire        rep_latches_cs_dr_wr,
    output wire        rep_latches_cs_sr_wr,
    output wire        rep_latches_cs_eax_wr,
    output wire        rep_latches_cs_MOVS_OP,
    output wire [1:0]  rep_latches_cs_datasize,
    output wire        rep_latches_cs_will_mod_zf,
    output wire        rep_latches_cs_seg_1_valid,
    output wire [`REG_ID_W-1:0] rep_latches_cs_seg_0_id,
    output wire [`REG_ID_W-1:0] rep_latches_cs_seg_1_id,
    output wire        rep_latches_cs_special_modrm_bs,
    output wire        rep_latches_cs_special_br,
    output wire        rep_latches_dc_cs_LD_OP,
    output wire        rep_latches_dc_cs_ST_OP,
    output wire        rep_latches_dc_cs_dr_upper8,
    output wire        rep_latches_dc_cs_sr_upper8,
    output wire [1:0]  rep_latches_dc_cs_datasize,
    output wire        rep_latches_mem_cs_ST_OP,
    output wire        rep_latches_mem_cs_LD_OP,
    output wire        rep_latches_exe_cs_ST_OP,
    output wire [`EXE_OP_W-1:0] rep_latches_exe_cs_OP_TYPE,
    output wire [`SRC_SEL_W-1:0] rep_latches_exe_cs_alu_inputA_sel,
    output wire [`SRC_SEL_W-1:0] rep_latches_exe_cs_alu_inputB_sel,
    output wire [`SRC_SEL_W-1:0] rep_latches_exe_cs_branch_target_sel,
    output wire        rep_latches_exe_cs_shift_by_one,
    output wire        rep_latches_exe_cs_br_ucond,
    output wire        rep_latches_exe_cs_relative_branch,
    output wire        rep_latches_exe_cs_special_br,
    output wire        rep_latches_exe_cs_is_far,
    output wire        rep_latches_exe_cs_is_call,
    output wire        rep_latches_exe_cs_second_flag_needed,
    output wire        rep_latches_exe_cs_rep_no_zf_update,
    output wire        rep_latches_wb_cs_ST_OP,
    output wire        rep_latches_wb_cs_WB_DR,
    output wire        rep_latches_wb_cs_WB_SR,
    output wire        rep_latches_wb_cs_WB_EAX,
    output wire        rep_latches_br_info_valid,
    output wire [31:0] rep_latches_br_info_br_eip,
    output wire        rep_latches_br_info_br_xcl,
    output wire        rep_latches_br_info_br_pred_taken,
    output wire [31:0] rep_latches_br_info_speculative_target,
    output wire [31:0] rep_latches_NEIP,
    output wire [31:0] rep_latches_EIP,
    output wire [31:0] rep_latches_EAX,
    output wire [63:0] rep_latches_imm64,
    output wire [`REG_ID_W-1:0] rep_latches_sib_idx_id,
    output wire [`REG_ID_W-1:0] rep_latches_sib_base_id,
    output wire        rep_latches_sib_needed,
    output wire [7:0]  rep_latches_sib_scale,
    output wire        rep_latches_disp_needed,
    output wire        rep_latches_disp_size,
    output wire [31:0] rep_latches_displacement,
    output wire        clear_rep
);

    // --- control signals ---
    wire continue_mov, wait_mov, exit_mov;
    wire continue_cmp, wait_cmp, exit_cmp;

    // assign continue_mov = !ecx_sb && (ecx != 32'b0);
    // assign wait_mov     = ecx_sb;
    // assign exit_mov     = !ecx_sb && (ecx == 32'b0);
    wire ecx_eq0;
    wire ecx_sb_n;
    `CMP_N(u_ecx_eq0,     32, ecx_eq0,     ecx, 32'b0)
    `NOR_2(u_continue_mov, 1, continue_mov, ecx_sb, ecx_eq0)  // !ecx_sb && !ecx_eq0
    assign wait_mov = ecx_sb;
    `INV_N(u_ecx_sb_n,     1, ecx_sb,      ecx_sb_n)
    `AND_2(u_exit_mov,     1, exit_mov,     ecx_sb_n, ecx_eq0)

    wire [7:0] zf_sb_counter;

    // assign continue_cmp = (!ecx_sb && (ecx != 32'b0)) && ((zf_sb_counter == 8'b0) && zf_flag);
    // assign wait_cmp     = ecx_sb || (zf_sb_counter != 8'b0);
    // assign exit_cmp     = (!ecx_sb && (ecx == 32'b0)) || ((zf_sb_counter == 8'b0) && !zf_flag);
    wire zf_sb_eq0, zf_sb_ne0;
    wire zf_flag_n;
    wire zf_part_cmp, zf_part_exit;
    `CMP_N(u_zf_sb_eq0,    8, zf_sb_eq0,   zf_sb_counter, 8'b0)
    `INV_N(u_zf_sb_ne0,    1, zf_sb_eq0,   zf_sb_ne0)
    `INV_N(u_zf_flag_n,    1, zf_flag,      zf_flag_n)
    `AND_2(u_zf_part_cmp,  1, zf_part_cmp,  zf_sb_eq0,   zf_flag)

    `AND_2(u_continue_cmp, 1, continue_cmp, continue_mov, zf_part_cmp)

    `OR_2 (u_wait_cmp,     1, wait_cmp,     ecx_sb,       zf_sb_ne0)

    `AND_2(u_zf_part_exit, 1, zf_part_exit, zf_sb_eq0,   zf_flag_n)
    `OR_2 (u_exit_cmp,     1, exit_cmp,     exit_mov,     zf_part_exit)

    wire [2:0] rep_fsm_state_bits;
    wire [2:0] rep_cmp_fsm_state_bits;
    wire [2:0] rep_movs_fsm_state_bits;

    wire [2:0] cmp_inst_select;
    wire [2:0] movs_inst_select;
    wire [2:0] inst_select;
    // assign inst_select = cmp_inst ? cmp_inst_select : movs_inst_select;
    `MUX_2(u_inst_select, 3, inst_select, movs_inst_select, cmp_inst_select, cmp_inst)

    wire movs_clear, cmp_clear;
    wire movs_start, cmp_start;
    // assign clear_rep = cmp_inst ? cmp_clear : movs_clear;
    `MUX_2(u_clear_rep, 1, clear_rep, movs_clear, cmp_clear, cmp_inst)

    // assign fsm_reset = rst && !exp_pipe_clear && !flush;
    wire rst_n;
    wire fsm_reset;
    `INV_N(u_rst_n,     1, rst,       rst_n)
    `NOR_3(u_fsm_reset, 1, fsm_reset, rst_n, exp_pipe_clear, flush)

    // assign fsm_stall = stall || wait_cmp || wait_mov;
    wire fsm_stall;
    `OR_3(u_fsm_stall, 1, fsm_stall, stall, wait_cmp, wait_mov)

    rep_fsm fsm_rep (
        .clk           (clk),
        .rst           (fsm_reset),
        .rep_prefix_i  (rep_latch),
        .cs_mov_i      (mov_inst),
        .cs_cmp_i      (cmp_inst),
        .mov_clear_i   (movs_clear),
        .cmp_clear_i   (cmp_clear),
        .stall_i       (fsm_stall),
        .S_0           (rep_fsm_state_bits[0]),
        .S_1           (rep_fsm_state_bits[1]),
        .S_2           (rep_fsm_state_bits[2]),
        .movs_start_o  (movs_start),
        .cmp_start_o   (cmp_start)
    );
    rep_cmp_fsm cmp_fsm (
        .clk           (clk),
        .rst           (fsm_reset),
        .start_i       (cmp_start),
        .exit_mov_i    (exit_mov),
        .cont_cmp_i    (continue_cmp),
        .exit_cmp_i    (exit_cmp),
        .wait_i        (fsm_stall),
        .S_0           (rep_cmp_fsm_state_bits[0]),
        .S_1           (rep_cmp_fsm_state_bits[1]),
        .S_2           (rep_cmp_fsm_state_bits[2]),
        .clear_rep_o   (cmp_clear),
        .select_line2_o(cmp_inst_select[2]),
        .select_line1_o(cmp_inst_select[1]),
        .select_line0_o(cmp_inst_select[0])
    );
    rep_movs_fsm movs_fsm (
        .clk           (clk),
        .rst           (fsm_reset),
        .start_i       (movs_start),
        .cont_mov_i    (continue_mov),
        .wait_mov_i    (wait_mov),
        .exit_mov_i    (exit_mov),
        .stall_i       (fsm_stall),
        .S_0           (rep_movs_fsm_state_bits[0]),
        .S_1           (rep_movs_fsm_state_bits[1]),
        .S_2           (rep_movs_fsm_state_bits[2]),
        .clear_rep_o   (movs_clear),
        .select_line2_o(movs_inst_select[2]),
        .select_line1_o(movs_inst_select[1]),
        .select_line0_o(movs_inst_select[0])
    );

    // Spec:
    //   updateSB   = !stall
    //   set_zf     = external_set_zf | (rep_latches_cs_will_mod_zf & updateSB)
    //   inc_en     = set_zf & !clear_zf & updateSB
    //   dec_en     = clear_zf & (!set_zf | !updateSB)
    //   counter_we = flush | inc_en | dec_en
    //   counter_din= flush ? 0 : inc_en ? counter_inc : counter_dec
    //
    // Algebraic simplification (E=external_set_zf, M=rep_latches_cs_will_mod_zf,
    // S=stall, C=clear_zf, F=flush):
    //   set_zf & updateSB = (E | (M & ~S)) & ~S = (E | M) & ~S        := A
    //   inc_en            = A & ~C = (E | M) & ~S & ~C
    //   inc_en | dec_en   = (A & ~C) | (~A & C) = A ^ C
    //   counter_we        = F | (A ^ C)
    //
    // Build from e_or_m_n = NOR_2(E, M) so all signals are in NOR form:
    //   A          = NOR_2(e_or_m_n, S)             // (E|M) & ~S
    //   inc_en     = NOR_3(e_or_m_n, S, C)          // (E|M) & ~S & ~C
    //   counter_we = OR_2(F, XOR_2(A, C))

    // inc/dec combinational adders
    wire [7:0] counter_inc, counter_dec;
    wire       cnt_inc_cout, cnt_dec_cout;
    `ADD_N(u_cnt_inc, 8, counter_inc, cnt_inc_cout, zf_sb_counter, 8'b0,   1'b1)  // counter + 1
    `ADD_N(u_cnt_dec, 8, counter_dec, cnt_dec_cout, zf_sb_counter, 8'hFF,  1'b0)  // counter - 1

    wire e_or_m_n;
    wire A;
    wire any_change;
    wire inc_en, counter_we;
    `NOR_2(u_e_or_m_n,    1, e_or_m_n,   external_set_zf, rep_latches_cs_will_mod_zf)
    `NOR_2(u_A,           1, A,          e_or_m_n,        stall)
    `NOR_3(u_inc_en,      1, inc_en,     e_or_m_n,        stall,    clear_zf)
    `XOR_2(u_any_change,  1, any_change, A,               clear_zf)
    `OR_2 (u_counter_we,  1, counter_we, flush,           any_change)

    wire [7:0] counter_din;
    `MUX_4(u_counter_din, 8, counter_din, counter_dec, counter_inc, 8'b0, 8'b0, {flush, inc_en})

    `REG_RST_WE(u_zf_sb_counter, 8, clk, rst, counter_we, counter_din, zf_sb_counter)

    // ==================== idle_output ====================
    wire        idle_valid                      = 1'b1;
    wire        idle_cs_ST_SEL                  = 1'b0;
    wire        idle_cs_MODRM_NEEDED            = 1'b0;
    wire        idle_cs_RM_IS_DR                = 1'b0;
    wire        idle_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        idle_cs_LD_OP                   = 1'b0;
    wire        idle_cs_ST_OP                   = 1'b0;
    wire [`REG_ID_W-1:0] idle_cs_dr_id         = `REG_ID_W'b0;
    wire [`REG_ID_W-1:0] idle_cs_sr_id         = `REG_ID_W'b0;
    wire        idle_cs_dr_rd                   = 1'b0;
    wire        idle_cs_sr_rd                   = 1'b0;
    wire        idle_cs_eax_rd                  = 1'b0;
    wire        idle_cs_dr_wr                   = 1'b0;
    wire        idle_cs_sr_wr                   = 1'b0;
    wire        idle_cs_eax_wr                  = 1'b0;
    wire        idle_cs_MOVS_OP                 = 1'b0;
    wire [1:0]  idle_cs_datasize                = 2'b0;
    wire        idle_cs_will_mod_zf             = 1'b0;
    wire        idle_cs_seg_1_valid             = 1'b0;
    wire [`REG_ID_W-1:0] idle_cs_seg_0_id      = `REG_ID_W'b0;
    wire [`REG_ID_W-1:0] idle_cs_seg_1_id      = `REG_ID_W'b0;
    wire        idle_cs_special_modrm_bs        = 1'b0;
    wire        idle_cs_special_br              = 1'b0;
    wire        idle_dc_cs_LD_OP                = 1'b0;
    wire        idle_dc_cs_ST_OP                = 1'b0;
    wire        idle_dc_cs_dr_upper8            = 1'b0;
    wire        idle_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  idle_dc_cs_datasize             = 2'b0;
    wire        idle_mem_cs_ST_OP               = 1'b0;
    wire        idle_mem_cs_LD_OP               = 1'b0;
    wire        idle_exe_cs_ST_OP               = 1'b0;
    wire [`EXE_OP_W-1:0]  idle_exe_cs_OP_TYPE             = `NOP;
    wire [`SRC_SEL_W-1:0] idle_exe_cs_alu_inputA_sel      = `SRC_SEL_W'b0;
    wire [`SRC_SEL_W-1:0] idle_exe_cs_alu_inputB_sel      = `SRC_SEL_W'b0;
    wire [`SRC_SEL_W-1:0] idle_exe_cs_branch_target_sel   = `SRC_SEL_W'b0;
    wire        idle_exe_cs_shift_by_one        = 1'b0;
    wire        idle_exe_cs_br_ucond            = 1'b0;
    wire        idle_exe_cs_relative_branch     = 1'b0;
    wire        idle_exe_cs_special_br          = 1'b0;
    wire        idle_exe_cs_is_far              = 1'b0;
    wire        idle_exe_cs_is_call             = 1'b0;
    wire        idle_exe_cs_second_flag_needed  = 1'b0;
    wire        idle_exe_cs_rep_no_zf_update    = 1'b1;
    wire        idle_wb_cs_ST_OP                = 1'b0;
    wire        idle_wb_cs_WB_DR                = 1'b0;
    wire        idle_wb_cs_WB_SR                = 1'b0;
    wire        idle_wb_cs_WB_EAX               = 1'b0;
    wire        idle_br_info_valid              = 1'b0;
    wire [31:0] idle_br_info_br_eip             = 32'h0;
    wire        idle_br_info_br_xcl             = 1'b0;
    wire        idle_br_info_br_pred_taken      = 1'b0;
    wire [31:0] idle_br_info_speculative_target = 32'h0;
    wire [31:0] idle_NEIP                       = 32'h0;
    wire [31:0] idle_EIP                        = 32'h0;
    wire [31:0] idle_EAX                        = 32'h0;
    wire [63:0] idle_imm64                      = 64'h0;
    wire [`REG_ID_W-1:0] idle_sib_idx_id       = `REG_ID_W'b0;
    wire [`REG_ID_W-1:0] idle_sib_base_id      = `REG_ID_W'b0;
    wire        idle_sib_needed                 = 1'b0;
    wire [7:0]  idle_sib_scale                  = 8'h0;
    wire        idle_disp_needed                = 1'b0;
    wire        idle_disp_size                  = 1'b0;
    wire [31:0] idle_displacement               = 32'h0;

    // ==================== movs_instruction ====================
    wire        movs_valid                      = 1'b1;
    wire        movs_cs_ST_SEL                  = 1'b1;
    wire        movs_cs_MODRM_NEEDED            = 1'b0;
    wire        movs_cs_RM_IS_DR                = 1'b0;
    wire        movs_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        movs_cs_LD_OP                   = 1'b1;
    wire        movs_cs_ST_OP                   = 1'b1;
    wire [`REG_ID_W-1:0] movs_cs_dr_id         = `EDI;
    wire [`REG_ID_W-1:0] movs_cs_sr_id         = `ESI;
    wire        movs_cs_dr_rd                   = 1'b1;
    wire        movs_cs_sr_rd                   = 1'b1;
    wire        movs_cs_eax_rd                  = 1'b0;
    wire        movs_cs_dr_wr                   = 1'b1;
    wire        movs_cs_sr_wr                   = 1'b1;
    wire        movs_cs_eax_wr                  = 1'b0;
    wire        movs_cs_MOVS_OP                 = 1'b1;
    wire [1:0]  movs_cs_datasize;
    assign      movs_cs_datasize                = saved_datasize;
    wire        movs_cs_will_mod_zf             = 1'b0;
    wire        movs_cs_seg_1_valid             = 1'b1;
    wire [`REG_ID_W-1:0] movs_cs_seg_0_id;
    `MUX_2(u_movs_seg0, `REG_ID_W, movs_cs_seg_0_id, `DS, saved_segment0, saved_segment_override)
    wire [`REG_ID_W-1:0] movs_cs_seg_1_id      = `ES;
    wire        movs_cs_special_modrm_bs        = 1'b0;
    wire        movs_cs_special_br              = 1'b0;
    wire        movs_dc_cs_LD_OP                = 1'b1;
    wire        movs_dc_cs_ST_OP                = 1'b1;
    wire        movs_dc_cs_dr_upper8            = 1'b0;
    wire        movs_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  movs_dc_cs_datasize;
    assign      movs_dc_cs_datasize             = saved_datasize;
    wire        movs_mem_cs_ST_OP               = 1'b1;
    wire        movs_mem_cs_LD_OP               = 1'b1;
    wire        movs_exe_cs_ST_OP               = 1'b1;
    wire [`EXE_OP_W-1:0]  movs_exe_cs_OP_TYPE             = `MOVS;
    wire [`SRC_SEL_W-1:0] movs_exe_cs_alu_inputA_sel      = `SR_DR_SEL;
    wire [`SRC_SEL_W-1:0] movs_exe_cs_alu_inputB_sel      = `BUFFER;
    wire [`SRC_SEL_W-1:0] movs_exe_cs_branch_target_sel   = `NO_EXE;
    wire        movs_exe_cs_shift_by_one        = 1'b0;
    wire        movs_exe_cs_br_ucond            = 1'b0;
    wire        movs_exe_cs_relative_branch     = 1'b0;
    wire        movs_exe_cs_special_br          = 1'b0;
    wire        movs_exe_cs_is_far              = 1'b0;
    wire        movs_exe_cs_is_call             = 1'b0;
    wire        movs_exe_cs_second_flag_needed  = 1'b0;
    wire        movs_exe_cs_rep_no_zf_update    = 1'b1;
    wire        movs_wb_cs_ST_OP                = 1'b1;
    wire        movs_wb_cs_WB_DR                = 1'b1;
    wire        movs_wb_cs_WB_SR                = 1'b1;
    wire        movs_wb_cs_WB_EAX               = 1'b0;
    wire        movs_br_info_valid              = 1'b0;
    wire [31:0] movs_br_info_br_eip             = 32'h0;
    wire        movs_br_info_br_xcl             = 1'b0;
    wire        movs_br_info_br_pred_taken      = 1'b0;
    wire [31:0] movs_br_info_speculative_target = 32'h0;
    wire [31:0] movs_NEIP                       = 32'h0;
    wire [31:0] movs_EIP;
    assign      movs_EIP                        = saved_rep_eip;
    wire [31:0] movs_EAX                        = 32'h0;
    wire [63:0] movs_imm64                      = 64'h0;
    wire [`REG_ID_W-1:0] movs_sib_idx_id       = `NO_REG;
    wire [`REG_ID_W-1:0] movs_sib_base_id      = `NO_REG;
    wire        movs_sib_needed                 = 1'b0;
    wire [7:0]  movs_sib_scale                  = 8'h0;
    wire        movs_disp_needed                = 1'b0;
    wire        movs_disp_size                  = 1'b0;
    wire [31:0] movs_displacement               = 32'h0;

    // ==================== dec_ecx ====================
    wire        decx_valid                      = 1'b1;
    wire        decx_cs_ST_SEL                  = 1'b0;
    wire        decx_cs_MODRM_NEEDED            = 1'b1;
    wire        decx_cs_RM_IS_DR                = 1'b1;
    wire        decx_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        decx_cs_LD_OP                   = 1'b0;
    wire        decx_cs_ST_OP                   = 1'b0;
    wire [`REG_ID_W-1:0] decx_cs_dr_id         = `ECX;
    wire [`REG_ID_W-1:0] decx_cs_sr_id         = `NO_REG;
    wire        decx_cs_dr_rd                   = 1'b1;
    wire        decx_cs_sr_rd                   = 1'b0;
    wire        decx_cs_eax_rd                  = 1'b0;
    wire        decx_cs_dr_wr                   = 1'b1;
    wire        decx_cs_sr_wr                   = 1'b0;
    wire        decx_cs_eax_wr                  = 1'b0;
    wire        decx_cs_MOVS_OP                 = 1'b0;
    wire [1:0]  decx_cs_datasize;
    assign      decx_cs_datasize                = saved_datasize;
    wire        decx_cs_will_mod_zf             = 1'b0;
    wire        decx_cs_seg_1_valid             = 1'b0;
    wire [`REG_ID_W-1:0] decx_cs_seg_0_id      = `DS;
    wire [`REG_ID_W-1:0] decx_cs_seg_1_id      = `DS;
    wire        decx_cs_special_modrm_bs        = 1'b0;
    wire        decx_cs_special_br              = 1'b0;
    wire        decx_dc_cs_LD_OP                = 1'b0;
    wire        decx_dc_cs_ST_OP                = 1'b0;
    wire        decx_dc_cs_dr_upper8            = 1'b0;
    wire        decx_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  decx_dc_cs_datasize;
    assign      decx_dc_cs_datasize             = saved_datasize;
    wire        decx_mem_cs_ST_OP               = 1'b0;
    wire        decx_mem_cs_LD_OP               = 1'b0;
    wire        decx_exe_cs_ST_OP               = 1'b0;
    wire [`EXE_OP_W-1:0]  decx_exe_cs_OP_TYPE             = `ADD;
    wire [`SRC_SEL_W-1:0] decx_exe_cs_alu_inputA_sel      = `DR_REGISTER;
    wire [`SRC_SEL_W-1:0] decx_exe_cs_alu_inputB_sel      = `SEXT8;
    wire [`SRC_SEL_W-1:0] decx_exe_cs_branch_target_sel   = `NO_EXE;
    wire        decx_exe_cs_shift_by_one        = 1'b0;
    wire        decx_exe_cs_br_ucond            = 1'b0;
    wire        decx_exe_cs_relative_branch     = 1'b0;
    wire        decx_exe_cs_special_br          = 1'b0;
    wire        decx_exe_cs_is_far              = 1'b0;
    wire        decx_exe_cs_is_call             = 1'b0;
    wire        decx_exe_cs_second_flag_needed  = 1'b0;
    wire        decx_exe_cs_rep_no_zf_update    = 1'b1;
    wire        decx_wb_cs_ST_OP                = 1'b0;
    wire        decx_wb_cs_WB_DR                = 1'b1;
    wire        decx_wb_cs_WB_SR                = 1'b0;
    wire        decx_wb_cs_WB_EAX               = 1'b0;
    wire        decx_br_info_valid              = 1'b0;
    wire [31:0] decx_br_info_br_eip             = 32'h0;
    wire        decx_br_info_br_xcl             = 1'b0;
    wire        decx_br_info_br_pred_taken      = 1'b0;
    wire [31:0] decx_br_info_speculative_target = 32'h0;
    wire [31:0] decx_NEIP                       = 32'h0;
    wire [31:0] decx_EIP;
    assign      decx_EIP                        = saved_rep_eip;
    wire [31:0] decx_EAX                        = 32'h0;
    wire [63:0] decx_imm64                      = 64'hff;
    wire [`REG_ID_W-1:0] decx_sib_idx_id       = `NO_REG;
    wire [`REG_ID_W-1:0] decx_sib_base_id      = `NO_REG;
    wire        decx_sib_needed                 = 1'b0;
    wire [7:0]  decx_sib_scale                  = 8'h0;
    wire        decx_disp_needed                = 1'b0;
    wire        decx_disp_size                  = 1'b0;
    wire [31:0] decx_displacement               = 32'h0;

    // ==================== cmp0 : mov ds:(%esi), %etr ====================
    wire        cmp0_valid                      = 1'b1;
    wire        cmp0_cs_ST_SEL                  = 1'b0;
    wire        cmp0_cs_MODRM_NEEDED            = 1'b1;
    wire        cmp0_cs_RM_IS_DR                = 1'b0;
    wire        cmp0_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        cmp0_cs_LD_OP                   = 1'b1;
    wire        cmp0_cs_ST_OP                   = 1'b0;
    wire [`REG_ID_W-1:0] cmp0_cs_dr_id         = `ETR;
    wire [`REG_ID_W-1:0] cmp0_cs_sr_id         = `ESI;
    wire        cmp0_cs_dr_rd                   = 1'b1;
    wire        cmp0_cs_sr_rd                   = 1'b1;
    wire        cmp0_cs_eax_rd                  = 1'b0;
    wire        cmp0_cs_dr_wr                   = 1'b1;
    wire        cmp0_cs_sr_wr                   = 1'b0;
    wire        cmp0_cs_eax_wr                  = 1'b0;
    wire        cmp0_cs_MOVS_OP                 = 1'b0;
    wire [1:0]  cmp0_cs_datasize;
    assign      cmp0_cs_datasize                = saved_datasize;
    wire        cmp0_cs_will_mod_zf             = 1'b0;
    wire        cmp0_cs_seg_1_valid             = 1'b0;
    wire [`REG_ID_W-1:0] cmp0_cs_seg_0_id;
    `MUX_2(u_cmp0_seg0, `REG_ID_W, cmp0_cs_seg_0_id, `DS, saved_segment0, saved_segment_override)
    wire [`REG_ID_W-1:0] cmp0_cs_seg_1_id      = `DS;
    wire        cmp0_cs_special_modrm_bs        = 1'b0;
    wire        cmp0_cs_special_br              = 1'b0;
    wire        cmp0_dc_cs_LD_OP                = 1'b1;
    wire        cmp0_dc_cs_ST_OP                = 1'b0;
    wire        cmp0_dc_cs_dr_upper8            = 1'b0;
    wire        cmp0_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  cmp0_dc_cs_datasize;
    assign      cmp0_dc_cs_datasize             = saved_datasize;
    wire        cmp0_mem_cs_ST_OP               = 1'b0;
    wire        cmp0_mem_cs_LD_OP               = 1'b1;
    wire        cmp0_exe_cs_ST_OP               = 1'b0;
    wire [`EXE_OP_W-1:0]  cmp0_exe_cs_OP_TYPE             = `MOV;
    wire [`SRC_SEL_W-1:0] cmp0_exe_cs_alu_inputA_sel      = `DR_REGISTER;
    wire [`SRC_SEL_W-1:0] cmp0_exe_cs_alu_inputB_sel      = `BUFFER;
    wire [`SRC_SEL_W-1:0] cmp0_exe_cs_branch_target_sel   = `NO_EXE;
    wire        cmp0_exe_cs_shift_by_one        = 1'b0;
    wire        cmp0_exe_cs_br_ucond            = 1'b0;
    wire        cmp0_exe_cs_relative_branch     = 1'b0;
    wire        cmp0_exe_cs_special_br          = 1'b0;
    wire        cmp0_exe_cs_is_far              = 1'b0;
    wire        cmp0_exe_cs_is_call             = 1'b0;
    wire        cmp0_exe_cs_second_flag_needed  = 1'b0;
    wire        cmp0_exe_cs_rep_no_zf_update    = 1'b0;
    wire        cmp0_wb_cs_ST_OP                = 1'b0;
    wire        cmp0_wb_cs_WB_DR                = 1'b1;
    wire        cmp0_wb_cs_WB_SR                = 1'b0;
    wire        cmp0_wb_cs_WB_EAX               = 1'b0;
    wire        cmp0_br_info_valid              = 1'b0;
    wire [31:0] cmp0_br_info_br_eip             = 32'h0;
    wire        cmp0_br_info_br_xcl             = 1'b0;
    wire        cmp0_br_info_br_pred_taken      = 1'b0;
    wire [31:0] cmp0_br_info_speculative_target = 32'h0;
    wire [31:0] cmp0_NEIP                       = 32'h0;
    wire [31:0] cmp0_EIP;
    assign      cmp0_EIP                        = saved_rep_eip;
    wire [31:0] cmp0_EAX                        = 32'h0;
    wire [63:0] cmp0_imm64                      = 64'h0;
    wire [`REG_ID_W-1:0] cmp0_sib_idx_id       = `NO_REG;
    wire [`REG_ID_W-1:0] cmp0_sib_base_id      = `NO_REG;
    wire        cmp0_sib_needed                 = 1'b0;
    wire [7:0]  cmp0_sib_scale                  = 8'h0;
    wire        cmp0_disp_needed                = 1'b0;
    wire        cmp0_disp_size                  = 1'b0;
    wire [31:0] cmp0_displacement               = 32'h0;

    // ==================== cmp1 : add es:(%edi), %etr ====================
    wire        cmp1_valid                      = 1'b1;
    wire        cmp1_cs_ST_SEL                  = 1'b0;
    wire        cmp1_cs_MODRM_NEEDED            = 1'b1;
    wire        cmp1_cs_RM_IS_DR                = 1'b0;
    wire        cmp1_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        cmp1_cs_LD_OP                   = 1'b1;
    wire        cmp1_cs_ST_OP                   = 1'b0;
    wire [`REG_ID_W-1:0] cmp1_cs_dr_id         = `ETR;
    wire [`REG_ID_W-1:0] cmp1_cs_sr_id         = `EDI;
    wire        cmp1_cs_dr_rd                   = 1'b1;
    wire        cmp1_cs_sr_rd                   = 1'b1;
    wire        cmp1_cs_eax_rd                  = 1'b0;
    wire        cmp1_cs_dr_wr                   = 1'b1;
    wire        cmp1_cs_sr_wr                   = 1'b0;
    wire        cmp1_cs_eax_wr                  = 1'b0;
    wire        cmp1_cs_MOVS_OP                 = 1'b0;
    wire [1:0]  cmp1_cs_datasize;
    assign      cmp1_cs_datasize                = saved_datasize;
    wire        cmp1_cs_will_mod_zf             = 1'b1;
    wire        cmp1_cs_seg_1_valid             = 1'b0;
    wire [`REG_ID_W-1:0] cmp1_cs_seg_0_id      = `ES;
    wire [`REG_ID_W-1:0] cmp1_cs_seg_1_id      = `DS;
    wire        cmp1_cs_special_modrm_bs        = 1'b0;
    wire        cmp1_cs_special_br              = 1'b0;
    wire        cmp1_dc_cs_LD_OP                = 1'b1;
    wire        cmp1_dc_cs_ST_OP                = 1'b0;
    wire        cmp1_dc_cs_dr_upper8            = 1'b0;
    wire        cmp1_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  cmp1_dc_cs_datasize;
    assign      cmp1_dc_cs_datasize             = saved_datasize;
    wire        cmp1_mem_cs_ST_OP               = 1'b0;
    wire        cmp1_mem_cs_LD_OP               = 1'b1;
    wire        cmp1_exe_cs_ST_OP               = 1'b0;
    wire [`EXE_OP_W-1:0]  cmp1_exe_cs_OP_TYPE             = `REP_CMP;
    wire [`SRC_SEL_W-1:0] cmp1_exe_cs_alu_inputA_sel      = `DR_REGISTER;
    wire [`SRC_SEL_W-1:0] cmp1_exe_cs_alu_inputB_sel      = `BUFFER;
    wire [`SRC_SEL_W-1:0] cmp1_exe_cs_branch_target_sel   = `NO_EXE;
    wire        cmp1_exe_cs_shift_by_one        = 1'b0;
    wire        cmp1_exe_cs_br_ucond            = 1'b0;
    wire        cmp1_exe_cs_relative_branch     = 1'b0;
    wire        cmp1_exe_cs_special_br          = 1'b0;
    wire        cmp1_exe_cs_is_far              = 1'b0;
    wire        cmp1_exe_cs_is_call             = 1'b0;
    wire        cmp1_exe_cs_second_flag_needed  = 1'b0;
    wire        cmp1_exe_cs_rep_no_zf_update    = 1'b0;
    wire        cmp1_wb_cs_ST_OP                = 1'b0;
    wire        cmp1_wb_cs_WB_DR                = 1'b1;
    wire        cmp1_wb_cs_WB_SR                = 1'b0;
    wire        cmp1_wb_cs_WB_EAX               = 1'b0;
    wire        cmp1_br_info_valid              = 1'b0;
    wire [31:0] cmp1_br_info_br_eip             = 32'h0;
    wire        cmp1_br_info_br_xcl             = 1'b0;
    wire        cmp1_br_info_br_pred_taken      = 1'b0;
    wire [31:0] cmp1_br_info_speculative_target = 32'h0;
    wire [31:0] cmp1_NEIP                       = 32'h0;
    wire [31:0] cmp1_EIP;
    assign      cmp1_EIP                        = saved_rep_eip;
    wire [31:0] cmp1_EAX                        = 32'h0;
    wire [63:0] cmp1_imm64                      = 64'h0;
    wire [`REG_ID_W-1:0] cmp1_sib_idx_id       = `NO_REG;
    wire [`REG_ID_W-1:0] cmp1_sib_base_id      = `NO_REG;
    wire        cmp1_sib_needed                 = 1'b0;
    wire [7:0]  cmp1_sib_scale                  = 8'h0;
    wire        cmp1_disp_needed                = 1'b0;
    wire        cmp1_disp_size                  = 1'b0;
    wire [31:0] cmp1_displacement               = 32'h0;

    // ==================== cmp2 : add_df %edi, %esi ====================
    wire        cmp2_valid                      = 1'b1;
    wire        cmp2_cs_ST_SEL                  = 1'b0;
    wire        cmp2_cs_MODRM_NEEDED            = 1'b1;
    wire        cmp2_cs_RM_IS_DR                = 1'b1;
    wire        cmp2_cs_SWITCH_LD_ADDY          = 1'b0;
    wire        cmp2_cs_LD_OP                   = 1'b0;
    wire        cmp2_cs_ST_OP                   = 1'b0;
    wire [`REG_ID_W-1:0] cmp2_cs_dr_id         = `ESI;
    wire [`REG_ID_W-1:0] cmp2_cs_sr_id         = `EDI;
    wire        cmp2_cs_dr_rd                   = 1'b1;
    wire        cmp2_cs_sr_rd                   = 1'b1;
    wire        cmp2_cs_eax_rd                  = 1'b0;
    wire        cmp2_cs_dr_wr                   = 1'b1;
    wire        cmp2_cs_sr_wr                   = 1'b1;
    wire        cmp2_cs_eax_wr                  = 1'b0;
    wire        cmp2_cs_MOVS_OP                 = 1'b0;
    wire [1:0]  cmp2_cs_datasize;
    assign      cmp2_cs_datasize                = saved_datasize;
    wire        cmp2_cs_will_mod_zf             = 1'b0;
    wire        cmp2_cs_seg_1_valid             = 1'b0;
    wire [`REG_ID_W-1:0] cmp2_cs_seg_0_id      = `DS;
    wire [`REG_ID_W-1:0] cmp2_cs_seg_1_id      = `DS;
    wire        cmp2_cs_special_modrm_bs        = 1'b0;
    wire        cmp2_cs_special_br              = 1'b0;
    wire        cmp2_dc_cs_LD_OP                = 1'b1;
    wire        cmp2_dc_cs_ST_OP                = 1'b0;
    wire        cmp2_dc_cs_dr_upper8            = 1'b0;
    wire        cmp2_dc_cs_sr_upper8            = 1'b0;
    wire [1:0]  cmp2_dc_cs_datasize;
    assign      cmp2_dc_cs_datasize             = saved_datasize;
    wire        cmp2_mem_cs_ST_OP               = 1'b0;
    wire        cmp2_mem_cs_LD_OP               = 1'b1;
    wire        cmp2_exe_cs_ST_OP               = 1'b0;
    wire [`EXE_OP_W-1:0]  cmp2_exe_cs_OP_TYPE             = `ADD_DF;
    wire [`SRC_SEL_W-1:0] cmp2_exe_cs_alu_inputA_sel      = `DR_REGISTER;
    wire [`SRC_SEL_W-1:0] cmp2_exe_cs_alu_inputB_sel      = `SR_REGISTER;
    wire [`SRC_SEL_W-1:0] cmp2_exe_cs_branch_target_sel   = `NO_EXE;
    wire        cmp2_exe_cs_shift_by_one        = 1'b0;
    wire        cmp2_exe_cs_br_ucond            = 1'b0;
    wire        cmp2_exe_cs_relative_branch     = 1'b0;
    wire        cmp2_exe_cs_special_br          = 1'b0;
    wire        cmp2_exe_cs_is_far              = 1'b0;
    wire        cmp2_exe_cs_is_call             = 1'b0;
    wire        cmp2_exe_cs_second_flag_needed  = 1'b0;
    wire        cmp2_exe_cs_rep_no_zf_update    = 1'b0;
    wire        cmp2_wb_cs_ST_OP                = 1'b0;
    wire        cmp2_wb_cs_WB_DR                = 1'b1;
    wire        cmp2_wb_cs_WB_SR                = 1'b1;
    wire        cmp2_wb_cs_WB_EAX               = 1'b0;
    wire        cmp2_br_info_valid              = 1'b0;
    wire [31:0] cmp2_br_info_br_eip             = 32'h0;
    wire        cmp2_br_info_br_xcl             = 1'b0;
    wire        cmp2_br_info_br_pred_taken      = 1'b0;
    wire [31:0] cmp2_br_info_speculative_target = 32'h0;
    wire [31:0] cmp2_NEIP                       = 32'h0;
    wire [31:0] cmp2_EIP;
    assign      cmp2_EIP                        = saved_rep_eip;
    wire [31:0] cmp2_EAX                        = 32'h0;
    wire [63:0] cmp2_imm64                      = 64'h0;
    wire [`REG_ID_W-1:0] cmp2_sib_idx_id       = `NO_REG;
    wire [`REG_ID_W-1:0] cmp2_sib_base_id      = `NO_REG;
    wire        cmp2_sib_needed                 = 1'b0;
    wire [7:0]  cmp2_sib_scale                  = 8'h0;
    wire        cmp2_disp_needed                = 1'b0;
    wire        cmp2_disp_size                  = 1'b0;
    wire [31:0] cmp2_displacement               = 32'h0;

    // ==================== output mux ====================
    // sel: inst_select[2:0]
    // in0=idle  in1=movs  in2=decx  in3=cmp0  in4=cmp1  in5=cmp2  in6,in7=idle(unused)

    `MUX_8(u_mux_valid,          1,             rep_latches_valid,                    idle_valid,             movs_valid,             decx_valid,             cmp0_valid,             cmp1_valid,             cmp2_valid,             idle_valid,             idle_valid,             inst_select)
    `MUX_8(u_mux_cs_ST_SEL,      1,             rep_latches_cs_ST_SEL,                idle_cs_ST_SEL,         movs_cs_ST_SEL,         decx_cs_ST_SEL,         cmp0_cs_ST_SEL,         cmp1_cs_ST_SEL,         cmp2_cs_ST_SEL,         idle_cs_ST_SEL,         idle_cs_ST_SEL,         inst_select)
    `MUX_8(u_mux_cs_MODRM,       1,             rep_latches_cs_MODRM_NEEDED,          idle_cs_MODRM_NEEDED,   movs_cs_MODRM_NEEDED,   decx_cs_MODRM_NEEDED,   cmp0_cs_MODRM_NEEDED,   cmp1_cs_MODRM_NEEDED,   cmp2_cs_MODRM_NEEDED,   idle_cs_MODRM_NEEDED,   idle_cs_MODRM_NEEDED,   inst_select)
    `MUX_8(u_mux_cs_RM_IS_DR,    1,             rep_latches_cs_RM_IS_DR,              idle_cs_RM_IS_DR,       movs_cs_RM_IS_DR,       decx_cs_RM_IS_DR,       cmp0_cs_RM_IS_DR,       cmp1_cs_RM_IS_DR,       cmp2_cs_RM_IS_DR,       idle_cs_RM_IS_DR,       idle_cs_RM_IS_DR,       inst_select)
    `MUX_8(u_mux_cs_SWITCH_LD,   1,             rep_latches_cs_SWITCH_LD_ADDY,        idle_cs_SWITCH_LD_ADDY, movs_cs_SWITCH_LD_ADDY, decx_cs_SWITCH_LD_ADDY, cmp0_cs_SWITCH_LD_ADDY, cmp1_cs_SWITCH_LD_ADDY, cmp2_cs_SWITCH_LD_ADDY, idle_cs_SWITCH_LD_ADDY, idle_cs_SWITCH_LD_ADDY, inst_select)
    `MUX_8(u_mux_cs_LD_OP,       1,             rep_latches_cs_LD_OP,                 idle_cs_LD_OP,          movs_cs_LD_OP,          decx_cs_LD_OP,          cmp0_cs_LD_OP,          cmp1_cs_LD_OP,          cmp2_cs_LD_OP,          idle_cs_LD_OP,          idle_cs_LD_OP,          inst_select)
    `MUX_8(u_mux_cs_ST_OP,       1,             rep_latches_cs_ST_OP,                 idle_cs_ST_OP,          movs_cs_ST_OP,          decx_cs_ST_OP,          cmp0_cs_ST_OP,          cmp1_cs_ST_OP,          cmp2_cs_ST_OP,          idle_cs_ST_OP,          idle_cs_ST_OP,          inst_select)
    `MUX_8(u_mux_cs_dr_id,       `REG_ID_W,     rep_latches_cs_dr_id,                 idle_cs_dr_id,          movs_cs_dr_id,          decx_cs_dr_id,          cmp0_cs_dr_id,          cmp1_cs_dr_id,          cmp2_cs_dr_id,          idle_cs_dr_id,          idle_cs_dr_id,          inst_select)
    `MUX_8(u_mux_cs_sr_id,       `REG_ID_W,     rep_latches_cs_sr_id,                 idle_cs_sr_id,          movs_cs_sr_id,          decx_cs_sr_id,          cmp0_cs_sr_id,          cmp1_cs_sr_id,          cmp2_cs_sr_id,          idle_cs_sr_id,          idle_cs_sr_id,          inst_select)
    `MUX_8(u_mux_cs_dr_rd,       1,             rep_latches_cs_dr_rd,                 idle_cs_dr_rd,          movs_cs_dr_rd,          decx_cs_dr_rd,          cmp0_cs_dr_rd,          cmp1_cs_dr_rd,          cmp2_cs_dr_rd,          idle_cs_dr_rd,          idle_cs_dr_rd,          inst_select)
    `MUX_8(u_mux_cs_sr_rd,       1,             rep_latches_cs_sr_rd,                 idle_cs_sr_rd,          movs_cs_sr_rd,          decx_cs_sr_rd,          cmp0_cs_sr_rd,          cmp1_cs_sr_rd,          cmp2_cs_sr_rd,          idle_cs_sr_rd,          idle_cs_sr_rd,          inst_select)
    `MUX_8(u_mux_cs_eax_rd,      1,             rep_latches_cs_eax_rd,                idle_cs_eax_rd,         movs_cs_eax_rd,         decx_cs_eax_rd,         cmp0_cs_eax_rd,         cmp1_cs_eax_rd,         cmp2_cs_eax_rd,         idle_cs_eax_rd,         idle_cs_eax_rd,         inst_select)
    `MUX_8(u_mux_cs_dr_wr,       1,             rep_latches_cs_dr_wr,                 idle_cs_dr_wr,          movs_cs_dr_wr,          decx_cs_dr_wr,          cmp0_cs_dr_wr,          cmp1_cs_dr_wr,          cmp2_cs_dr_wr,          idle_cs_dr_wr,          idle_cs_dr_wr,          inst_select)
    `MUX_8(u_mux_cs_sr_wr,       1,             rep_latches_cs_sr_wr,                 idle_cs_sr_wr,          movs_cs_sr_wr,          decx_cs_sr_wr,          cmp0_cs_sr_wr,          cmp1_cs_sr_wr,          cmp2_cs_sr_wr,          idle_cs_sr_wr,          idle_cs_sr_wr,          inst_select)
    `MUX_8(u_mux_cs_eax_wr,      1,             rep_latches_cs_eax_wr,                idle_cs_eax_wr,         movs_cs_eax_wr,         decx_cs_eax_wr,         cmp0_cs_eax_wr,         cmp1_cs_eax_wr,         cmp2_cs_eax_wr,         idle_cs_eax_wr,         idle_cs_eax_wr,         inst_select)
    `MUX_8(u_mux_cs_MOVS_OP,     1,             rep_latches_cs_MOVS_OP,               idle_cs_MOVS_OP,        movs_cs_MOVS_OP,        decx_cs_MOVS_OP,        cmp0_cs_MOVS_OP,        cmp1_cs_MOVS_OP,        cmp2_cs_MOVS_OP,        idle_cs_MOVS_OP,        idle_cs_MOVS_OP,        inst_select)
    `MUX_8(u_mux_cs_datasize,    2,             rep_latches_cs_datasize,              idle_cs_datasize,       movs_cs_datasize,       decx_cs_datasize,       cmp0_cs_datasize,       cmp1_cs_datasize,       cmp2_cs_datasize,       idle_cs_datasize,       idle_cs_datasize,       inst_select)
    `MUX_8(u_mux_cs_will_mod_zf, 1,             rep_latches_cs_will_mod_zf,           idle_cs_will_mod_zf,    movs_cs_will_mod_zf,    decx_cs_will_mod_zf,    cmp0_cs_will_mod_zf,    cmp1_cs_will_mod_zf,    cmp2_cs_will_mod_zf,    idle_cs_will_mod_zf,    idle_cs_will_mod_zf,    inst_select)
    `MUX_8(u_mux_cs_seg1_valid,  1,             rep_latches_cs_seg_1_valid,           idle_cs_seg_1_valid,    movs_cs_seg_1_valid,    decx_cs_seg_1_valid,    cmp0_cs_seg_1_valid,    cmp1_cs_seg_1_valid,    cmp2_cs_seg_1_valid,    idle_cs_seg_1_valid,    idle_cs_seg_1_valid,    inst_select)
    `MUX_8(u_mux_cs_seg0_id,     `REG_ID_W,     rep_latches_cs_seg_0_id,              idle_cs_seg_0_id,       movs_cs_seg_0_id,       decx_cs_seg_0_id,       cmp0_cs_seg_0_id,       cmp1_cs_seg_0_id,       cmp2_cs_seg_0_id,       idle_cs_seg_0_id,       idle_cs_seg_0_id,       inst_select)
    `MUX_8(u_mux_cs_seg1_id,     `REG_ID_W,     rep_latches_cs_seg_1_id,              idle_cs_seg_1_id,       movs_cs_seg_1_id,       decx_cs_seg_1_id,       cmp0_cs_seg_1_id,       cmp1_cs_seg_1_id,       cmp2_cs_seg_1_id,       idle_cs_seg_1_id,       idle_cs_seg_1_id,       inst_select)
    `MUX_8(u_mux_cs_sp_modrm,    1,             rep_latches_cs_special_modrm_bs,      idle_cs_special_modrm_bs, movs_cs_special_modrm_bs, decx_cs_special_modrm_bs, cmp0_cs_special_modrm_bs, cmp1_cs_special_modrm_bs, cmp2_cs_special_modrm_bs, idle_cs_special_modrm_bs, idle_cs_special_modrm_bs, inst_select)
    `MUX_8(u_mux_cs_sp_br,       1,             rep_latches_cs_special_br,            idle_cs_special_br,     movs_cs_special_br,     decx_cs_special_br,     cmp0_cs_special_br,     cmp1_cs_special_br,     cmp2_cs_special_br,     idle_cs_special_br,     idle_cs_special_br,     inst_select)
    `MUX_8(u_mux_dc_LD_OP,       1,             rep_latches_dc_cs_LD_OP,              idle_dc_cs_LD_OP,       movs_dc_cs_LD_OP,       decx_dc_cs_LD_OP,       cmp0_dc_cs_LD_OP,       cmp1_dc_cs_LD_OP,       cmp2_dc_cs_LD_OP,       idle_dc_cs_LD_OP,       idle_dc_cs_LD_OP,       inst_select)
    `MUX_8(u_mux_dc_ST_OP,       1,             rep_latches_dc_cs_ST_OP,              idle_dc_cs_ST_OP,       movs_dc_cs_ST_OP,       decx_dc_cs_ST_OP,       cmp0_dc_cs_ST_OP,       cmp1_dc_cs_ST_OP,       cmp2_dc_cs_ST_OP,       idle_dc_cs_ST_OP,       idle_dc_cs_ST_OP,       inst_select)
    `MUX_8(u_mux_dc_dr_upper8,   1,             rep_latches_dc_cs_dr_upper8,          idle_dc_cs_dr_upper8,   movs_dc_cs_dr_upper8,   decx_dc_cs_dr_upper8,   cmp0_dc_cs_dr_upper8,   cmp1_dc_cs_dr_upper8,   cmp2_dc_cs_dr_upper8,   idle_dc_cs_dr_upper8,   idle_dc_cs_dr_upper8,   inst_select)
    `MUX_8(u_mux_dc_sr_upper8,   1,             rep_latches_dc_cs_sr_upper8,          idle_dc_cs_sr_upper8,   movs_dc_cs_sr_upper8,   decx_dc_cs_sr_upper8,   cmp0_dc_cs_sr_upper8,   cmp1_dc_cs_sr_upper8,   cmp2_dc_cs_sr_upper8,   idle_dc_cs_sr_upper8,   idle_dc_cs_sr_upper8,   inst_select)
    `MUX_8(u_mux_dc_datasize,    2,             rep_latches_dc_cs_datasize,           idle_dc_cs_datasize,    movs_dc_cs_datasize,    decx_dc_cs_datasize,    cmp0_dc_cs_datasize,    cmp1_dc_cs_datasize,    cmp2_dc_cs_datasize,    idle_dc_cs_datasize,    idle_dc_cs_datasize,    inst_select)
    `MUX_8(u_mux_mem_ST_OP,      1,             rep_latches_mem_cs_ST_OP,             idle_mem_cs_ST_OP,      movs_mem_cs_ST_OP,      decx_mem_cs_ST_OP,      cmp0_mem_cs_ST_OP,      cmp1_mem_cs_ST_OP,      cmp2_mem_cs_ST_OP,      idle_mem_cs_ST_OP,      idle_mem_cs_ST_OP,      inst_select)
    `MUX_8(u_mux_mem_LD_OP,      1,             rep_latches_mem_cs_LD_OP,             idle_mem_cs_LD_OP,      movs_mem_cs_LD_OP,      decx_mem_cs_LD_OP,      cmp0_mem_cs_LD_OP,      cmp1_mem_cs_LD_OP,      cmp2_mem_cs_LD_OP,      idle_mem_cs_LD_OP,      idle_mem_cs_LD_OP,      inst_select)
    `MUX_8(u_mux_exe_ST_OP,      1,             rep_latches_exe_cs_ST_OP,             idle_exe_cs_ST_OP,      movs_exe_cs_ST_OP,      decx_exe_cs_ST_OP,      cmp0_exe_cs_ST_OP,      cmp1_exe_cs_ST_OP,      cmp2_exe_cs_ST_OP,      idle_exe_cs_ST_OP,      idle_exe_cs_ST_OP,      inst_select)
    `MUX_8(u_mux_exe_OP_TYPE,    `EXE_OP_W,     rep_latches_exe_cs_OP_TYPE,           idle_exe_cs_OP_TYPE,    movs_exe_cs_OP_TYPE,    decx_exe_cs_OP_TYPE,    cmp0_exe_cs_OP_TYPE,    cmp1_exe_cs_OP_TYPE,    cmp2_exe_cs_OP_TYPE,    idle_exe_cs_OP_TYPE,    idle_exe_cs_OP_TYPE,    inst_select)
    `MUX_8(u_mux_exe_inA,        `SRC_SEL_W,    rep_latches_exe_cs_alu_inputA_sel,    idle_exe_cs_alu_inputA_sel,  movs_exe_cs_alu_inputA_sel,  decx_exe_cs_alu_inputA_sel,  cmp0_exe_cs_alu_inputA_sel,  cmp1_exe_cs_alu_inputA_sel,  cmp2_exe_cs_alu_inputA_sel,  idle_exe_cs_alu_inputA_sel,  idle_exe_cs_alu_inputA_sel,  inst_select)
    `MUX_8(u_mux_exe_inB,        `SRC_SEL_W,    rep_latches_exe_cs_alu_inputB_sel,    idle_exe_cs_alu_inputB_sel,  movs_exe_cs_alu_inputB_sel,  decx_exe_cs_alu_inputB_sel,  cmp0_exe_cs_alu_inputB_sel,  cmp1_exe_cs_alu_inputB_sel,  cmp2_exe_cs_alu_inputB_sel,  idle_exe_cs_alu_inputB_sel,  idle_exe_cs_alu_inputB_sel,  inst_select)
    `MUX_8(u_mux_exe_br_tgt,     `SRC_SEL_W,    rep_latches_exe_cs_branch_target_sel, idle_exe_cs_branch_target_sel, movs_exe_cs_branch_target_sel, decx_exe_cs_branch_target_sel, cmp0_exe_cs_branch_target_sel, cmp1_exe_cs_branch_target_sel, cmp2_exe_cs_branch_target_sel, idle_exe_cs_branch_target_sel, idle_exe_cs_branch_target_sel, inst_select)
    `MUX_8(u_mux_exe_shby1,      1,             rep_latches_exe_cs_shift_by_one,      idle_exe_cs_shift_by_one,    movs_exe_cs_shift_by_one,    decx_exe_cs_shift_by_one,    cmp0_exe_cs_shift_by_one,    cmp1_exe_cs_shift_by_one,    cmp2_exe_cs_shift_by_one,    idle_exe_cs_shift_by_one,    idle_exe_cs_shift_by_one,    inst_select)
    `MUX_8(u_mux_exe_br_ucond,   1,             rep_latches_exe_cs_br_ucond,          idle_exe_cs_br_ucond,        movs_exe_cs_br_ucond,        decx_exe_cs_br_ucond,        cmp0_exe_cs_br_ucond,        cmp1_exe_cs_br_ucond,        cmp2_exe_cs_br_ucond,        idle_exe_cs_br_ucond,        idle_exe_cs_br_ucond,        inst_select)
    `MUX_8(u_mux_exe_rel_br,     1,             rep_latches_exe_cs_relative_branch,   idle_exe_cs_relative_branch, movs_exe_cs_relative_branch, decx_exe_cs_relative_branch, cmp0_exe_cs_relative_branch, cmp1_exe_cs_relative_branch, cmp2_exe_cs_relative_branch, idle_exe_cs_relative_branch, idle_exe_cs_relative_branch, inst_select)
    `MUX_8(u_mux_exe_sp_br,      1,             rep_latches_exe_cs_special_br,        idle_exe_cs_special_br,      movs_exe_cs_special_br,      decx_exe_cs_special_br,      cmp0_exe_cs_special_br,      cmp1_exe_cs_special_br,      cmp2_exe_cs_special_br,      idle_exe_cs_special_br,      idle_exe_cs_special_br,      inst_select)
    `MUX_8(u_mux_exe_is_far,     1,             rep_latches_exe_cs_is_far,            idle_exe_cs_is_far,          movs_exe_cs_is_far,          decx_exe_cs_is_far,          cmp0_exe_cs_is_far,          cmp1_exe_cs_is_far,          cmp2_exe_cs_is_far,          idle_exe_cs_is_far,          idle_exe_cs_is_far,          inst_select)
    `MUX_8(u_mux_exe_is_call,    1,             rep_latches_exe_cs_is_call,           idle_exe_cs_is_call,         movs_exe_cs_is_call,         decx_exe_cs_is_call,         cmp0_exe_cs_is_call,         cmp1_exe_cs_is_call,         cmp2_exe_cs_is_call,         idle_exe_cs_is_call,         idle_exe_cs_is_call,         inst_select)
    `MUX_8(u_mux_exe_2nd_flag,   1,             rep_latches_exe_cs_second_flag_needed, idle_exe_cs_second_flag_needed, movs_exe_cs_second_flag_needed, decx_exe_cs_second_flag_needed, cmp0_exe_cs_second_flag_needed, cmp1_exe_cs_second_flag_needed, cmp2_exe_cs_second_flag_needed, idle_exe_cs_second_flag_needed, idle_exe_cs_second_flag_needed, inst_select)
    `MUX_8(u_mux_exe_nozfupd,    1,             rep_latches_exe_cs_rep_no_zf_update,  idle_exe_cs_rep_no_zf_update, movs_exe_cs_rep_no_zf_update, decx_exe_cs_rep_no_zf_update, cmp0_exe_cs_rep_no_zf_update, cmp1_exe_cs_rep_no_zf_update, cmp2_exe_cs_rep_no_zf_update, idle_exe_cs_rep_no_zf_update, idle_exe_cs_rep_no_zf_update, inst_select)
    `MUX_8(u_mux_wb_ST_OP,       1,             rep_latches_wb_cs_ST_OP,              idle_wb_cs_ST_OP,       movs_wb_cs_ST_OP,       decx_wb_cs_ST_OP,       cmp0_wb_cs_ST_OP,       cmp1_wb_cs_ST_OP,       cmp2_wb_cs_ST_OP,       idle_wb_cs_ST_OP,       idle_wb_cs_ST_OP,       inst_select)
    `MUX_8(u_mux_wb_WB_DR,       1,             rep_latches_wb_cs_WB_DR,              idle_wb_cs_WB_DR,       movs_wb_cs_WB_DR,       decx_wb_cs_WB_DR,       cmp0_wb_cs_WB_DR,       cmp1_wb_cs_WB_DR,       cmp2_wb_cs_WB_DR,       idle_wb_cs_WB_DR,       idle_wb_cs_WB_DR,       inst_select)
    `MUX_8(u_mux_wb_WB_SR,       1,             rep_latches_wb_cs_WB_SR,              idle_wb_cs_WB_SR,       movs_wb_cs_WB_SR,       decx_wb_cs_WB_SR,       cmp0_wb_cs_WB_SR,       cmp1_wb_cs_WB_SR,       cmp2_wb_cs_WB_SR,       idle_wb_cs_WB_SR,       idle_wb_cs_WB_SR,       inst_select)
    `MUX_8(u_mux_wb_WB_EAX,      1,             rep_latches_wb_cs_WB_EAX,             idle_wb_cs_WB_EAX,      movs_wb_cs_WB_EAX,      decx_wb_cs_WB_EAX,      cmp0_wb_cs_WB_EAX,      cmp1_wb_cs_WB_EAX,      cmp2_wb_cs_WB_EAX,      idle_wb_cs_WB_EAX,      idle_wb_cs_WB_EAX,      inst_select)
    `MUX_8(u_mux_br_valid,       1,             rep_latches_br_info_valid,            idle_br_info_valid,     movs_br_info_valid,     decx_br_info_valid,     cmp0_br_info_valid,     cmp1_br_info_valid,     cmp2_br_info_valid,     idle_br_info_valid,     idle_br_info_valid,     inst_select)
    `MUX_8(u_mux_br_eip,         32,            rep_latches_br_info_br_eip,           idle_br_info_br_eip,    movs_br_info_br_eip,    decx_br_info_br_eip,    cmp0_br_info_br_eip,    cmp1_br_info_br_eip,    cmp2_br_info_br_eip,    idle_br_info_br_eip,    idle_br_info_br_eip,    inst_select)
    `MUX_8(u_mux_br_xcl,         1,             rep_latches_br_info_br_xcl,           idle_br_info_br_xcl,    movs_br_info_br_xcl,    decx_br_info_br_xcl,    cmp0_br_info_br_xcl,    cmp1_br_info_br_xcl,    cmp2_br_info_br_xcl,    idle_br_info_br_xcl,    idle_br_info_br_xcl,    inst_select)
    `MUX_8(u_mux_br_pred,        1,             rep_latches_br_info_br_pred_taken,    idle_br_info_br_pred_taken,  movs_br_info_br_pred_taken,  decx_br_info_br_pred_taken,  cmp0_br_info_br_pred_taken,  cmp1_br_info_br_pred_taken,  cmp2_br_info_br_pred_taken,  idle_br_info_br_pred_taken,  idle_br_info_br_pred_taken,  inst_select)
    `MUX_8(u_mux_br_spec_tgt,    32,            rep_latches_br_info_speculative_target, idle_br_info_speculative_target, movs_br_info_speculative_target, decx_br_info_speculative_target, cmp0_br_info_speculative_target, cmp1_br_info_speculative_target, cmp2_br_info_speculative_target, idle_br_info_speculative_target, idle_br_info_speculative_target, inst_select)
    `MUX_8(u_mux_NEIP,           32,            rep_latches_NEIP,                     idle_NEIP,              movs_NEIP,              decx_NEIP,              cmp0_NEIP,              cmp1_NEIP,              cmp2_NEIP,              idle_NEIP,              idle_NEIP,              inst_select)
    `MUX_8(u_mux_EIP,            32,            rep_latches_EIP,                      idle_EIP,               movs_EIP,               decx_EIP,               cmp0_EIP,               cmp1_EIP,               cmp2_EIP,               idle_EIP,               idle_EIP,               inst_select)
    `MUX_8(u_mux_EAX,            32,            rep_latches_EAX,                      idle_EAX,               movs_EAX,               decx_EAX,               cmp0_EAX,               cmp1_EAX,               cmp2_EAX,               idle_EAX,               idle_EAX,               inst_select)
    `MUX_8(u_mux_imm64,          64,            rep_latches_imm64,                    idle_imm64,             movs_imm64,             decx_imm64,             cmp0_imm64,             cmp1_imm64,             cmp2_imm64,             idle_imm64,             idle_imm64,             inst_select)
    `MUX_8(u_mux_sib_idx,        `REG_ID_W,     rep_latches_sib_idx_id,               idle_sib_idx_id,        movs_sib_idx_id,        decx_sib_idx_id,        cmp0_sib_idx_id,        cmp1_sib_idx_id,        cmp2_sib_idx_id,        idle_sib_idx_id,        idle_sib_idx_id,        inst_select)
    `MUX_8(u_mux_sib_base,       `REG_ID_W,     rep_latches_sib_base_id,              idle_sib_base_id,       movs_sib_base_id,       decx_sib_base_id,       cmp0_sib_base_id,       cmp1_sib_base_id,       cmp2_sib_base_id,       idle_sib_base_id,       idle_sib_base_id,       inst_select)
    `MUX_8(u_mux_sib_needed,     1,             rep_latches_sib_needed,               idle_sib_needed,        movs_sib_needed,        decx_sib_needed,        cmp0_sib_needed,        cmp1_sib_needed,        cmp2_sib_needed,        idle_sib_needed,        idle_sib_needed,        inst_select)
    `MUX_8(u_mux_sib_scale,      8,             rep_latches_sib_scale,                idle_sib_scale,         movs_sib_scale,         decx_sib_scale,         cmp0_sib_scale,         cmp1_sib_scale,         cmp2_sib_scale,         idle_sib_scale,         idle_sib_scale,         inst_select)
    `MUX_8(u_mux_disp_needed,    1,             rep_latches_disp_needed,              idle_disp_needed,       movs_disp_needed,       decx_disp_needed,       cmp0_disp_needed,       cmp1_disp_needed,       cmp2_disp_needed,       idle_disp_needed,       idle_disp_needed,       inst_select)
    `MUX_8(u_mux_disp_size,      1,             rep_latches_disp_size,                idle_disp_size,         movs_disp_size,         decx_disp_size,         cmp0_disp_size,         cmp1_disp_size,         cmp2_disp_size,         idle_disp_size,         idle_disp_size,         inst_select)
    `MUX_8(u_mux_displacement,   32,            rep_latches_displacement,             idle_displacement,      movs_displacement,      decx_displacement,      cmp0_displacement,      cmp1_displacement,      cmp2_displacement,      idle_displacement,      idle_displacement,      inst_select)

endmodule
