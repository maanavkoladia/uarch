
module modrm_processor (
    input  wire [7:0]              modrm_byte,
    input  wire [1:0]              datasize,

    // decode_cs_t inputs (struct flattened)
    input  wire                    cs_MODRM_NEEDED,
    input  wire                    cs_RM_IS_DR,
    input  wire                    cs_REG_IS_DR,
    input  wire                    cs_REG_IS_SEGMENT,
    input  wire                    cs_MODRM_BUT_NO_SR,
    input  wire                    cs_HARDCODED_DR,
    input  wire [`REG_ID_W-1:0]    cs_HARDCODED_DR_ID,
    input  wire                    cs_HARDCODED_DR_RD,
    input  wire                    cs_HARDCODED_DR_WR,
    input  wire                    cs_HARDCODED_DR_HIGH8,
    input  wire                    cs_HARDCODED_SR,
    input  wire [`REG_ID_W-1:0]    cs_HARDCODED_SR_ID,
    input  wire                    cs_HARDCODED_SR_RD,
    input  wire                    cs_HARDCODED_SR_WR,
    input  wire                    cs_HARDCODED_LD_OP,
    input  wire                    cs_HARDCODED_ST_OP,
    input  wire                    cs_LD_OP_CANCEL,
    input  wire                    cs_ST_OP_CANCEL,

    // modrm_processor_outs_t outputs (struct flattened)
    output wire [`REG_ID_W-1:0]    dr_id,
    output wire [`REG_ID_W-1:0]    sr_id,
    output wire                    dr_rd,
    output wire                    sr_rd,
    output wire                    dr_wr,
    output wire                    sr_wr,
    output wire                    st_op,
    output wire                    ld_op,
    output wire                    dr_high8,
    output wire                    sr_high8,
    output wire                    alu_inputA_override,
    output wire                    alu_inputB_override,
    output wire [`SRC_SEL_W-1:0]   alu_inputA_override_sel,
    output wire [`SRC_SEL_W-1:0]   alu_inputB_override_sel,
    output wire                    special_modrm_bs
);

    // =================================================================
    // Inverted versions of single-bit inputs / signals used downstream.
    // =================================================================
    wire n_datasize_1, n_datasize_0;
    `INV_N(u_inv_ds1, 1, datasize[1], n_datasize_1)
    `INV_N(u_inv_ds0, 1, datasize[0], n_datasize_0)

    wire n_modrm_7, n_modrm_6, n_modrm_1, n_modrm_0;
    `INV_N(u_inv_m7, 1, modrm_byte[7], n_modrm_7)
    `INV_N(u_inv_m6, 1, modrm_byte[6], n_modrm_6)
    `INV_N(u_inv_m1, 1, modrm_byte[1], n_modrm_1)
    `INV_N(u_inv_m0, 1, modrm_byte[0], n_modrm_0)

    wire n_cs_MODRM_NEEDED, n_cs_RM_IS_DR, n_cs_REG_IS_DR;
    wire n_cs_HARDCODED_SR, n_cs_LD_OP_CANCEL, n_cs_ST_OP_CANCEL;
    wire n_cs_MODRM_BUT_NO_SR;
    `INV_N(u_inv_modneed, 1, cs_MODRM_NEEDED,    n_cs_MODRM_NEEDED)
    `INV_N(u_inv_rmisdr,  1, cs_RM_IS_DR,        n_cs_RM_IS_DR)
    `INV_N(u_inv_regisdr, 1, cs_REG_IS_DR,       n_cs_REG_IS_DR)
    `INV_N(u_inv_hcsr,    1, cs_HARDCODED_SR,    n_cs_HARDCODED_SR)
    `INV_N(u_inv_ldcan,   1, cs_LD_OP_CANCEL,    n_cs_LD_OP_CANCEL)
    `INV_N(u_inv_stcan,   1, cs_ST_OP_CANCEL,    n_cs_ST_OP_CANCEL)
    `INV_N(u_inv_mbnsr,   1, cs_MODRM_BUT_NO_SR, n_cs_MODRM_BUT_NO_SR)

    // =================================================================
    // Datasize / mod / rm decode helpers
    // =================================================================
    wire is_mmx;        // datasize == 2'b11
    wire is_8bit;       // datasize == 2'b00
    wire mod_is_11;
    wire mod_is_00;
    wire n_mod_is_11;
    wire is_mmx_mod11;
    wire is_8bit_mod11;

    `AND_2(u_is_mmx,        1, is_mmx,        datasize[1], datasize[0])
    `AND_2(u_is_8bit,       1, is_8bit,       n_datasize_1, n_datasize_0)
    `AND_2(u_mod_is_11,     1, mod_is_11,     modrm_byte[7], modrm_byte[6])
    `AND_2(u_mod_is_00,     1, mod_is_00,     n_modrm_7, n_modrm_6)
    `INV_N(u_inv_mod11,     1, mod_is_11,     n_mod_is_11)
    `AND_2(u_is_mmx_mod11,  1, is_mmx_mod11,  is_mmx,  mod_is_11)
    `AND_2(u_is_8bit_mod11, 1, is_8bit_mod11, is_8bit, mod_is_11)

    // rm == 3'b100 / 3'b101
    wire rm_is_100, rm_is_101;
    `AND_3(u_rm100, 1, rm_is_100, modrm_byte[2], n_modrm_1, n_modrm_0)
    `AND_3(u_rm101, 1, rm_is_101, modrm_byte[2], n_modrm_1, modrm_byte[0])

    // special_pattern = (rm==100 & mod!=11) | (mod==00 & rm==101)
    wire sp_term0, sp_term1, special_pattern, n_special_pattern;
    `AND_2(u_sp_t0, 1, sp_term0, rm_is_100, n_mod_is_11)
    `AND_2(u_sp_t1, 1, sp_term1, mod_is_00, rm_is_101)
    `OR_2 (u_sp_or, 1, special_pattern, sp_term0, sp_term1)
    `INV_N(u_inv_sp, 1, special_pattern, n_special_pattern)

    // =================================================================
    // High-level decode state
    // =================================================================
    wire rm_is_dr, reg_is_dr, reg_is_segment;
    wire n_reg_is_segment;

    `AND_3(u_rm_is_dr,  1, rm_is_dr,
           cs_MODRM_NEEDED, cs_RM_IS_DR,   n_cs_REG_IS_DR)
    `AND_3(u_reg_is_dr, 1, reg_is_dr,
           cs_MODRM_NEEDED, n_cs_RM_IS_DR, cs_REG_IS_DR)
    `AND_2(u_reg_is_seg, 1, reg_is_segment,
           cs_MODRM_NEEDED, cs_REG_IS_SEGMENT)
    `INV_N(u_inv_regseg, 1, reg_is_segment, n_reg_is_segment)

    // =================================================================
    // dr_id / sr_id branch-active flags
    // =================================================================
    wire dr_b1, dr_b2, dr_b3, dr_b4;
    wire sr_b1, sr_b2, sr_b3, sr_b4;

    `AND_2(u_dr_b1, 1, dr_b1, rm_is_dr,  n_special_pattern)
    `AND_2(u_dr_b2, 1, dr_b2, reg_is_dr, n_reg_is_segment)
    `AND_2(u_dr_b3, 1, dr_b3, reg_is_segment, reg_is_dr)
    `AND_2(u_dr_b4, 1, dr_b4, n_cs_MODRM_NEEDED, cs_HARDCODED_DR)

    `AND_4(u_sr_b1, 1, sr_b1,
           rm_is_dr, n_reg_is_segment, n_cs_MODRM_BUT_NO_SR, n_cs_HARDCODED_SR)
    `AND_2(u_sr_b2, 1, sr_b2, reg_is_dr, n_special_pattern)
    `AND_2(u_sr_b3, 1, sr_b3, reg_is_segment, rm_is_dr)
    assign sr_b4 = cs_HARDCODED_SR;

    // =================================================================
    // Lookup A: case(modrm_byte[2:0]), candidates depend on (mod==11)
    //   n=0..3: is_mmx_mod11 ? MMn : <gpr>
    //   n=4..7: is_mmx_mod11 ? MMn : (is_8bit_mod11 ? <8b alias> : <full gpr>)
    // =================================================================
    wire [`REG_ID_W-1:0] A_id0, A_id1, A_id2, A_id3;
    wire [`REG_ID_W-1:0] A_id4, A_id5, A_id6, A_id7;
    wire [`REG_ID_W-1:0] A_id4_inner, A_id5_inner, A_id6_inner, A_id7_inner;

    `MUX_2(u_A_id0, `REG_ID_W, A_id0, `EAX, `MM0, is_mmx_mod11)
    `MUX_2(u_A_id1, `REG_ID_W, A_id1, `ECX, `MM1, is_mmx_mod11)
    `MUX_2(u_A_id2, `REG_ID_W, A_id2, `EDX, `MM2, is_mmx_mod11)
    `MUX_2(u_A_id3, `REG_ID_W, A_id3, `EBX, `MM3, is_mmx_mod11)

    `MUX_2(u_A_id4_in, `REG_ID_W, A_id4_inner, `ESP, `EAX, is_8bit_mod11)
    `MUX_2(u_A_id5_in, `REG_ID_W, A_id5_inner, `EBP, `ECX, is_8bit_mod11)
    `MUX_2(u_A_id6_in, `REG_ID_W, A_id6_inner, `ESI, `EDX, is_8bit_mod11)
    `MUX_2(u_A_id7_in, `REG_ID_W, A_id7_inner, `EDI, `EBX, is_8bit_mod11)

    `MUX_2(u_A_id4, `REG_ID_W, A_id4, A_id4_inner, `MM4, is_mmx_mod11)
    `MUX_2(u_A_id5, `REG_ID_W, A_id5, A_id5_inner, `MM5, is_mmx_mod11)
    `MUX_2(u_A_id6, `REG_ID_W, A_id6, A_id6_inner, `MM6, is_mmx_mod11)
    `MUX_2(u_A_id7, `REG_ID_W, A_id7, A_id7_inner, `MM7, is_mmx_mod11)

    wire [`REG_ID_W-1:0] lookup_A_id;
    `MUX_8(u_lookupA_id, `REG_ID_W, lookup_A_id,
           A_id0, A_id1, A_id2, A_id3, A_id4, A_id5, A_id6, A_id7,
           modrm_byte[2:0])

    // high8 set only for indices 4..7 (rm bit2 == 1) and only when 8b & mod==11
    wire lookup_A_high8;
    `AND_2(u_A_high8, 1, lookup_A_high8, is_8bit_mod11, modrm_byte[2])

    // =================================================================
    // Lookup B: case(modrm_byte[5:3]), no mod==11 conditioning
    // =================================================================
    wire [`REG_ID_W-1:0] B_id0, B_id1, B_id2, B_id3;
    wire [`REG_ID_W-1:0] B_id4, B_id5, B_id6, B_id7;
    wire [`REG_ID_W-1:0] B_id4_inner, B_id5_inner, B_id6_inner, B_id7_inner;

    `MUX_2(u_B_id0, `REG_ID_W, B_id0, `EAX, `MM0, is_mmx)
    `MUX_2(u_B_id1, `REG_ID_W, B_id1, `ECX, `MM1, is_mmx)
    `MUX_2(u_B_id2, `REG_ID_W, B_id2, `EDX, `MM2, is_mmx)
    `MUX_2(u_B_id3, `REG_ID_W, B_id3, `EBX, `MM3, is_mmx)

    `MUX_2(u_B_id4_in, `REG_ID_W, B_id4_inner, `ESP, `EAX, is_8bit)
    `MUX_2(u_B_id5_in, `REG_ID_W, B_id5_inner, `EBP, `ECX, is_8bit)
    `MUX_2(u_B_id6_in, `REG_ID_W, B_id6_inner, `ESI, `EDX, is_8bit)
    `MUX_2(u_B_id7_in, `REG_ID_W, B_id7_inner, `EDI, `EBX, is_8bit)

    `MUX_2(u_B_id4, `REG_ID_W, B_id4, B_id4_inner, `MM4, is_mmx)
    `MUX_2(u_B_id5, `REG_ID_W, B_id5, B_id5_inner, `MM5, is_mmx)
    `MUX_2(u_B_id6, `REG_ID_W, B_id6, B_id6_inner, `MM6, is_mmx)
    `MUX_2(u_B_id7, `REG_ID_W, B_id7, B_id7_inner, `MM7, is_mmx)

    wire [`REG_ID_W-1:0] lookup_B_id;
    `MUX_8(u_lookupB_id, `REG_ID_W, lookup_B_id,
           B_id0, B_id1, B_id2, B_id3, B_id4, B_id5, B_id6, B_id7,
           modrm_byte[5:3])

    wire lookup_B_high8;
    `AND_2(u_B_high8, 1, lookup_B_high8, is_8bit, modrm_byte[5])

    // =================================================================
    // Segment lookup: case(modrm_byte[5:3])
    //   0:ES 1:CS 2:SS 3:DS 4:FS 5:GS 6:NO_REG 7:NO_REG
    // =================================================================
    wire [`REG_ID_W-1:0] lookup_seg_id;
    `MUX_8(u_lookup_seg, `REG_ID_W, lookup_seg_id,
           `ES, `CS, `SS, `DS, `FS, `GS, `NO_REG, `NO_REG,
           modrm_byte[5:3])

    // =================================================================
    // dr_id priority cascade: b1 ? A : b2 ? B : b3 ? Seg : b4 ? HC : NO_REG
    // =================================================================
    wire [`REG_ID_W-1:0] dr_id_s0, dr_id_s1, dr_id_s2;
    `MUX_2(u_dr_id_s0, `REG_ID_W, dr_id_s0, `NO_REG,  cs_HARDCODED_DR_ID, dr_b4)
    `MUX_2(u_dr_id_s1, `REG_ID_W, dr_id_s1, dr_id_s0, lookup_seg_id,      dr_b3)
    `MUX_2(u_dr_id_s2, `REG_ID_W, dr_id_s2, dr_id_s1, lookup_B_id,        dr_b2)
    `MUX_2(u_dr_id_s3, `REG_ID_W, dr_id,    dr_id_s2, lookup_A_id,        dr_b1)

    // =================================================================
    // sr_id priority cascade: b1 ? B : b2 ? A : b3 ? Seg : b4 ? HC : NO_REG
    // =================================================================
    wire [`REG_ID_W-1:0] sr_id_s0, sr_id_s1, sr_id_s2;
    `MUX_2(u_sr_id_s0, `REG_ID_W, sr_id_s0, `NO_REG,  cs_HARDCODED_SR_ID, sr_b4)
    `MUX_2(u_sr_id_s1, `REG_ID_W, sr_id_s1, sr_id_s0, lookup_seg_id,      sr_b3)
    `MUX_2(u_sr_id_s2, `REG_ID_W, sr_id_s2, sr_id_s1, lookup_A_id,        sr_b2)
    `MUX_2(u_sr_id_s3, `REG_ID_W, sr_id,    sr_id_s2, lookup_B_id,        sr_b1)

    // =================================================================
    // dr_high8 = (dr_b1 & A_high8) | (dr_b2 & B_high8) | (dr_b4 & HC_DR_HIGH8)
    // =================================================================
    wire dr_h8_t0, dr_h8_t1, dr_h8_t2;
    `AND_2(u_dr_h8_t0, 1, dr_h8_t0, dr_b1, lookup_A_high8)
    `AND_2(u_dr_h8_t1, 1, dr_h8_t1, dr_b2, lookup_B_high8)
    `AND_2(u_dr_h8_t2, 1, dr_h8_t2, dr_b4, cs_HARDCODED_DR_HIGH8)
    `OR_3 (u_dr_h8,    1, dr_high8, dr_h8_t0, dr_h8_t1, dr_h8_t2)

    // sr_high8 = (sr_b1 & B_high8) | (sr_b2 & A_high8)
    wire sr_h8_t0, sr_h8_t1;
    `AND_2(u_sr_h8_t0, 1, sr_h8_t0, sr_b1, lookup_B_high8)
    `AND_2(u_sr_h8_t1, 1, sr_h8_t1, sr_b2, lookup_A_high8)
    `OR_2 (u_sr_h8,    1, sr_high8, sr_h8_t0, sr_h8_t1)

    // =================================================================
    // dr_rd / dr_wr / sr_rd / sr_wr
    // =================================================================
    wire dr_rd_t3;                       // dr_b4 & HC_DR_RD
    wire dr_wr_t0, dr_wr_t3;             // dr_b1 & mod==11; dr_b4 & HC_DR_WR
    wire sr_rd_t3;                       // sr_b4 & HC_SR_RD

    `AND_2(u_dr_rd_t3, 1, dr_rd_t3, dr_b4, cs_HARDCODED_DR_RD)
    `OR_4 (u_dr_rd,    1, dr_rd,    dr_b1, dr_b2, dr_b3, dr_rd_t3)

    `AND_2(u_dr_wr_t0, 1, dr_wr_t0, dr_b1, mod_is_11)
    `AND_2(u_dr_wr_t3, 1, dr_wr_t3, dr_b4, cs_HARDCODED_DR_WR)
    `OR_4 (u_dr_wr,    1, dr_wr,    dr_wr_t0, dr_b2, dr_b3, dr_wr_t3)

    `AND_2(u_sr_rd_t3, 1, sr_rd_t3, sr_b4, cs_HARDCODED_SR_RD)
    `OR_4 (u_sr_rd,    1, sr_rd,    sr_b1, sr_b2, sr_b3, sr_rd_t3)

    `AND_2(u_sr_wr,    1, sr_wr,    sr_b4, cs_HARDCODED_SR_WR)

    // =================================================================
    // Load / store op generation
    //   ld_op_unmasked = (mod!=11 & MODRM_NEEDED) | HARDCODED_LD_OP
    //   st_op_unmasked = (rm_is_dr & mod!=11)     | HARDCODED_ST_OP
    //   ld_op = ld_op_unmasked & ~LD_OP_CANCEL
    //   st_op = st_op_unmasked & ~ST_OP_CANCEL
    // =================================================================
    wire ld_op_t0, ld_op_unmasked;
    wire st_op_t0, st_op_unmasked;

    `AND_2(u_ld_t0,   1, ld_op_t0,        n_mod_is_11, cs_MODRM_NEEDED)
    `OR_2 (u_ld_un,   1, ld_op_unmasked,  ld_op_t0, cs_HARDCODED_LD_OP)
    `AND_2(u_ld_op,   1, ld_op,           ld_op_unmasked, n_cs_LD_OP_CANCEL)

    `AND_2(u_st_t0,   1, st_op_t0,        rm_is_dr, n_mod_is_11)
    `OR_2 (u_st_un,   1, st_op_unmasked,  st_op_t0, cs_HARDCODED_ST_OP)
    `AND_2(u_st_op,   1, st_op,           st_op_unmasked, n_cs_ST_OP_CANCEL)

    // =================================================================
    // ALU input override flags + sources (always BUFFER)
    //   alu_inputA_override = rm_is_dr  & (st_op | ld_op)
    //   alu_inputB_override = reg_is_dr & ld_op
    // =================================================================
    wire st_or_ld;
    `OR_2 (u_st_or_ld,  1, st_or_ld, st_op, ld_op)
    `AND_2(u_ovrA,      1, alu_inputA_override, rm_is_dr,  st_or_ld)
    `AND_2(u_ovrB,      1, alu_inputB_override, reg_is_dr, ld_op)

    assign alu_inputA_override_sel = `BUFFER;
    assign alu_inputB_override_sel = `BUFFER;

    // =================================================================
    // special_modrm_bs = (mod==00) & (rm==101) & MODRM_NEEDED
    // =================================================================
    `AND_3(u_smb, 1, special_modrm_bs, mod_is_00, rm_is_101, cs_MODRM_NEEDED)

endmodule








import reg_ids_pkg::*;
import core_stage_latches_pkg::*;
import control_store_pkg::*;

module modrm_processor (
    input byte_t modrm_byte,
    input logic [1:0] datasize,
    input decode_cs_t decode_cs_inputs,
    output modrm_processor_outs_t outputs
);
    reg_ids_e dr_id;
    reg_ids_e sr_id;
    bool dr_rd;
    bool sr_rd;
    bool dr_wr;
    bool sr_wr;
    bool ld_op_unmasked;
    bool st_op_unmasked;
    bool ld_op;
    bool st_op;
    bool rm_is_dr;
    bool reg_is_dr;
    bool reg_is_segment;
    bool modrm_but_no_sr;
    bool alu_inputA_override;
    bool alu_inputB_override;
    bool dr_high8;
    bool sr_high8;
    source_selector_e alu_inputA_override_sel;
    source_selector_e alu_inputB_override_sel;




    wire mod_field_is_11;
    `CMP_N(mod_field_cmp, 3, mod_field_is_11, modrm_byte[7:6], 2'b11)


    /* ===================================================================== //
                alu_inputA, alu_inputB stuff
    // ===================================================================== */
    // assign alu_inputA_override = rm_is_dr && (st_op || ld_op);
    // assign alu_inputB_override = reg_is_dr && ld_op;
    // assign alu_inputA_override_sel = BUFFER;
    // assign alu_inputB_override_sel = BUFFER;

    wire alu_inputA_override
    wire alu_inputB_override;
    wire [`SRC_SEL_W-1:0] alu_inputA_override_sel;
    wire [`SRC_SEL_W-1:0] alu_inputB_override_sel;
    wire st_or_ld_op;

    `OR_2(st_or_ld_op_gate, 1, st_or_ld_op, st_op, ld_op)
    `AND_2(alu_inputA_over_gate, 1, alu_inputA_override, rm_is_dr, st_or_ld_op)
    assign alu_inputA_override_sel = `BUFFER;
    assign alu_inputB_override_sel = `BUFFER;


    /* ===================================================================== //
                rm_is_dr, reg_is_dr, segment, stuff
    // ===================================================================== */
    // assign rm_is_dr = (decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.RM_IS_DR && !decode_cs_inputs.REG_IS_DR);
    // assign reg_is_dr = (decode_cs_inputs.MODRM_NEEDED && !decode_cs_inputs.RM_IS_DR && decode_cs_inputs.REG_IS_DR);
    // assign reg_is_segment = (decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.REG_IS_SEGMENT);
    // assign modrm_but_no_sr = decode_cs_inputs.MODRM_BUT_NO_SR;

    wire rm_is_dr;
    wire reg_is_dr;
    wire reg_is_segment;
    wire modrm_but_no_sr;
    
    `AND_2(rm_is_dr_gate, 1, rm_is_dr, cs_MODRM_NEEDED, cs_RM_IS_DR)
    `AND_2(reg_is_dr_gate, 1, reg_is_dr, cs_MODRM_NEEDED, cs_REG_IS_DR)
    `AND_2(reg_is_segment_gate, 1, reg_is_segment, cs_MODRM_NEEDED, cs_REG_IS_SEGMENT)
    assign modrm_but_no_sr = cs_MODRM_BUT_NO_SR;




    /* ===================================================================== //
                dr_high8, dr_id, dr_rd, dr_wr always_comb block
    // ===================================================================== */

    if(rm_is_dr && 
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00101) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b01100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b10100)) 
    else if(reg_is_dr && !reg_is_segment)
    else if(reg_is_segment && reg_is_dr)
    else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_DR)
    else


    always_comb begin
        dr_high8 = 1'b0;
        //dr reg setting
        if(rm_is_dr && 
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00101) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b01100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b10100)) 
            begin
            case(modrm_byte[2:0])    //rm id
                3'd0: dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM3 : EBX;
                3'd4: begin
                    dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM4 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EAX : ESP;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM5 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? ECX : EBP;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM6 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EDX : ESI;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    dr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM7 :
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EBX : EDI;
                    dr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
            endcase 
            dr_rd = 1'b1;
            dr_wr = (modrm_byte[7:6] == 2'b11 && decode_cs_inputs.MODRM_NEEDED) ? 1'b1 : 1'b0;
        end
        else if(reg_is_dr && !reg_is_segment) begin
            case(modrm_byte[5:3])    //reg id
                3'd0: dr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: dr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: dr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: dr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0]) ? EAX : ESP;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0]) ? ECX : EBP;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0]) ? EDX : ESI;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    dr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0]) ? EBX : EDI;
                    dr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
            endcase
            dr_rd = 1'b1;
            dr_wr = 1'b1;
        end
        else if(reg_is_segment && reg_is_dr) begin
            case(modrm_byte[5:3])    //seg orders, given by chat, idk if i trust
                3'd0: dr_id = ES;
                3'd1: dr_id = CS;
                3'd2: dr_id = SS;
                3'd3: dr_id = DS;
                3'd4: dr_id = FS;
                3'd5: dr_id = GS;
                3'd6: dr_id = NO_REG;
                3'd7: dr_id = NO_REG;
            endcase
            dr_rd = 1'b1;
            dr_wr = 1'b1;
        end
        else if(!decode_cs_inputs.MODRM_NEEDED && decode_cs_inputs.HARDCODED_DR) begin
            dr_id = decode_cs_inputs.HARDCODED_DR_ID;
            dr_rd = decode_cs_inputs.HARDCODED_DR_RD;
            //gonna assume for now that if youre reading this reg then youre gonna write back to it since this is dr
            //actually not true for fuck ass movs case, but gonna mux outside of here cause fuck that instruction
            //actually still not true even outside of movs case, what other case? you guessed it, mov. fuck ass instruction
            dr_wr = decode_cs_inputs.HARDCODED_DR_WR;
            dr_high8 = decode_cs_inputs.HARDCODED_DR_HIGH8;
        end
        else begin
            dr_id = NO_REG;
            dr_rd = 1'b0;
            dr_wr = 1'b0;
        end
    end








    always_comb begin
        sr_high8 = 1'b0;
        //sr reg setting
        if(rm_is_dr && !reg_is_segment && !modrm_but_no_sr && !decode_cs_inputs.HARDCODED_SR) begin
            case(modrm_byte[5:3])    //rm id
                3'd0: sr_id = (datasize[1] && datasize[0]) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0]) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0]) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0]) ? MM3 : EBX;
                3'd4: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM4 : 
                            (!datasize[1] && !datasize[0]) ? EAX : ESP;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM5 : 
                            (!datasize[1] && !datasize[0]) ? ECX : EBP;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM6 : 
                            (!datasize[1] && !datasize[0]) ? EDX : ESI;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    sr_id = (datasize[1] && datasize[0]) ? MM7 :
                            (!datasize[1] && !datasize[0]) ? EBX : EDI;
                    sr_high8 = (!datasize[1] && !datasize[0]) ? 1'b1 : 1'b0;
                end
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(reg_is_dr &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b00101) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b01100) &&
            ({modrm_byte[7:6], modrm_byte[2:0]} != 5'b10100)) begin
            case(modrm_byte[2:0])    //reg id
                3'd0: sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM0 : EAX;
                3'd1: sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM1 : ECX;
                3'd2: sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM2 : EDX;
                3'd3: sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM3 : EBX;
                3'd4: begin
                    sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM4 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EAX : ESP;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd5: begin
                    sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM5 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? ECX : EBP;
                   sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd6: begin
                    sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM6 : 
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EDX : ESI;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
                3'd7: begin
                    sr_id = (datasize[1] && datasize[0] && modrm_byte[7:6] == 2'b11) ? MM7 :
                            (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? EBX : EDI;
                    sr_high8 = (!datasize[1] && !datasize[0] && modrm_byte[7:6] == 2'b11) ? 1'b1 : 1'b0;
                end
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(reg_is_segment && rm_is_dr) begin
            case(modrm_byte[5:3])    //seg orders, given by chat, idk if i trust
                3'd0: sr_id = ES;
                3'd1: sr_id = CS;
                3'd2: sr_id = SS;
                3'd3: sr_id = DS;
                3'd4: sr_id = FS;
                3'd5: sr_id = GS;
                3'd6: sr_id = NO_REG;
                3'd7: sr_id = NO_REG;
            endcase
            sr_rd = 1'b1;
            sr_wr = 1'b0;
        end
        else if(decode_cs_inputs.HARDCODED_SR) begin
            sr_id = decode_cs_inputs.HARDCODED_SR_ID;
            sr_rd = decode_cs_inputs.HARDCODED_SR_RD;
            sr_wr = decode_cs_inputs.HARDCODED_SR_WR;
        end
        else begin
            sr_id = NO_REG;
            sr_rd = 1'b0;
            sr_wr = 1'b0;
        end
    end






    //st/ld op setting
    assign ld_op_unmasked = ((modrm_byte[7:6] != 2'b11) && decode_cs_inputs.MODRM_NEEDED) || decode_cs_inputs.HARDCODED_LD_OP;
    assign st_op_unmasked = (rm_is_dr && (modrm_byte[7:6] != 2'b11)) || decode_cs_inputs.HARDCODED_ST_OP;

    assign ld_op = ld_op_unmasked && !decode_cs_inputs.LD_OP_CANCEL;
    assign st_op = st_op_unmasked && !decode_cs_inputs.ST_OP_CANCEL;


    assign outputs = '{
        dr_id   : dr_id,
        sr_id   : sr_id,
        dr_rd   : dr_rd,
        sr_rd   : sr_rd,
        dr_wr   : dr_wr,
        sr_wr   : sr_wr,
        st_op   : st_op,
        ld_op   : ld_op,
        dr_high8   : dr_high8,
        sr_high8   : sr_high8,
        alu_inputA_override : alu_inputA_override,
        alu_inputB_override : alu_inputB_override,
        alu_inputA_override_sel : alu_inputA_override_sel,
        alu_inputB_override_sel : alu_inputB_override_sel,
        special_modrm_bs : ({modrm_byte[7:6], modrm_byte[2:0]} == 5'b00101 && decode_cs_inputs.MODRM_NEEDED) ? 1'b1 : 1'b0
    };


endmodule
