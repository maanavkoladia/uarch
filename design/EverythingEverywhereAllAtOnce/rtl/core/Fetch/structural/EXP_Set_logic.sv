import common_pkg::*;
import interconnect_pkg::*;
import core_common_pkg::*;
import core_stage_latches_pkg::*;

module EXP_Set_logic(
    input  invalid_instruction,
    input rr_valid,
    input dc_valid,
    input mem_valid,
    input exe_valid,
    input wb_valid,

    // ispresent
    input f_exp,
    input dc_exp,
    input int_set,

    input exp_mode_jk,
    input int_mode_jk,

    output exp_set_logic_output_t outputs
);

// =====================
// Internal signals
// =====================
logic f_pipe_clear;
logic dc_pipe_clear;

logic not_rr_valid;
logic not_dc_valid;
logic not_mem_valid;
logic not_exe_valid;
logic not_wb_valid;

// =====================
// Inverters
// =====================
assign not_rr_valid  = ~rr_valid;
assign not_dc_valid  = ~dc_valid;
assign not_mem_valid = ~mem_valid;
assign not_exe_valid = ~exe_valid;
assign not_wb_valid  = ~wb_valid;

// =====================
// AND trees
// =====================
assign f_pipe_clear = invalid_instruction & not_rr_valid & not_dc_valid &
                      not_mem_valid & not_exe_valid & not_wb_valid & f_exp & ~exp_mode_jk;

assign dc_pipe_clear = not_mem_valid & not_exe_valid & not_wb_valid & dc_exp & ~exp_mode_jk;

// =====================
// MUX (dc_exp priority)
// =====================
assign outputs.exp_pipe_clear = dc_exp ? dc_pipe_clear : f_pipe_clear;

// =====================
// Interrupt logic
// =====================
assign outputs.int_pipe_clear = invalid_instruction & not_rr_valid & not_dc_valid &
                                not_mem_valid & not_exe_valid & not_wb_valid & int_set & ~int_mode_jk;

assign outputs.dc_exp_set = dc_pipe_clear;

endmodule