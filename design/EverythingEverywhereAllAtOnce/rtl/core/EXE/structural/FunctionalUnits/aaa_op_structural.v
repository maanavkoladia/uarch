// Structural Verilog 2005 port of EXE/FunctionalUnits/aaa_op.sv
// ASCII Adjust After Addition.
//   AL = EAX_in[7:0]; AH = EAX_in[15:8]
//   adjust = ((AL & 0x0F) > 9) || AF_flag_in
//          = (AL[3] AND (AL[2] OR AL[1])) || AF_flag_in
//   if adjust: AL <- (AL + 6) & 0x0F ; AH <- AH + 1 ; CF=AF=1
//   else     : CF=AF=0
//   dr_o = {32'h0, EAX_in[31:16], AH, AL}

module aaa_op (
    input  wire [63:0] EAX_in,
    input  wire        AF_flag_in,
    output wire [63:0] dr_o,
    output wire        CF,
    output wire        AF
);

    wire [7:0] AL;
    wire [7:0] AH;
    assign AL = EAX_in[7:0];
    assign AH = EAX_in[15:8];

    // gt9 = AL[3] AND (AL[2] OR AL[1])  ⇔  (AL & 0x0F) > 9
    wire al_or_21;
    `OR_2(u_or_al21, 1, al_or_21, AL[2], AL[1])
    wire gt9;
    `AND_2(u_and_gt9, 1, gt9, AL[3], al_or_21)

    // adjust = gt9 OR AF_flag_in
    wire adjust;
    wire adjust_raw;
    `OR_2(u_or_adj, 1, adjust_raw, gt9, AF_flag_in)
    // Buffer adjust with bufferH64$: fanout 18 exceeds bufferH16$'s 16-load
    // rating; bufferH64$ (rated 64, 0.30 ns typ) is the next size up.
    bufferH64$ u_buf_adj (.out(adjust), .in(adjust_raw));

    // AL + 6 (8-bit)
    wire [7:0] al_p6;
    wire       al_cout;
    `ADD_N(u_add_al6, 8, al_p6, al_cout, AL, 8'h06, 1'b0)

    // AH + 1 (8-bit)
    wire [7:0] ah_p1;
    wire       ah_cout;
    `ADD_N(u_add_ah1, 8, ah_p1, ah_cout, AH, 8'h01, 1'b0)

    // AL_out: low nibble = adjust ? al_p6[3:0] : AL[3:0]
    //         high nibble = adjust ? 4'h0       : AL[7:4]
    wire [3:0] al_lo_new;
    wire [3:0] al_hi_new;
    `MUX_2(u_mux_al_lo, 4, al_lo_new, AL[3:0], al_p6[3:0], adjust)
    `MUX_2(u_mux_al_hi, 4, al_hi_new, AL[7:4], 4'h0,        adjust)

    // AH_out = adjust ? ah_p1 : AH
    wire [7:0] ah_new;
    `MUX_2(u_mux_ah, 8, ah_new, AH, ah_p1, adjust)

    assign dr_o = {32'h0, EAX_in[31:16], ah_new, al_hi_new, al_lo_new};

    assign CF = adjust;
    assign AF = adjust;

endmodule
