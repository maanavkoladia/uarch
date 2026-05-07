// Structural Verilog 2005 port of EXE/res_buf_logic.sv
// Places 8 bytes of res_info_i into a 32-byte buffer at byte offset = st_addr_0[3:0].
// Other 24 bytes are 0. Implementation: 16 pre-shifted 256-bit candidates +
// one MUX_16 selected by offset. Critical path: ~2 gate delays through mux16.

module res_buf_logic (
    input  wire [63:0]                 res_info_i,
    input  wire [`EXE_STRUCT_P_ADDR_W-1:0] st_addr_0,  // p_address_t (15 bits)
    output wire [`CACHE_LINES_SIZE_B*2*8-1:0] res_buf  // 256-bit packed: byte i in bits [8i+7:8i]
);

    // 4-bit byte offset within the 32-byte staging buffer.
    wire [3:0] offset;
    assign offset = st_addr_0[3:0];

    // 16 pre-shifted candidates: candidate[o] places res_info_i at byte position o.
    // Layout (LSB-first byte packing): {high zeros, res_info_i, low zeros}.
    // High zeros: (24-o) bytes = (24-o)*8 bits. Low zeros: o bytes = o*8 bits.
    wire [255:0] shifted [0:15];

    assign shifted[0]  = {192'h0, res_info_i};
    assign shifted[1]  = {184'h0, res_info_i, 8'h0};
    assign shifted[2]  = {176'h0, res_info_i, 16'h0};
    assign shifted[3]  = {168'h0, res_info_i, 24'h0};
    assign shifted[4]  = {160'h0, res_info_i, 32'h0};
    assign shifted[5]  = {152'h0, res_info_i, 40'h0};
    assign shifted[6]  = {144'h0, res_info_i, 48'h0};
    assign shifted[7]  = {136'h0, res_info_i, 56'h0};
    assign shifted[8]  = {128'h0, res_info_i, 64'h0};
    assign shifted[9]  = {120'h0, res_info_i, 72'h0};
    assign shifted[10] = {112'h0, res_info_i, 80'h0};
    assign shifted[11] = {104'h0, res_info_i, 88'h0};
    assign shifted[12] = { 96'h0, res_info_i, 96'h0};
    assign shifted[13] = { 88'h0, res_info_i, 104'h0};
    assign shifted[14] = { 80'h0, res_info_i, 112'h0};
    assign shifted[15] = { 72'h0, res_info_i, 120'h0};

    // 256-bit-wide 16:1 mux selects the right candidate by offset.
    `MUX_16(u_mux_res_buf, 256, res_buf,
        shifted[0],  shifted[1],  shifted[2],  shifted[3],
        shifted[4],  shifted[5],  shifted[6],  shifted[7],
        shifted[8],  shifted[9],  shifted[10], shifted[11],
        shifted[12], shifted[13], shifted[14], shifted[15],
        offset)

endmodule
