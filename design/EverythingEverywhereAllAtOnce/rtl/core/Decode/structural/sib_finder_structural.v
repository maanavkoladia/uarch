module sib_finder (
    input [3:0] modrm_index,
    input [127:0] IR,
    output [7:0] sib_byte
);

    wire [3:0] sib_index, sib_index_pre;  //byte index
    wire adder_cout;
    `ADD_N(sib_index_adder, 4, sib_index_pre, adder_cout, modrm_index, 4'd1, 1'b0)
    bufferH64$ sib_buf0(.out(sib_index[0]), .in(sib_index_pre[0]));
    bufferH64$ sib_buf1(.out(sib_index[1]), .in(sib_index_pre[1]));
    bufferH64$ sib_buf2(.out(sib_index[2]), .in(sib_index_pre[2]));
    bufferH64$ sib_buf3(.out(sib_index[3]), .in(sib_index_pre[3]));
    
    // assign sib_byte = IR[sib_index*8 +: 32];  //bit index
    `MUX_16(sib_byte_mux, 8, sib_byte,
        IR[0*8 +: 8],  IR[1*8 +: 8],  IR[2*8 +: 8],  IR[3*8 +: 8],
        IR[4*8 +: 8],  IR[5*8 +: 8],  IR[6*8 +: 8],  IR[7*8 +: 8],
        IR[8*8 +: 8],  IR[9*8 +: 8],  IR[10*8 +: 8], IR[11*8 +: 8],
        IR[12*8 +: 8], IR[13*8 +: 8], IR[14*8 +: 8], IR[15*8 +: 8],
        sib_index)
endmodule

