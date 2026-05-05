module disp_finder (
    input [3:0] sib_index,
    input sib_size,
    input [127:0] IR,
    output [31:0] disp
);
    wire [3:0] disp_index;  //byte index
    wire adder_cout;
    `ADD_N(disp_index_adder, 4, disp_index, adder_cout, sib_index, {3'b0, sib_size}, 1'b0)

    // assign disp = IR[disp_index*8 +: 32];
    `MUX_16(disp_mux, 32, disp,
        IR[0*8  +: 32], IR[1*8  +: 32], IR[2*8  +: 32], IR[3*8  +: 32],
        IR[4*8  +: 32], IR[5*8  +: 32], IR[6*8  +: 32], IR[7*8  +: 32],
        IR[8*8  +: 32], IR[9*8  +: 32], IR[10*8 +: 32], IR[11*8 +: 32],
        IR[12*8 +: 32], IR[13*8 +: 32], IR[14*8 +: 32], IR[15*8 +: 32],
        disp_index)

endmodule


