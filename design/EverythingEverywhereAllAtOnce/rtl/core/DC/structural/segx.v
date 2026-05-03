// ----------------------------------------------------------------
// segx -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/segx.sv
//   assign segx_gp = (laddy >= seg_limit_w_datasize) && !stack_access;
//
// Implementation:
//   laddy >= seg_limit_w_datasize is the carry-out of
//   (laddy + ~seg_limit_w_datasize + 1) -- two's-complement subtraction.
//   No borrow out of an unsigned subtract means the minuend was >= the
//   subtrahend.
//
//   seg_limit is on the port list to match the .sv reference but is
//   unused in the original behavior, so it is unused here too.
// ----------------------------------------------------------------
module segx (
    input  wire [31:0] laddy,
    input  wire [31:0] seg_limit,
    input  wire [31:0] seg_limit_w_datasize,
    input  wire        stack_access,
    output wire        segx_gp
);

    wire [31:0] seg_limit_w_datasize_inv;
    wire [31:0] sub_sum;            // unused: only the carry-out matters
    wire        ge_l_ge_s;          // 1 iff laddy >= seg_limit_w_datasize
    wire        not_stack_access;

    `INV_N(u_inv_seg,    32, seg_limit_w_datasize, seg_limit_w_datasize_inv)
    `ADD_N(u_sub_l_seg,  32, sub_sum, ge_l_ge_s, laddy, seg_limit_w_datasize_inv, 1'b1)
    `INV_N(u_inv_stack,   1, stack_access, not_stack_access)
    `AND_2(u_segx_gp,     1, segx_gp, ge_l_ge_s, not_stack_access)

endmodule
