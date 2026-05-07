
//=============================================================================
// npu_node1 - structural Verilog 2005 port of npu_node1.sv
//
// Address-generation block for the RR stage.  Computes load/store virtual
// addresses (ld_vaddy / actual_st_vaddy), linear addresses
// (ld_laddy / actual_st_laddy), the next-page virtual address for TLB
// (next_ld_vaddy / actual_next_st_vaddy), and the seg0/seg1 limit values
// adjusted for the access datasize.
//
// Interface change vs. SV:
//   segment0_limit / segment1_limit (segment_limit_reg_entry_t struct
//   containing a single uint32_t .limit field) are unrolled into 32-bit
//   wires segment0_limit_data / segment1_limit_data.
//
// Implementation notes:
//   - SIB_SCALE_val in practice is 0..3 (per Decode/sib_processor.sv);
//     the variable shift << SIB_SCALE_val collapses to a 4:1 mux of the
//     four fixed shifts of SIB_IDX_data.
//   - All << 16 shifts are constant and become pure rewiring.
//   - All subtractions become "ADD with constant two's-complement value"
//     (limit - K = limit + (~K + 1)).  K=1,3,7 -> 0xFFFFFFFF, FD, F9.
//   - Sign extension uses bit replication (wire broadcasting, not an op).
//   - VPN bits are [31:12] (20-bit), page offset is [11:0] (12-bit).
//=============================================================================

