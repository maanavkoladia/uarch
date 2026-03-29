module push_op(
    input  logic [63:0] value, // value to push
    input  logic [63:0] sp,    // stack pointer in

    output logic [63:0] res_buf,  // value to write to memory
    output logic [63:0] dr_o      // new stack pointer out
);

    assign res_buf = {32'd0, value[31:0]};
    assign dr_o    = {32'd0, sp[31:0] - 4};

endmodule