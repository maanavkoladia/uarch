// Structural Verilog 2005 port of EXE/FunctionalUnits/adc_op.sv
//
// 33-bit add: sum = srA[31:0] + srB[31:0] + CF_in
// dr_o = res_buf_o = {32'd0, sum[31:0]}
// CF = sum[32], SF = sum[31], ZF = (sum[31:0] == 0), PF = ~^sum[7:0]
// OF = (srA[31] == srB[31]) AND (srA[31] != sum[31])
// AF: SV reference uses 4-bit-truncated arithmetic compared to 4'hF, which is
//     always false under Verilog 2005 self-determined width rules — so AF
//     is 1'b0 here, matching simulator behavior.

module adc_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire        CF_in,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        CF,
    output wire        PF,
    output wire        AF,
    output wire        ZF,
    output wire        SF,
    output wire        OF
);

    wire [32:0] sum;
    wire        cout;
    `ADD_N(u_add, 33, sum, cout, {1'b0, srA[31:0]}, {1'b0, srB[31:0]}, CF_in)

    assign dr_o      = {32'd0, sum[31:0]};
    assign res_buf_o = {32'd0, sum[31:0]};

    assign CF = sum[32];
    assign SF = sum[31];

    zf_red_32 u_zf (.x(sum[31:0]), .z(ZF));
    pf_red_8  u_pf (.x(sum[7:0]),  .p(PF));

    // See header note re: AF.
    assign AF = 1'b0;

    // OF = ~(srA[31] XOR srB[31]) AND (srA[31] XOR sum[31])
    wire xab, xab_inv, xas;
    `XOR_2(u_xor_ab, 1, xab, srA[31], srB[31])
    `INV_N(u_inv_ab, 1, xab, xab_inv)
    `XOR_2(u_xor_as, 1, xas, srA[31], sum[31])
    `AND_2(u_and_of, 1, OF,  xab_inv, xas)

endmodule
