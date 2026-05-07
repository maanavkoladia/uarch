// Structural Verilog 2005 port of EXE/FunctionalUnits/iretd_op.sv
// dr_o = {32'd0, cs}
// sr_o = stack_ptr + 12
// {CF, PF, AF, ZF, SF, OF} = flags at flag-bit indices

module iretd_op (
    input  wire [31:0] cs,
    input  wire [31:0] flags,
    input  wire [63:0] stack_ptr,
    output wire [63:0] dr_o,
    output wire [63:0] sr_o,
    output wire        CF,
    output wire        PF,
    output wire        AF,
    output wire        ZF,
    output wire        SF,
    output wire        OF
);

    assign dr_o = {32'd0, cs};

    wire add_cout;
    `ADD_N(u_add_12, 64, sr_o, add_cout, stack_ptr, 64'd12, 1'b0)

    assign CF = flags[`EXE_FLAG_CF_IDX];
    assign PF = flags[`EXE_FLAG_PF_IDX];
    assign AF = flags[`EXE_FLAG_AF_IDX];
    assign ZF = flags[`EXE_FLAG_ZF_IDX];
    assign SF = flags[`EXE_FLAG_SF_IDX];
    assign OF = flags[`EXE_FLAG_OF_IDX];

endmodule
