// Structural Verilog 2005 port of BTFN.
// Reference SV: rtl/core/Fetch/structural/BTFN.sv (original).
//
// Static Backward-Taken / Forward-Not-Taken predictor.
//   taken = (btfn_target < spc)        unsigned
//
// Implemented using the Kogge-Stone adder:
//   btfn_target - spc  =  btfn_target + ~spc + 1
//   For unsigned a < b, the subtraction has no carry-out (cout = 0).
//   So:  taken = ~cout
//
//   a < b      | cout
//   --------- | ----
//   a < b     | 0   (taken)
//   a >= b    | 1   (not taken)

module BTFN (
    input  wire [31:0] btfn_target,
    input  wire [31:0] spc,
    output wire        taken
);

    wire [31:0] spc_inv;
    wire [31:0] sub_sum;       // unused: only the carry-out matters
    wire        sub_cout;

    // Build the (target - spc) subtraction with the adder
    `INV_N(u_inv_spc,   32, spc,     spc_inv)
    `ADD_N(u_sub,       32, sub_sum, sub_cout, btfn_target, spc_inv, 1'b1)

    // taken = ~cout
    `INV_N(u_inv_cout,  1,  sub_cout, taken)

endmodule
