// Structural Verilog 2005 port of EXP_Set_logic.
// Reference SV: rtl/core/Fetch/structural/EXP_Set_logic.sv (original).
//
// Pure combinational. Produces three pipe-clear / set signals:
//
//   f_pipe_clear   = invalid_instruction & ~rr_valid & ~dc_valid &
//                    ~mem_valid & ~exe_valid & ~wb_valid &
//                    f_exp & ~exp_mode_jk
//   dc_pipe_clear  = ~mem_valid & ~exe_valid & ~wb_valid &
//                    dc_exp & ~exp_mode_jk
//   exp_pipe_clear = dc_exp ? dc_pipe_clear : f_pipe_clear
//   int_pipe_clear = invalid_instruction & ~rr_valid & ~dc_valid &
//                    ~mem_valid & ~exe_valid & ~wb_valid &
//                    int_set & ~int_mode_jk
//   dc_exp_set     = dc_pipe_clear

module EXP_Set_logic (
    input  wire invalid_instruction,
    input  wire rr_valid,
    input  wire dc_valid,
    input  wire mem_valid,
    input  wire exe_valid,
    input  wire wb_valid,

    input  wire f_exp,
    input  wire dc_exp,
    input  wire int_set,

    input  wire exp_mode_jk,
    input  wire int_mode_jk,

    // exp_set_logic_output_t unrolled
    output wire exp_pipe_clear,
    output wire dc_exp_set,
    output wire int_pipe_clear
);

    // ----------------------------------------------------------------
    // Inverters
    // ----------------------------------------------------------------
    wire not_rr_valid;
    wire not_dc_valid;
    wire not_mem_valid;
    wire not_exe_valid;
    wire not_wb_valid;
    wire not_exp_mode_jk;
    wire not_int_mode_jk;

    `INV_N(u_inv_rr,   1, rr_valid,    not_rr_valid)
    `INV_N(u_inv_dc,   1, dc_valid,    not_dc_valid)
    `INV_N(u_inv_mem,  1, mem_valid,   not_mem_valid)
    `INV_N(u_inv_exe,  1, exe_valid,   not_exe_valid)
    `INV_N(u_inv_wb,   1, wb_valid,    not_wb_valid)
    `INV_N(u_inv_exp,  1, exp_mode_jk, not_exp_mode_jk)
    `INV_N(u_inv_int,  1, int_mode_jk, not_int_mode_jk)

    // ----------------------------------------------------------------
    // f_pipe_clear (8-input AND)
    // ----------------------------------------------------------------
    wire f_pipe_clear;
    `AND_8(u_f_pc, 1, f_pipe_clear,
           invalid_instruction,
           not_rr_valid,
           not_dc_valid,
           not_mem_valid,
           not_exe_valid,
           not_wb_valid,
           f_exp,
           not_exp_mode_jk)

    // ----------------------------------------------------------------
    // dc_pipe_clear (5-input AND)
    // ----------------------------------------------------------------
    wire dc_pipe_clear;
    `AND_5(u_dc_pc, 1, dc_pipe_clear,
           not_mem_valid,
           not_exe_valid,
           not_wb_valid,
           dc_exp,
           not_exp_mode_jk)

    // ----------------------------------------------------------------
    // exp_pipe_clear = dc_exp ? dc_pipe_clear : f_pipe_clear
    // ----------------------------------------------------------------
    `MUX_2(u_exp_mux, 1, exp_pipe_clear, f_pipe_clear, dc_pipe_clear, dc_exp)

    // ----------------------------------------------------------------
    // int_pipe_clear (8-input AND)
    // ----------------------------------------------------------------
    `AND_8(u_int_pc, 1, int_pipe_clear,
           invalid_instruction,
           not_rr_valid,
           not_dc_valid,
           not_mem_valid,
           not_exe_valid,
           not_wb_valid,
           int_set,
           not_int_mode_jk)

    // ----------------------------------------------------------------
    // dc_exp_set is just dc_pipe_clear republished
    // ----------------------------------------------------------------
    assign dc_exp_set = dc_pipe_clear;

endmodule
