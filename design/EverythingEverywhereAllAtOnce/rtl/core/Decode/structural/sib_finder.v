module sib_finder (
    input [3:0] modrm_index,
    input [15:0][7:0] IR,
    output [7:0] sib_byte
);
    wire [3:0] sib_index;
    assign sib_index = modrm_index + 1;
    assign sib_byte = IR[sib_index];
endmodule

/*
    wire [3:0] sib_index;  //bit index
    wire adder_cout;
    `ADD_N(sib_index_adder, 4, sib_index, adder_cout, modrm_index, 4'd1, 1'b0)

    
    assign disp = IR[{sib_index, 3'd0} +: 32];

    */

