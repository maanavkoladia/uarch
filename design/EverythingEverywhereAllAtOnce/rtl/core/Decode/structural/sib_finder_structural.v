module sib_finder (
    input [3:0] modrm_index,
    input [127:0] IR,
    output [7:0] sib_byte
);

    wire [3:0] sib_index;  //byte index
    wire adder_cout;
    `ADD_N(sib_index_adder, 4, sib_index, adder_cout, modrm_index, 4'd1, 1'b0)
    
    assign sib_byte = IR[sib_index*8 +: 32];  //bit index
endmodule

