`include "STDCell_Macros.vh"

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
    assign seg0_data_shl16[15:0]  = 16'h0000;
    assign seg0_data_shl16[31:16] = seg0_data[15:0];

    //=========================================================================
    // real_seg1_data = seg1_valid ? seg1_data : seg0_data
    //=========================================================================
    `MUX_2(mux_real_seg1_data, 32, real_seg1_data, seg0_data, seg1_data, seg1_valid)

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
    wire [31:0] displacement_sext_8b, displacement_out;
    assign displacement_sext_8b[7:0]  = displacement[7:0];
    assign displacement_sext_8b[31:8] = {24{displacement[7]}};

    `MUX_4(mux_disp_out, 32, displacement_out,
           32'b0, 32'b0, displacement_sext_8b, displacement,
           {disp_needed, dispsize})

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
    wire [31:0] sib_or_reg;
    `MUX_4(mux_sib_or_reg, 32, sib_or_reg,
           register_data, 32'b0, sib_nonsense, sib_nonsense,
           {sib_needed, special_modrm_bs})

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