module npu_node1 (
    input  wire [31:0] register_data,
    input  wire [31:0] regout_sr_data,
    input  wire [31:0] regout_dr_data,
    input  wire [31:0] SIB_IDX_data,
    input  wire [31:0] SIB_BASE_data,
    input  wire [7:0]  SIB_SCALE_val,
    input  wire        sib_needed,
    input  wire        disp_needed,
    input  wire        dispsize,
    input  wire        special_modrm_bs,
    input  wire [31:0] displacement,

    input  wire [1:0]  datasize,

    input  wire [31:0] seg0_data,
    input  wire [31:0] segment0_limit_data,   // unrolled from segment_limit_reg_entry_t
    input  wire [31:0] seg1_data,
    input  wire [31:0] segment1_limit_data,   // unrolled
    input  wire        seg1_valid,

    input  wire        modrm_needed,          // unused (matches original SV)
    input  wire        rm_is_dr,              // unused (matches original SV)
    input  wire        st_sel,
    input  wire        movs_op,
    input  wire        switch_ld_addy,
    input  wire        special_br,

    output wire [31:0] ld_vaddy,
    output wire [31:0] seg0_limit_w_datasize,
    output wire [31:0] seg0_limit_wo_datasize,
    output wire [31:0] next_ld_vaddy,
    output wire [31:0] ld_laddy,

    output wire [31:0] actual_st_vaddy,
    output wire [31:0] seg1_limit_w_datasize,
    output wire [31:0] seg1_limit_wo_datasize,
    output wire [31:0] actual_next_st_vaddy,
    output wire [31:0] actual_st_laddy
);

    //=========================================================================
    // Constant shift helpers ( x << 16 )
    //   Just rewire: result[15:0] = 0, result[31:16] = x[15:0].
    //=========================================================================
    wire [31:0] seg0_data_shl16, real_seg1_data, real_seg1_data_shl16;
    wire [31:0] real_seg1_data_pre;
    assign seg0_data_shl16[15:0]  = 16'h0000;
    assign seg0_data_shl16[31:16] = seg0_data[15:0];

    //=========================================================================
    // real_seg1_data = seg1_valid ? seg1_data : seg0_data
    //=========================================================================
    `MUX_2(mux_real_seg1_data, 32, real_seg1_data_pre, seg0_data, seg1_data, seg1_valid)
    bufferH16$ u_buf_real_seg1_data_0  (.out(real_seg1_data[0]),  .in(real_seg1_data_pre[0]));
    bufferH16$ u_buf_real_seg1_data_1  (.out(real_seg1_data[1]),  .in(real_seg1_data_pre[1]));
    bufferH16$ u_buf_real_seg1_data_2  (.out(real_seg1_data[2]),  .in(real_seg1_data_pre[2]));
    bufferH16$ u_buf_real_seg1_data_3  (.out(real_seg1_data[3]),  .in(real_seg1_data_pre[3]));
    bufferH16$ u_buf_real_seg1_data_4  (.out(real_seg1_data[4]),  .in(real_seg1_data_pre[4]));
    bufferH16$ u_buf_real_seg1_data_5  (.out(real_seg1_data[5]),  .in(real_seg1_data_pre[5]));
    bufferH16$ u_buf_real_seg1_data_6  (.out(real_seg1_data[6]),  .in(real_seg1_data_pre[6]));
    bufferH16$ u_buf_real_seg1_data_7  (.out(real_seg1_data[7]),  .in(real_seg1_data_pre[7]));
    bufferH16$ u_buf_real_seg1_data_8  (.out(real_seg1_data[8]),  .in(real_seg1_data_pre[8]));
    bufferH16$ u_buf_real_seg1_data_9  (.out(real_seg1_data[9]),  .in(real_seg1_data_pre[9]));
    bufferH16$ u_buf_real_seg1_data_10 (.out(real_seg1_data[10]), .in(real_seg1_data_pre[10]));
    bufferH16$ u_buf_real_seg1_data_11 (.out(real_seg1_data[11]), .in(real_seg1_data_pre[11]));
    bufferH16$ u_buf_real_seg1_data_12 (.out(real_seg1_data[12]), .in(real_seg1_data_pre[12]));
    bufferH16$ u_buf_real_seg1_data_13 (.out(real_seg1_data[13]), .in(real_seg1_data_pre[13]));
    bufferH16$ u_buf_real_seg1_data_14 (.out(real_seg1_data[14]), .in(real_seg1_data_pre[14]));
    bufferH16$ u_buf_real_seg1_data_15 (.out(real_seg1_data[15]), .in(real_seg1_data_pre[15]));
    bufferH16$ u_buf_real_seg1_data_16 (.out(real_seg1_data[16]), .in(real_seg1_data_pre[16]));
    bufferH16$ u_buf_real_seg1_data_17 (.out(real_seg1_data[17]), .in(real_seg1_data_pre[17]));
    bufferH16$ u_buf_real_seg1_data_18 (.out(real_seg1_data[18]), .in(real_seg1_data_pre[18]));
    bufferH16$ u_buf_real_seg1_data_19 (.out(real_seg1_data[19]), .in(real_seg1_data_pre[19]));
    bufferH16$ u_buf_real_seg1_data_20 (.out(real_seg1_data[20]), .in(real_seg1_data_pre[20]));
    bufferH16$ u_buf_real_seg1_data_21 (.out(real_seg1_data[21]), .in(real_seg1_data_pre[21]));
    bufferH16$ u_buf_real_seg1_data_22 (.out(real_seg1_data[22]), .in(real_seg1_data_pre[22]));
    bufferH16$ u_buf_real_seg1_data_23 (.out(real_seg1_data[23]), .in(real_seg1_data_pre[23]));
    bufferH16$ u_buf_real_seg1_data_24 (.out(real_seg1_data[24]), .in(real_seg1_data_pre[24]));
    bufferH16$ u_buf_real_seg1_data_25 (.out(real_seg1_data[25]), .in(real_seg1_data_pre[25]));
    bufferH16$ u_buf_real_seg1_data_26 (.out(real_seg1_data[26]), .in(real_seg1_data_pre[26]));
    bufferH16$ u_buf_real_seg1_data_27 (.out(real_seg1_data[27]), .in(real_seg1_data_pre[27]));
    bufferH16$ u_buf_real_seg1_data_28 (.out(real_seg1_data[28]), .in(real_seg1_data_pre[28]));
    bufferH16$ u_buf_real_seg1_data_29 (.out(real_seg1_data[29]), .in(real_seg1_data_pre[29]));
    bufferH16$ u_buf_real_seg1_data_30 (.out(real_seg1_data[30]), .in(real_seg1_data_pre[30]));
    bufferH16$ u_buf_real_seg1_data_31 (.out(real_seg1_data[31]), .in(real_seg1_data_pre[31]));

    assign real_seg1_data_shl16[15:0]  = 16'h0000;
    assign real_seg1_data_shl16[31:16] = real_seg1_data[15:0];

    //=========================================================================
    // shift_result = SIB_IDX_data << SIB_SCALE_val   (SIB_SCALE_val in {0,1,2,3})
    //   Implemented as a 4:1 mux of the four fixed shifts.
    //=========================================================================
    wire [31:0] sib_idx_shl0, sib_idx_shl1, sib_idx_shl2, sib_idx_shl3;
    wire [31:0] shift_result;

    assign sib_idx_shl0           = SIB_IDX_data;

    assign sib_idx_shl1[0]        = 1'b0;
    assign sib_idx_shl1[31:1]     = SIB_IDX_data[30:0];

    assign sib_idx_shl2[1:0]      = 2'b00;
    assign sib_idx_shl2[31:2]     = SIB_IDX_data[29:0];

    assign sib_idx_shl3[2:0]      = 3'b000;
    assign sib_idx_shl3[31:3]     = SIB_IDX_data[28:0];

    `MUX_4(mux_shift_result, 32, shift_result,
           sib_idx_shl0, sib_idx_shl1, sib_idx_shl2, sib_idx_shl3,
           SIB_SCALE_val[1:0])

    //=========================================================================
    // sib_nonsense = shift_result + SIB_BASE_data
    //=========================================================================
    wire [31:0] sib_nonsense;
    wire        cout_sib_nonsense;
    `ADD_N(add_sib_nonsense, 32, sib_nonsense, cout_sib_nonsense,
           shift_result, SIB_BASE_data, 1'b0)

    //=========================================================================
    // displacement_out (case on {disp_needed, dispsize})
    //   00, 01: 32'b0
    //   10    : sign-extend(displacement[7:0])
    //   11    : displacement (full 32b)
    //=========================================================================
    wire [31:0] displacement_sext_8b, displacement_out, displacement_out_pre;
    assign displacement_sext_8b[7:0]  = displacement[7:0];
    assign displacement_sext_8b[31:8] = {24{displacement[7]}};

    `MUX_4(mux_disp_out, 32, displacement_out_pre,
           32'b0, 32'b0, displacement_sext_8b, displacement,
           {disp_needed, dispsize})
    bufferH16$ u_buf_displacement_out_0  (.out(displacement_out[0]),  .in(displacement_out_pre[0]));
    bufferH16$ u_buf_displacement_out_1  (.out(displacement_out[1]),  .in(displacement_out_pre[1]));
    bufferH16$ u_buf_displacement_out_2  (.out(displacement_out[2]),  .in(displacement_out_pre[2]));
    bufferH16$ u_buf_displacement_out_3  (.out(displacement_out[3]),  .in(displacement_out_pre[3]));
    bufferH16$ u_buf_displacement_out_4  (.out(displacement_out[4]),  .in(displacement_out_pre[4]));
    bufferH16$ u_buf_displacement_out_5  (.out(displacement_out[5]),  .in(displacement_out_pre[5]));
    bufferH16$ u_buf_displacement_out_6  (.out(displacement_out[6]),  .in(displacement_out_pre[6]));
    bufferH16$ u_buf_displacement_out_7  (.out(displacement_out[7]),  .in(displacement_out_pre[7]));
    bufferH16$ u_buf_displacement_out_8  (.out(displacement_out[8]),  .in(displacement_out_pre[8]));
    bufferH16$ u_buf_displacement_out_9  (.out(displacement_out[9]),  .in(displacement_out_pre[9]));
    bufferH16$ u_buf_displacement_out_10 (.out(displacement_out[10]), .in(displacement_out_pre[10]));
    bufferH16$ u_buf_displacement_out_11 (.out(displacement_out[11]), .in(displacement_out_pre[11]));
    bufferH16$ u_buf_displacement_out_12 (.out(displacement_out[12]), .in(displacement_out_pre[12]));
    bufferH16$ u_buf_displacement_out_13 (.out(displacement_out[13]), .in(displacement_out_pre[13]));
    bufferH16$ u_buf_displacement_out_14 (.out(displacement_out[14]), .in(displacement_out_pre[14]));
    bufferH16$ u_buf_displacement_out_15 (.out(displacement_out[15]), .in(displacement_out_pre[15]));
    bufferH16$ u_buf_displacement_out_16 (.out(displacement_out[16]), .in(displacement_out_pre[16]));
    bufferH16$ u_buf_displacement_out_17 (.out(displacement_out[17]), .in(displacement_out_pre[17]));
    bufferH16$ u_buf_displacement_out_18 (.out(displacement_out[18]), .in(displacement_out_pre[18]));
    bufferH16$ u_buf_displacement_out_19 (.out(displacement_out[19]), .in(displacement_out_pre[19]));
    bufferH16$ u_buf_displacement_out_20 (.out(displacement_out[20]), .in(displacement_out_pre[20]));
    bufferH16$ u_buf_displacement_out_21 (.out(displacement_out[21]), .in(displacement_out_pre[21]));
    bufferH16$ u_buf_displacement_out_22 (.out(displacement_out[22]), .in(displacement_out_pre[22]));
    bufferH16$ u_buf_displacement_out_23 (.out(displacement_out[23]), .in(displacement_out_pre[23]));
    bufferH16$ u_buf_displacement_out_24 (.out(displacement_out[24]), .in(displacement_out_pre[24]));
    bufferH16$ u_buf_displacement_out_25 (.out(displacement_out[25]), .in(displacement_out_pre[25]));
    bufferH16$ u_buf_displacement_out_26 (.out(displacement_out[26]), .in(displacement_out_pre[26]));
    bufferH16$ u_buf_displacement_out_27 (.out(displacement_out[27]), .in(displacement_out_pre[27]));
    bufferH16$ u_buf_displacement_out_28 (.out(displacement_out[28]), .in(displacement_out_pre[28]));
    bufferH16$ u_buf_displacement_out_29 (.out(displacement_out[29]), .in(displacement_out_pre[29]));
    bufferH16$ u_buf_displacement_out_30 (.out(displacement_out[30]), .in(displacement_out_pre[30]));
    bufferH16$ u_buf_displacement_out_31 (.out(displacement_out[31]), .in(displacement_out_pre[31]));

    //=========================================================================
    // masked_displacement_out = switch_ld_addy ? 32'b0 : displacement_out
    //=========================================================================
    wire [31:0] masked_displacement_out;
    `MUX_2(mux_masked_disp, 32, masked_displacement_out,
           displacement_out, 32'b0, switch_ld_addy)

    //=========================================================================
    // seg0val_plus_displacement = masked_displacement_out + (seg0_data << 16)
    // seg1val_plus_displacement = displacement_out         + (real_seg1_data << 16)
    //=========================================================================
    wire [31:0] seg0val_plus_displacement, seg1val_plus_displacement;
    wire        cout_seg0val_plus_displacement, cout_seg1val_plus_displacement;
    `ADD_N(add_seg0val_plus_disp, 32, seg0val_plus_displacement,
           cout_seg0val_plus_displacement,
           masked_displacement_out, seg0_data_shl16, 1'b0)
    `ADD_N(add_seg1val_plus_disp, 32, seg1val_plus_displacement,
           cout_seg1val_plus_displacement,
           displacement_out, real_seg1_data_shl16, 1'b0)

    //=========================================================================
    // sib_or_reg (case on {sib_needed, special_modrm_bs})
    //   00: register_data
    //   01: 32'b0
    //   10: sib_nonsense
    //   11: sib_nonsense
    //=========================================================================
    wire [31:0] sib_or_reg, sib_or_reg_pre;
    `MUX_4(mux_sib_or_reg, 32, sib_or_reg_pre,
           register_data, 32'b0, sib_nonsense, sib_nonsense,
           {sib_needed, special_modrm_bs})
    bufferH16$ u_buf_sib_or_reg_0  (.out(sib_or_reg[0]),  .in(sib_or_reg_pre[0]));
    bufferH16$ u_buf_sib_or_reg_1  (.out(sib_or_reg[1]),  .in(sib_or_reg_pre[1]));
    bufferH16$ u_buf_sib_or_reg_2  (.out(sib_or_reg[2]),  .in(sib_or_reg_pre[2]));
    bufferH16$ u_buf_sib_or_reg_3  (.out(sib_or_reg[3]),  .in(sib_or_reg_pre[3]));
    bufferH16$ u_buf_sib_or_reg_4  (.out(sib_or_reg[4]),  .in(sib_or_reg_pre[4]));
    bufferH16$ u_buf_sib_or_reg_5  (.out(sib_or_reg[5]),  .in(sib_or_reg_pre[5]));
    bufferH16$ u_buf_sib_or_reg_6  (.out(sib_or_reg[6]),  .in(sib_or_reg_pre[6]));
    bufferH16$ u_buf_sib_or_reg_7  (.out(sib_or_reg[7]),  .in(sib_or_reg_pre[7]));
    bufferH16$ u_buf_sib_or_reg_8  (.out(sib_or_reg[8]),  .in(sib_or_reg_pre[8]));
    bufferH16$ u_buf_sib_or_reg_9  (.out(sib_or_reg[9]),  .in(sib_or_reg_pre[9]));
    bufferH16$ u_buf_sib_or_reg_10 (.out(sib_or_reg[10]), .in(sib_or_reg_pre[10]));
    bufferH16$ u_buf_sib_or_reg_11 (.out(sib_or_reg[11]), .in(sib_or_reg_pre[11]));
    bufferH16$ u_buf_sib_or_reg_12 (.out(sib_or_reg[12]), .in(sib_or_reg_pre[12]));
    bufferH16$ u_buf_sib_or_reg_13 (.out(sib_or_reg[13]), .in(sib_or_reg_pre[13]));
    bufferH16$ u_buf_sib_or_reg_14 (.out(sib_or_reg[14]), .in(sib_or_reg_pre[14]));
    bufferH16$ u_buf_sib_or_reg_15 (.out(sib_or_reg[15]), .in(sib_or_reg_pre[15]));
    bufferH16$ u_buf_sib_or_reg_16 (.out(sib_or_reg[16]), .in(sib_or_reg_pre[16]));
    bufferH16$ u_buf_sib_or_reg_17 (.out(sib_or_reg[17]), .in(sib_or_reg_pre[17]));
    bufferH16$ u_buf_sib_or_reg_18 (.out(sib_or_reg[18]), .in(sib_or_reg_pre[18]));
    bufferH16$ u_buf_sib_or_reg_19 (.out(sib_or_reg[19]), .in(sib_or_reg_pre[19]));
    bufferH16$ u_buf_sib_or_reg_20 (.out(sib_or_reg[20]), .in(sib_or_reg_pre[20]));
    bufferH16$ u_buf_sib_or_reg_21 (.out(sib_or_reg[21]), .in(sib_or_reg_pre[21]));
    bufferH16$ u_buf_sib_or_reg_22 (.out(sib_or_reg[22]), .in(sib_or_reg_pre[22]));
    bufferH16$ u_buf_sib_or_reg_23 (.out(sib_or_reg[23]), .in(sib_or_reg_pre[23]));
    bufferH16$ u_buf_sib_or_reg_24 (.out(sib_or_reg[24]), .in(sib_or_reg_pre[24]));
    bufferH16$ u_buf_sib_or_reg_25 (.out(sib_or_reg[25]), .in(sib_or_reg_pre[25]));
    bufferH16$ u_buf_sib_or_reg_26 (.out(sib_or_reg[26]), .in(sib_or_reg_pre[26]));
    bufferH16$ u_buf_sib_or_reg_27 (.out(sib_or_reg[27]), .in(sib_or_reg_pre[27]));
    bufferH16$ u_buf_sib_or_reg_28 (.out(sib_or_reg[28]), .in(sib_or_reg_pre[28]));
    bufferH16$ u_buf_sib_or_reg_29 (.out(sib_or_reg[29]), .in(sib_or_reg_pre[29]));
    bufferH16$ u_buf_sib_or_reg_30 (.out(sib_or_reg[30]), .in(sib_or_reg_pre[30]));
    bufferH16$ u_buf_sib_or_reg_31 (.out(sib_or_reg[31]), .in(sib_or_reg_pre[31]));

    //=========================================================================
    // ld_addy_reg_data = switch_ld_addy ? regout_sr_data : sib_or_reg
    //=========================================================================
    wire [31:0] ld_addy_reg_data;
    `MUX_2(mux_ld_addy_reg_data, 32, ld_addy_reg_data,
           sib_or_reg, regout_sr_data, switch_ld_addy)

    //=========================================================================
    // ld_addy_reg_data_plus_displacement = ld_addy_reg_data + seg0val_plus_displacement
    //=========================================================================
    wire [31:0] ld_addy_reg_data_plus_displacement;
    wire        cout_ld_addy_reg_data_plus_displacement;
    `ADD_N(add_ld_addy_reg_plus_disp, 32, ld_addy_reg_data_plus_displacement,
           cout_ld_addy_reg_data_plus_displacement,
           ld_addy_reg_data, seg0val_plus_displacement, 1'b0)

    //=========================================================================
    // ld_vaddy = special_br ? regout_dr_data : ld_addy_reg_data_plus_displacement
    //=========================================================================
    `MUX_2(mux_ld_vaddy, 32, ld_vaddy,
           ld_addy_reg_data_plus_displacement, regout_dr_data, special_br)

    //=========================================================================
    // st_vaddy   = sib_or_reg + seg1val_plus_displacement
    // ld_laddy   = ld_addy_reg_data + masked_displacement_out
    // st_laddy   = sib_or_reg + displacement_out
    //=========================================================================
    wire [31:0] st_vaddy, st_laddy;
    wire        cout_st_vaddy, cout_ld_laddy, cout_st_laddy;
    `ADD_N(add_st_vaddy, 32, st_vaddy, cout_st_vaddy,
           sib_or_reg, seg1val_plus_displacement, 1'b0)
    `ADD_N(add_ld_laddy, 32, ld_laddy, cout_ld_laddy,
           ld_addy_reg_data, masked_displacement_out, 1'b0)
    `ADD_N(add_st_laddy, 32, st_laddy, cout_st_laddy,
           sib_or_reg, displacement_out, 1'b0)

    //=========================================================================
    // shifted_sr_data = regout_sr_data + (real_seg1_data << 16)
    // shifted_dr_data = regout_dr_data + (real_seg1_data << 16)
    //=========================================================================
    wire [31:0] shifted_sr_data, shifted_dr_data;
    wire        cout_shifted_sr_data, cout_shifted_dr_data;
    `ADD_N(add_shifted_sr, 32, shifted_sr_data, cout_shifted_sr_data,
           regout_sr_data, real_seg1_data_shl16, 1'b0)
    `ADD_N(add_shifted_dr, 32, shifted_dr_data, cout_shifted_dr_data,
           regout_dr_data, real_seg1_data_shl16, 1'b0)

    //=========================================================================
    // actual_st_vaddy = st_sel ? (movs_op ? shifted_dr_data : shifted_sr_data)
    //                          :  st_vaddy
    //=========================================================================
    wire [31:0] st_vaddy_movs_pick;
    `MUX_2(mux_st_vaddy_movs, 32, st_vaddy_movs_pick,
           shifted_sr_data, shifted_dr_data, movs_op)
    `MUX_2(mux_actual_st_vaddy, 32, actual_st_vaddy,
           st_vaddy, st_vaddy_movs_pick, st_sel)

    //=========================================================================
    // actual_st_laddy = st_sel ? (movs_op ? regout_dr_data : regout_sr_data)
    //                          :  st_laddy
    //=========================================================================
    wire [31:0] st_laddy_movs_pick;
    `MUX_2(mux_st_laddy_movs, 32, st_laddy_movs_pick,
           regout_sr_data, regout_dr_data, movs_op)
    `MUX_2(mux_actual_st_laddy, 32, actual_st_laddy,
           st_laddy, st_laddy_movs_pick, st_sel)

    //=========================================================================
    // seg0_limit_w_datasize = limit - { 0, 1, 3, 7 } based on datasize[1:0]
    //   Implement as MUX_4 selecting the (negative-of-K) constant, then ADD.
    //   datasize 00 -> 0; 01 -> -1=0xFFFFFFFF; 10 -> -3=0xFFFFFFFD; 11 -> -7=0xFFFFFFF9
    //=========================================================================
    wire [31:0] seg0_limit_delta;
    wire        cout_seg0_limit_w_datasize;
    `MUX_4(mux_seg0_limit_delta, 32, seg0_limit_delta,
           32'h0000_0000, 32'hFFFF_FFFF, 32'hFFFF_FFFD, 32'hFFFF_FFF9,
           datasize)
    `ADD_N(add_seg0_limit_w_datasize, 32, seg0_limit_w_datasize,
           cout_seg0_limit_w_datasize,
           segment0_limit_data, seg0_limit_delta, 1'b0)

    //=========================================================================
    // seg1_limit_w_datasize_temp same structure on segment1_limit_data
    //=========================================================================
    wire [31:0] seg1_limit_delta, seg1_limit_w_datasize_temp;
    wire        cout_seg1_limit_w_datasize_temp;
    `MUX_4(mux_seg1_limit_delta, 32, seg1_limit_delta,
           32'h0000_0000, 32'hFFFF_FFFF, 32'hFFFF_FFFD, 32'hFFFF_FFF9,
           datasize)
    `ADD_N(add_seg1_limit_w_datasize_temp, 32, seg1_limit_w_datasize_temp,
           cout_seg1_limit_w_datasize_temp,
           segment1_limit_data, seg1_limit_delta, 1'b0)

    //=========================================================================
    // seg0_limit_wo_datasize = segment0_limit_data
    // seg1_limit_wo_datasize = seg1_valid ? segment1_limit_data : segment0_limit_data
    // seg1_limit_w_datasize  = seg1_valid ? seg1_limit_w_datasize_temp : seg0_limit_w_datasize
    //=========================================================================
    assign seg0_limit_wo_datasize = segment0_limit_data;

    `MUX_2(mux_seg1_limit_wo_datasize, 32, seg1_limit_wo_datasize,
           segment0_limit_data, segment1_limit_data, seg1_valid)

    `MUX_2(mux_seg1_limit_w_datasize, 32, seg1_limit_w_datasize,
           seg0_limit_w_datasize, seg1_limit_w_datasize_temp, seg1_valid)

    //=========================================================================
    // Next-page VPNs
    //   next_*_VPN[19:0] = base_vpn[19:0] + addend_vpn[19:0] + 1
    //   We feed cin=1'b1 into ADD_N and avoid any explicit "+1" arithmetic.
    //   The page-offset bits of the resulting next_*_vaddy are tied to zero.
    //=========================================================================

    // ---- next_ld_vaddy ----
    wire [19:0] next_ld_VPN;
    wire        cout_next_ld_VPN;
    `ADD_N(add_next_ld_VPN, 20, next_ld_VPN, cout_next_ld_VPN,
           sib_or_reg[31:12], seg0val_plus_displacement[31:12], 1'b1)
    assign next_ld_vaddy[11:0]  = 12'h000;
    assign next_ld_vaddy[31:12] = next_ld_VPN;

    // ---- next_st_vaddy (the "non-st_sel" path) ----
    wire [19:0] next_st_VPN;
    wire [31:0] next_st_vaddy;
    wire        cout_next_st_VPN;
    `ADD_N(add_next_st_VPN, 20, next_st_VPN, cout_next_st_VPN,
           sib_or_reg[31:12], seg1val_plus_displacement[31:12], 1'b1)
    assign next_st_vaddy[11:0]  = 12'h000;
    assign next_st_vaddy[31:12] = next_st_VPN;

    // ---- next_shifted_sr_data ----
    wire [19:0] next_shifted_sr_VPN;
    wire [31:0] next_shifted_sr_data;
    wire        cout_next_shifted_sr_VPN;
    `ADD_N(add_next_shifted_sr_VPN, 20, next_shifted_sr_VPN, cout_next_shifted_sr_VPN,
           regout_sr_data[31:12], real_seg1_data_shl16[31:12], 1'b1)
    assign next_shifted_sr_data[11:0]  = 12'h000;
    assign next_shifted_sr_data[31:12] = next_shifted_sr_VPN;

    // ---- next_shifted_dr_data ----
    wire [19:0] next_shifted_dr_VPN;
    wire [31:0] next_shifted_dr_data;
    wire        cout_next_shifted_dr_VPN;
    `ADD_N(add_next_shifted_dr_VPN, 20, next_shifted_dr_VPN, cout_next_shifted_dr_VPN,
           regout_dr_data[31:12], real_seg1_data_shl16[31:12], 1'b1)
    assign next_shifted_dr_data[11:0]  = 12'h000;
    assign next_shifted_dr_data[31:12] = next_shifted_dr_VPN;

    //=========================================================================
    // actual_next_st_vaddy = st_sel ? (movs_op ? next_shifted_dr_data
    //                                          : next_shifted_sr_data)
    //                               :  next_st_vaddy
    //=========================================================================
    wire [31:0] next_st_vaddy_movs_pick;
    `MUX_2(mux_next_st_vaddy_movs, 32, next_st_vaddy_movs_pick,
           next_shifted_sr_data, next_shifted_dr_data, movs_op)
    `MUX_2(mux_actual_next_st_vaddy, 32, actual_next_st_vaddy,
           next_st_vaddy, next_st_vaddy_movs_pick, st_sel)

endmodule
