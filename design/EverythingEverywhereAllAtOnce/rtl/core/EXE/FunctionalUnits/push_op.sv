//value comes from DR latch/SRA
//SP will ALWAYS come from SR/SRB
//RES_BUF <- DR_latch/SRA
//SR_o <- SP
module push_op(
    input  logic [63:0] value, // value to push SRA
    input  logic [63:0] sp,    // stack pointer in SRB

    output logic [63:0] res_buf,  // value to write to memory
    output logic [63:0] sr_o      // new stack pointer out
);

    assign res_buf = {32'd0, value[31:0]};
    assign sr_o    = {32'd0, sp[31:0] - 4};

endmodule