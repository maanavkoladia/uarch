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

    output exp_set_logic_output_t outputs
);

// =====================
// Internal wires
// =====================
wire f_pipe_clear;
wire dc_pipe_clear;

wire not_rr_valid;
wire not_dc_valid;
wire not_mem_valid;
wire not_exe_valid;
wire not_wb_valid;

// =====================
// Inverters
// =====================
`INV_N(inv0, 1, rr_valid,  not_rr_valid)
`INV_N(inv1, 1, dc_valid,  not_dc_valid)
`INV_N(inv2, 1, mem_valid, not_mem_valid)
`INV_N(inv3, 1, exe_valid, not_exe_valid)
`INV_N(inv4, 1, wb_valid,  not_wb_valid)

// =====================
// AND trees
// =====================
`AND_7(and_exp, 1, f_pipe_clear,
    invalid_instruction,
    not_rr_valid,
    not_dc_valid,
    not_mem_valid,
    not_exe_valid,
    not_wb_valid,
    f_exp
)

`AND_4(and_dc, 1, dc_pipe_clear,
    not_mem_valid,
    not_exe_valid,
    not_wb_valid,
    dc_exp
)

// =====================
// MUX (dc_exp priority)
// =====================
`MUX_2(mux_exp_sel, 1,
    outputs.exp_pipe_clear,
    f_pipe_clear,
    dc_pipe_clear,
    dc_exp
)

// =====================
// Interrupt logic
// =====================
`AND_7(and_int, 1, outputs.int_pipe_clear,
    invalid_instruction,
    not_rr_valid,
    not_dc_valid,
    not_mem_valid,
    not_exe_valid,
    not_wb_valid,
    int_set
)

endmodule