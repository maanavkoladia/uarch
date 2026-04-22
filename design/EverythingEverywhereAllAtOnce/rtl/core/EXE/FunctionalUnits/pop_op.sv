//value_i comes from buffer ALWAYS
//SP will ALWAYS come from SR
//DR output latches <- value
//SR <- SP

module pop_op(
    input  logic [63:0] value_i, // value at stack (to restore)
    input  logic [63:0] sp_i,    // value of ESP (stack pointer)
    // never writing to mem
    output logic [63:0] dr_o,  // data to restore from stack
    output logic [63:0] sr_o     // stack pointer update
    // no flag update
);

    assign dr_o = {32'd0, value_i[31:0]};
    assign sr_o   = {32'd0, sp_i[31:0] + 4};

endmodule