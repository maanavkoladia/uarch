// Structural Verilog 2005 port of EXE/FunctionalUnits/or_op.sv
// merged_result = (per-byte mux of OR(srA, srB) vs srA) under data_size mask;
//                 high 32 bits forced to 0.
// dr_o = res_buf_o = merged_result.
// CF = OF = AF = 0.
// PF = ~^merged[15:8] when ~data_size[0], else ~^merged[7:0].
// ZF/SF: case on data_size (default 0).

module or_op (
    input  wire [63:0] srA,
    input  wire [63:0] srB,
    input  wire [3:0]  data_size,
    output wire [63:0] dr_o,
    output wire [63:0] res_buf_o,
    output wire        ZF,
    output wire        SF,
    output wire        PF,
    output wire        OF,
    output wire        CF,
    output wire        AF
);

    wire [63:0] or_result;
    `OR_2(u_or_full, 64, or_result, srA, srB)

    // Per-byte data_size mask
    wire [7:0]  m_b0, m_b1;
    wire [7:0]  m_b0_raw, m_b1_raw;
    wire [15:0] m_hi;
    `MUX_2(u_mux_b0, 8,  m_b0_raw, srA[7:0],   or_result[7:0],   data_size[0])
    `MUX_2(u_mux_b1, 8,  m_b1_raw, srA[15:8],  or_result[15:8],  data_size[1])
    `MUX_2(u_mux_hi, 16, m_hi,     srA[31:16], or_result[31:16], data_size[2])

    // Buffer m_b0/m_b1 with bufferH16$ (worst-bit fanout 6, single-stage).
    genvar gi_mb;
    generate
        for (gi_mb = 0; gi_mb < 8; gi_mb = gi_mb + 1) begin : g_mb_buf
            bufferH16$ u_buf_b0 (.out(m_b0[gi_mb]), .in(m_b0_raw[gi_mb]));
            bufferH16$ u_buf_b1 (.out(m_b1[gi_mb]), .in(m_b1_raw[gi_mb]));
        end
    endgenerate

    wire [31:0] merged;
    assign merged = {m_hi, m_b1, m_b0};
    assign dr_o      = {32'd0, merged};
    assign res_buf_o = {32'd0, merged};

    assign CF = 1'b0;
    assign OF = 1'b0;
    assign AF = 1'b0;

    // PF: data_size[0]=1 → low byte; else upper byte (matches SV ~data_size[0]).
    wire pf_lo, pf_hi;
    pf_red_8 u_pf_lo (.x(merged[7:0]),  .p(pf_lo));
    pf_red_8 u_pf_hi (.x(merged[15:8]), .p(pf_hi));
    `MUX_2(u_mux_pf, 1, PF, pf_hi, pf_lo, data_size[0])

    // ZF lane reductions
    wire zf_b0, zf_b1, zf_hi16;
    zf_red_8  u_zf_b0  (.x(merged[7:0]),   .z(zf_b0));
    zf_red_8  u_zf_b1  (.x(merged[15:8]),  .z(zf_b1));
    zf_red_16 u_zf_hi  (.x(merged[31:16]), .z(zf_hi16));

    wire zf_low16;
    `AND_2(u_and_zf_low16, 1, zf_low16, zf_b0, zf_b1)
    wire zf_full32;
    `AND_2(u_and_zf_full32, 1, zf_full32, zf_low16, zf_hi16)

    wire is_al, is_ah, is_ax, is_eax;
    `CMP_N(u_cmp_al,  4, is_al,  data_size, 4'b0001)
    `CMP_N(u_cmp_ah,  4, is_ah,  data_size, 4'b0010)
    `CMP_N(u_cmp_ax,  4, is_ax,  data_size, 4'b0011)
    `CMP_N(u_cmp_eax, 4, is_eax, data_size, 4'b0111)

    wire zf_s1, zf_s2, zf_s3;
    `MUX_2(u_mux_zf_1, 1, zf_s1, 1'b0,  zf_full32, is_eax)
    `MUX_2(u_mux_zf_2, 1, zf_s2, zf_s1, zf_low16,  is_ax)
    `MUX_2(u_mux_zf_3, 1, zf_s3, zf_s2, zf_b1,     is_ah)
    `MUX_2(u_mux_zf,   1, ZF,    zf_s3, zf_b0,     is_al)

    // SF: 0001 → merged[7]; 0010 → merged[15]; 0011 → merged[15]; 0111 → merged[31]
    wire sf_s1, sf_s2, sf_s3;
    `MUX_2(u_mux_sf_1, 1, sf_s1, 1'b0,  merged[31], is_eax)
    `MUX_2(u_mux_sf_2, 1, sf_s2, sf_s1, merged[15], is_ax)
    `MUX_2(u_mux_sf_3, 1, sf_s3, sf_s2, merged[15], is_ah)
    `MUX_2(u_mux_sf,   1, SF,    sf_s3, merged[7],  is_al)

endmodule
