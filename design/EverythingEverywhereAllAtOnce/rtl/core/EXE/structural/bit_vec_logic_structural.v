// Structural Verilog 2005 port of EXE/bit_vec_logic.sv
// Generates two 16-bit byte-write-vectors for the staging buffer:
//   st_vec0 — bytes written into the cache line whose offset is st_addr_0[3:0]
//   st_vec1 — bytes spilled into the next cache line when ST_XCL=1, else 0
//
// data_size encoding (one-hot-ish):
//   4'b0001 = AL  → 1 byte    4'b0010 = AH  → 1 byte
//   4'b0011 = AX  → 2 bytes   4'b0111 = EAX → 4 bytes   4'b1111 = RAX → 8 bytes

module bit_vec_logic (
    input  wire [`EXE_STRUCT_P_ADDR_W-1:0] st_addr_0,  // p_address_t (15 bits)
    input  wire                     ST_XCL,
    input  wire [3:0]               data_size,
    output wire [15:0]              st_vec0,
    output wire [15:0]              st_vec1
);

    // ---- Decode data_size into 5 one-hot size signals ----
    wire is_AL, is_AH, is_AX, is_EAX, is_RAX;
    `CMP_N(u_cmp_AL,  4, is_AL,  data_size, 4'b0001)
    `CMP_N(u_cmp_AH,  4, is_AH,  data_size, 4'b0010)
    `CMP_N(u_cmp_AX,  4, is_AX,  data_size, 4'b0011)
    `CMP_N(u_cmp_EAX, 4, is_EAX, data_size, 4'b0111)
    `CMP_N(u_cmp_RAX, 4, is_RAX, data_size, 4'b1111)

    // ---- Build mask_for_size: 16-bit value with num_bytes low bits = 1 ----
    //   AL/AH (1 byte)  → 16'h0001
    //   AX    (2 bytes) → 16'h0003
    //   EAX   (4 bytes) → 16'h000F
    //   RAX   (8 bytes) → 16'h00FF
    //   default         → 16'h0000
    //
    // mask_for_size[0]   = is_AL | is_AH | is_AX | is_EAX | is_RAX  (any size ≥ 1)
    // mask_for_size[1]   = is_AX | is_EAX | is_RAX                  (any size ≥ 2)
    // mask_for_size[2:3] = is_EAX | is_RAX                          (any size ≥ 4)
    // mask_for_size[4:7] = is_RAX                                   (size = 8)
    // mask_for_size[15:8] = 0
    wire is_size1_or_more, is_size2_or_more, is_size4_or_more;
    wire is_AL_or_AH;
    `OR_2(u_or_alh, 1, is_AL_or_AH, is_AL, is_AH)
    `OR_4(u_or_size1, 1, is_size1_or_more, is_AL_or_AH, is_AX, is_EAX, is_RAX)
    `OR_3(u_or_size2, 1, is_size2_or_more, is_AX, is_EAX, is_RAX)
    `OR_2(u_or_size4, 1, is_size4_or_more, is_EAX, is_RAX)

    wire [15:0] mask_for_size;
    assign mask_for_size[0]    = is_size1_or_more;
    assign mask_for_size[1]    = is_size2_or_more;
    assign mask_for_size[2]    = is_size4_or_more;
    assign mask_for_size[3]    = is_size4_or_more;
    assign mask_for_size[4]    = is_RAX;
    assign mask_for_size[5]    = is_RAX;
    assign mask_for_size[6]    = is_RAX;
    assign mask_for_size[7]    = is_RAX;
    assign mask_for_size[15:8] = 8'h0;

    // ---- num_bytes (4-bit one-hot encoding 1/2/4/8) for the address adder ----
    //   num_bytes[0] = is_AL | is_AH (size 1)
    //   num_bytes[1] = is_AX         (size 2)
    //   num_bytes[2] = is_EAX        (size 4)
    //   num_bytes[3] = is_RAX        (size 8)
    wire [3:0] num_bytes;
    assign num_bytes[0] = is_AL_or_AH;
    assign num_bytes[1] = is_AX;
    assign num_bytes[2] = is_EAX;
    assign num_bytes[3] = is_RAX;

    // ---- start_offset = st_addr_0[3:0] ----
    wire [3:0] start_offset;
    assign start_offset = st_addr_0[3:0];

    // ---- end_of_st_addr_1 = start_offset + num_bytes (4-bit Kogge-Stone add) ----
    // We only need the lower 4 bits as offset_xcl.
    wire [3:0] end_of_addr_lo;
    wire end_of_addr_cout;
    `ADD_N(u_add_end, 4, end_of_addr_lo, end_of_addr_cout, start_offset, num_bytes, 1'b0)

    wire [3:0] offset_xcl;
    assign offset_xcl = end_of_addr_lo;

    // ---- Pick base value for the st_vec0 shift ----
    //   ST_XCL=1: shift 16'hFFFF (all 1s — entire rest of cacheline written)
    //   ST_XCL=0: shift mask_for_size (only num_bytes low bits set)
    wire [15:0] all_ones;
    assign all_ones = 16'hFFFF;
    wire [15:0] vec0_base;
    `MUX_2(u_mux_vec0_base, 16, vec0_base, mask_for_size, all_ones, ST_XCL)

    // ---- 16-bit barrel shifter, shift left by start_offset[3:0] ----
    // Stage k shifts by 2^k when start_offset[k]=1, else passes through.
    wire [15:0] vec0_s0, vec0_s1, vec0_s2;
    wire [15:0] vec0_s0_shift, vec0_s1_shift, vec0_s2_shift, vec0_s3_shift;
    assign vec0_s0_shift = {vec0_base[14:0], 1'b0};
    `MUX_2(u_vec0_s0, 16, vec0_s0, vec0_base, vec0_s0_shift, start_offset[0])
    assign vec0_s1_shift = {vec0_s0[13:0], 2'b0};
    `MUX_2(u_vec0_s1, 16, vec0_s1, vec0_s0, vec0_s1_shift, start_offset[1])
    assign vec0_s2_shift = {vec0_s1[11:0], 4'b0};
    `MUX_2(u_vec0_s2, 16, vec0_s2, vec0_s1, vec0_s2_shift, start_offset[2])
    assign vec0_s3_shift = {vec0_s2[7:0], 8'b0};
    `MUX_2(u_vec0_s3, 16, st_vec0, vec0_s2, vec0_s3_shift, start_offset[3])

    // ---- st_vec1 path : when ST_XCL=1, mask_xcl = ~(16'hFFFF << offset_xcl) ----
    // 16-bit shift of all-1s by offset_xcl. INV gives bits 0..offset_xcl-1 set.
    wire [15:0] xcl_s0, xcl_s1, xcl_s2, xcl_s3;
    wire [15:0] xcl_s0_shift, xcl_s1_shift, xcl_s2_shift, xcl_s3_shift;
    assign xcl_s0_shift = {all_ones[14:0], 1'b0};
    `MUX_2(u_xcl_s0, 16, xcl_s0, all_ones, xcl_s0_shift, offset_xcl[0])
    assign xcl_s1_shift = {xcl_s0[13:0], 2'b0};
    `MUX_2(u_xcl_s1, 16, xcl_s1, xcl_s0, xcl_s1_shift, offset_xcl[1])
    assign xcl_s2_shift = {xcl_s1[11:0], 4'b0};
    `MUX_2(u_xcl_s2, 16, xcl_s2, xcl_s1, xcl_s2_shift, offset_xcl[2])
    assign xcl_s3_shift = {xcl_s2[7:0], 8'b0};
    `MUX_2(u_xcl_s3, 16, xcl_s3, xcl_s2, xcl_s3_shift, offset_xcl[3])

    wire [15:0] mask_xcl;
    `INV_N(u_inv_xcl, 16, xcl_s3, mask_xcl)

    // ---- st_vec1 = ST_XCL ? mask_xcl : 16'h0 ----
    wire [15:0] zero16;
    assign zero16 = 16'h0;
    `MUX_2(u_mux_vec1, 16, st_vec1, zero16, mask_xcl, ST_XCL)

endmodule
