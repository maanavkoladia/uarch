module imm_finder (
    input [3:0] imm_index,
    input [127:0] IR,
    output [63:0] imm64
);
    // assign imm64 = IR[imm_index*8 +: 64];
    `MUX_16(imm64_mux, 64, imm64,
        IR[0*8 +: 64], IR[1*8 +: 64], IR[2*8 +: 64], IR[3*8 +: 64],
        IR[4*8 +: 64], IR[5*8 +: 64], IR[6*8 +: 64], IR[7*8 +: 64],
        IR[8*8 +: 64],
        {8'b0,  IR[127:72]},  {16'b0, IR[127:80]},  {24'b0, IR[127:88]},
        {32'b0, IR[127:96]},  {40'b0, IR[127:104]}, {48'b0, IR[127:112]},
        {56'b0, IR[127:120]},
        imm_index)

endmodule
