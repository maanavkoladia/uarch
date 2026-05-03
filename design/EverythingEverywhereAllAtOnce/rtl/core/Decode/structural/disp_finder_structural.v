module disp_finder (
    input [3:0] sib_index,
    input sib_size,
    input [127:0] IR,
    output [31:0] disp
);
    wire [3:0] disp_index;  //byte index
    wire adder_cout;
    `ADD_N(disp_index_adder, 4, disp_index, adder_cout, sib_index, {3'b0, sib_size}, 1'b0)

    assign disp = IR[disp_index*8 +: 32];

endmodule


