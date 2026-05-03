
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

    /* ===================================================================== //
                field bools
    // ===================================================================== */
    wire mod_field_is_11;
    `AND_2(mod_field_is_11_u, 1, mod_field_is_11, modrm_byte[7], modrm_byte[6])

    wire mod_field_is_not_11;
    `NAND_2(mod_field_is_not_11_u, 1, mod_field_is_not_11, modrm_byte[7], modrm_byte[6])

    wire modrm_case_00100;
    wire modrm_case_00101;
    wire modrm_case_01100;
    wire modrm_case_10100;
    `CMP_N(modrm_case_00100_cmp, 5, modrm_case_00100, {modrm_byte[7:6], modrm_byte[2:0]}, 5'b00100)
    `CMP_N(modrm_case_00101_cmp, 5, modrm_case_00101, {modrm_byte[7:6], modrm_byte[2:0]}, 5'b00101)
    `CMP_N(modrm_case_01100_cmp, 5, modrm_case_01100, {modrm_byte[7:6], modrm_byte[2:0]}, 5'b01100)
    `CMP_N(modrm_case_10100_cmp, 5, modrm_case_10100, {modrm_byte[7:6], modrm_byte[2:0]}, 5'b10100)

    wire not_wierd_modrm_case;
    `NOR_4(not_wierd_modrm_case_gate, 1, not_wierd_modrm_case, modrm_case_00100, modrm_case_00101, modrm_case_01100, __in3modrm_case_10100__)


    wire datasize_11;
    wire datasize_00;
    wire datasize_11_mod_11;
    wire datasize_00_mod_11;
    `AND_2(datasize_11_u, 1, datasize_11, datasize[0], datasize[1])
    `NOR_2(datasize_00_u, 1, datasize_00, datasize[0], datasize[1])
    `AND_3(datasize_11_mod_11_u, 1, datasize_11_mod_11, datasize[0], datasize[1], mod_field_is_11)
    `NOR_3(datasize_00_mod_11_u, 1, datasize_00_mod_11, datasize[0], datasize[0], mod_field_is_not_11)



    


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
    wire not_rm_is_dr;
    wire reg_is_seg_inv;
    
    `AND_2(rm_is_dr_gate, 1, rm_is_dr, cs_MODRM_NEEDED, cs_RM_IS_DR)
    `AND_2(reg_is_dr_gate, 1, reg_is_dr, cs_MODRM_NEEDED, cs_REG_IS_DR)
    `AND_2(reg_is_segment_gate, 1, reg_is_segment, cs_MODRM_NEEDED, cs_REG_IS_SEGMENT)
    `INV_N(not_rm_is_dr_u, 1, rm_is_dr, not_rm_is_dr)
    `INV_N(reg_seg_inv, 1, reg_is_segment, reg_is_seg_inv)


    assign modrm_but_no_sr = cs_MODRM_BUT_NO_SR;




    /* ===================================================================== //
                dr_high8, dr_id, dr_rd, dr_wr always_comb block
    // ===================================================================== */
    // if(rm_is_dr && not_wierd_modrm_case) dr_a    2to1
    // else if(reg_is_dr && !reg_is_segment) dr_b               2to1

    // else if(reg_is_segment && reg_is_dr) dr_c    4to1
    // else if(decode_cs_inputs.HARDCODED_DR) dr_d
    // else dr_e

    wire rm_dr_not_wierd;
    wire reg_dr_not_segment;
    wire reg_dr_segment;

    `AND_2(rm_dr_not_wierd_gate, 1, rm_dr_not_wierd, rm_is_dr, not_wierd_modrm_case)
    `AND_2(reg_dr_not_segment_gate, 1, reg_dr_not_segment, reg_is_dr, reg_is_seg_inv)
    `AND_2(reg_dr_segment_gate, 1, reg_dr_segment, reg_is_segment, reg_is_dr)

    wire sel_dr_a_or_b;
    `OR_2(sel_dr_a_or_b_u, 1, sel_dr_a_or_b, rm_dr_not_wierd, reg_dr_not_segment)


    /////////////// rm_dr_not_wierd
    wire rm_dr_not_wierd_dr_rd;
    wire rm_dr_not_wierd_dr_wr;
    wire rm_dr_not_wierd_dr_high8;
    wire [`REG_ID_W-1:0] rm_dr_not_wierd_dr_id_v[0:7];
    wire [`REG_ID_W-1:0] rm_dr_not_wierd_dr_id;

    assign rm_dr_not_wierd_dr_rd = 1'b1;
    `AND_2(rm_dr_not_wierd_dr_wr_gate, 1, rm_dr_not_wierd_dr_wr, mod_is_11, cs_MODRM_NEEDED)
    `AND_2(rm_dr_not_wierd_dr_high8_gate, 1, rm_dr_not_wierd_dr_high8, datasize_00_mod_11, modrm_byte[2])

    //dr_id
    `MUX_2(rm_dr_not_wierd_dr_id0_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[0], `EAX, `MM0, datasize_11_mod_11)
    `MUX_2(rm_dr_not_wierd_dr_id1_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[1], `ECX, `MM1, datasize_11_mod_11)
    `MUX_2(rm_dr_not_wierd_dr_id2_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[2], `EDX, `MM2, datasize_11_mod_11)
    `MUX_2(rm_dr_not_wierd_dr_id3_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[3], `EBX, `MM3, datasize_11_mod_11)

    `MUX_4(rm_dr_not_wierd_dr_id4_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[4], `ESP, `EAX, `MM4, `MM4, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(rm_dr_not_wierd_dr_id5_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[5], `EBP, `ECX, `MM5, `MM5, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(rm_dr_not_wierd_dr_id6_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[6], `ESI, `EDX, `MM6, `MM6, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(rm_dr_not_wierd_dr_id7_u, `REG_ID_W, rm_dr_not_wierd_dr_id_v[7], `EDI, `EBX, `MM7, `MM7, {datasize_11_mod_11, datasize_00_mod_11})

    `MUX_8(rm_dr_not_wierd_dr_id_u, `REG_ID_W, rm_dr_not_wierd_dr_id, 
            rm_dr_not_wierd_dr_id_v[0], rm_dr_not_wierd_dr_id_v[1], rm_dr_not_wierd_dr_id_v[2], rm_dr_not_wierd_dr_id_v[3],
            rm_dr_not_wierd_dr_id_v[4], rm_dr_not_wierd_dr_id_v[5], rm_dr_not_wierd_dr_id_v[6], rm_dr_not_wierd_dr_id_v[7],
            modrm_byte[2:0])



    /////////////// reg_dr_not_segment
    wire reg_dr_not_segment_dr_rd;
    wire reg_dr_not_segment_dr_wr;
    wire reg_dr_not_segment_dr_high8;
    wire [`REG_ID_W-1:0] reg_dr_not_segment_dr_id_v[0:7];
    wire [`REG_ID_W-1:0] reg_dr_not_segment_dr_id;

    assign reg_dr_not_segment_dr_rd = 1'b1;
    assign reg_dr_not_segment_dr_wr = 1'b1;
    `AND_2(reg_dr_not_segment_dr_high8_gate, 1, reg_dr_not_segment_dr_high8, datasize_00, modrm_byte[5])

    //dr_id
    `MUX_2(reg_dr_not_segment_dr_id0_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[0], `EAX, `MM0, datasize_11)
    `MUX_2(reg_dr_not_segment_dr_id1_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[1], `ECX, `MM1, datasize_11)
    `MUX_2(reg_dr_not_segment_dr_id2_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[2], `EDX, `MM2, datasize_11)
    `MUX_2(reg_dr_not_segment_dr_id3_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[3], `EBX, `MM3, datasize_11)

    `MUX_4(reg_dr_not_segment_dr_id4_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[4], `ESP, `EAX, `MM4, `MM4, {datasize_11, datasize_00})
    `MUX_4(reg_dr_not_segment_dr_id5_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[5], `EBP, `ECX, `MM5, `MM5, {datasize_11, datasize_00})
    `MUX_4(reg_dr_not_segment_dr_id6_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[6], `ESI, `EDX, `MM6, `MM6, {datasize_11, datasize_00})
    `MUX_4(reg_dr_not_segment_dr_id7_u, `REG_ID_W, reg_dr_not_segment_dr_id_v[7], `EDI, `EBX, `MM7, `MM7, {datasize_11, datasize_00})

    `MUX_8(reg_dr_not_segment_dr_id_u, `REG_ID_W, reg_dr_not_segment_dr_id, 
            reg_dr_not_segment_dr_id_v[0], reg_dr_not_segment_dr_id_v[1], reg_dr_not_segment_dr_id_v[2], reg_dr_not_segment_dr_id_v[3],
            reg_dr_not_segment_dr_id_v[4], reg_dr_not_segment_dr_id_v[5], reg_dr_not_segment_dr_id_v[6], reg_dr_not_segment_dr_id_v[7],
            modrm_byte[5:3])




    /////////////// reg_dr_segment
    wire reg_dr_segment_dr_rd;
    wire reg_dr_segment_dr_wr;
    wire reg_dr_segment_dr_high8;
    wire [`REG_ID_W-1:0] reg_dr_segment_dr_id;

    assign reg_dr_segment_dr_rd = 1'b1;
    assign reg_dr_segment_dr_wr = 1'b1;
    assign reg_dr_segment_dr_high8 = 1'b0;

    //dr_id
    `MUX_8(reg_dr_segment_dr_id_u, `REG_ID_W, reg_dr_segment_dr_id, 
            `ES, `CS, `SS, `DS,
            `FS, `GS, `NO_REG, `NO_REG,
            modrm_byte[5:3])



    /////////////// hardcoded_dr
    wire hardcoded_dr_dr_rd;
    wire hardcoded_dr_dr_wr;
    wire hardcoded_dr_dr_high8;
    wire [`REG_ID_W-1:0] hardcoded_dr_dr_id;

    assign hardcoded_dr_dr_rd = cs_HARDCODED_DR_RD;
    assign hardcoded_dr_dr_wr = cs_HARDCODED_DR_WR;
    assign hardcoded_dr_dr_high8 = cs_HARDCODED_DR_HIGH8;
    assign hardcoded_dr_dr_id = cs_HARDCODED_DR_ID;

    /////////////// dr_else
    wire dr_else_dr_rd;
    wire dr_else_dr_wr;
    wire dr_else_dr_high8;
    wire [`REG_ID_W-1:0] dr_else_dr_id;

    assign dr_else_dr_rd = 1'b0;
    assign dr_else_dr_wr = 1'b0;
    assign dr_else_dr_high8 = 1'b0;
    assign dr_else_dr_id = NO_REG;


    //////////////selection
    wire dr_rd_ab;
    wire dr_rd_cde;
    `MUX_2(dr_rd_ab_u, 1, dr_rd_ab, 
            reg_dr_not_segment_dr_rd, rm_dr_not_wierd_dr_rd, rm_dr_not_wierd)
    `MUX_4(dr_rd_cde_u, 1, dr_rd_cde, 
            dr_else_dr_rd, hardcoded_dr_dr_rd, reg_is_segment_dr_rd, reg_is_segment_dr_rd, 
            {reg_dr_segment, cs_HARDCODED_DR})
    `MUX_2(dr_rd_u, 1, dr_rd, 
            dr_rd_cde, dr_rd_ab, sel_dr_a_or_b)

    wire dr_wr_ab;
    wire dr_wr_cde;
    `MUX_2(dr_wr_ab_u, 1, dr_wr_ab, 
            reg_dr_not_segment_dr_wr, rm_dr_not_wierd_dr_wr, rm_dr_not_wierd)
    `MUX_4(dr_wr_cde_u, 1, dr_wr_cde, 
            dr_else_dr_wr, hardcoded_dr_dr_wr, reg_is_segment_dr_wr, reg_is_segment_dr_wr, 
            {reg_dr_segment, cs_HARDCODED_DR})
    `MUX_2(dr_wr_u, 1, dr_wr, 
            dr_wr_cde, dr_wr_ab, sel_dr_a_or_b)

    wire dr_high8_ab;
    wire dr_high8_cde;
    `MUX_2(dr_high8_ab_u, 1, dr_high8_ab, 
            reg_dr_not_segment_dr_high8, rm_dr_not_wierd_dr_high8, rm_dr_not_wierd)
    `MUX_4(dr_high8_cde_u, 1, dr_high8_cde, 
            dr_else_dr_high8, hardcoded_dr_dr_high8, reg_is_segment_dr_high8, reg_is_segment_dr_high8, 
            {reg_dr_segment, cs_HARDCODED_DR})
    `MUX_2(dr_high8_u, 1, dr_high8, 
            dr_high8_cde, dr_high8_ab, sel_dr_a_or_b) 

    wire dr_id_ab;
    wire dr_id_cde;
    `MUX_2(dr_id_ab_u, `REG_ID_W, dr_id_ab, 
            reg_dr_not_segment_dr_id, rm_dr_not_wierd_dr_id, rm_dr_not_wierd)
    `MUX_4(dr_id_cde_u, `REG_ID_W, dr_id_cde, 
            dr_else_dr_id, hardcoded_dr_dr_id, reg_is_segment_dr_id, reg_is_segment_dr_id, 
            {reg_dr_segment, cs_HARDCODED_DR})
    `MUX_2(dr_id_u, `REG_ID_W, dr_id, 
            dr_id_cde, dr_id_ab, sel_dr_a_or_b) 








    /* ===================================================================== //
                sr_high8, sr_id, sr_rd, sr_wr always_comb block
    // ===================================================================== */
    // if(rm_is_dr && !reg_is_segment && !modrm_but_no_sr)
    // else if(reg_is_dr && not_wierd_modrm_case)

    // else if(reg_is_segment && rm_is_dr)
    // else if(decode_cs_inputs.HARDCODED_SR)
    // else dr_e


    wire rm_dr_no_seg_reg_valid_sr;
    wire reg_dr_not_wierd;
    wire reg_seg_rm_dr;

    `NOR_3(rm_dr_no_seg_reg_valid_sr_u, 1, rm_dr_no_seg_reg_valid_sr, not_rm_is_dr, reg_is_segment, modrm_but_no_sr)
    `AND_2(reg_dr_not_wierd_u, 1, reg_dr_not_wierd, reg_is_dr, not_wierd_modrm_case)
    `AND_2(reg_seg_rm_dr_u, 1, reg_seg_rm_dr, reg_is_segment, rm_is_dr)

    wire sel_sr_a_or_b;
    `OR_2(sel_sr_a_or_b_u, 1, sel_sr_a_or_b, rm_dr_no_seg_reg_valid_sr, reg_dr_not_wierd)



    /////////////// rm_dr_no_seg_reg_valid_sr
    wire rm_dr_no_seg_reg_valid_sr_sr_rd;
    wire rm_dr_no_seg_reg_valid_sr_sr_wr;
    wire rm_dr_no_seg_reg_valid_sr_sr_high8;
    wire [`REG_ID_W-1:0] rm_dr_no_seg_reg_valid_sr_sr_id_v[0:7];
    wire [`REG_ID_W-1:0] rm_dr_no_seg_reg_valid_sr_sr_id;

    assign rm_dr_no_seg_reg_valid_sr_sr_rd = 1'b1;
    assign rm_dr_no_seg_reg_valid_sr_sr_wr = 1'b1;
    `AND_2(rm_dr_no_seg_reg_valid_sr_sr_high8_gate, 1, rm_dr_no_seg_reg_valid_sr_sr_high8, datasize_00, modrm_byte[5])

    //sr_id
    `MUX_2(rm_dr_no_seg_reg_valid_sr_sr_id0_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[0], `EAX, `MM0, datasize_11)
    `MUX_2(rm_dr_no_seg_reg_valid_sr_sr_id1_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[1], `ECX, `MM1, datasize_11)
    `MUX_2(rm_dr_no_seg_reg_valid_sr_sr_id2_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[2], `EDX, `MM2, datasize_11)
    `MUX_2(rm_dr_no_seg_reg_valid_sr_sr_id3_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[3], `EBX, `MM3, datasize_11)

    `MUX_4(rm_dr_no_seg_reg_valid_sr_sr_id4_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[4], `ESP, `EAX, `MM4, `MM4, {datasize_11, datasize_00})
    `MUX_4(rm_dr_no_seg_reg_valid_sr_sr_id5_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[5], `EBP, `ECX, `MM5, `MM5, {datasize_11, datasize_00})
    `MUX_4(rm_dr_no_seg_reg_valid_sr_sr_id6_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[6], `ESI, `EDX, `MM6, `MM6, {datasize_11, datasize_00})
    `MUX_4(rm_dr_no_seg_reg_valid_sr_sr_id7_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id_v[7], `EDI, `EBX, `MM7, `MM7, {datasize_11, datasize_00})

    `MUX_8(rm_dr_no_seg_reg_valid_sr_sr_id_u, `REG_ID_W, rm_dr_no_seg_reg_valid_sr_sr_id, 
            rm_dr_no_seg_reg_valid_sr_sr_id_v[0], rm_dr_no_seg_reg_valid_sr_sr_id_v[1], rm_dr_no_seg_reg_valid_sr_sr_id_v[2], rm_dr_no_seg_reg_valid_sr_sr_id_v[3],
            rm_dr_no_seg_reg_valid_sr_sr_id_v[4], rm_dr_no_seg_reg_valid_sr_sr_id_v[5], rm_dr_no_seg_reg_valid_sr_sr_id_v[6], rm_dr_no_seg_reg_valid_sr_sr_id_v[7],
            modrm_byte[5:3])



    /////////////// rm_dr_no_seg_reg_valid_sr
    wire reg_dr_not_wierd_sr_rd;
    wire reg_dr_not_wierd_sr_wr;
    wire reg_dr_not_wierd_sr_high8;
    wire [`REG_ID_W-1:0] reg_dr_not_wierd_sr_id_v[0:7];
    wire [`REG_ID_W-1:0] reg_dr_not_wierd_sr_id;

    assign reg_dr_not_wierd_sr_rd = 1'b1;
    assign reg_dr_not_wierd_sr_wr = 1'b0;
    `AND_2(reg_dr_not_wierd_sr_high8_gate, 1, reg_dr_not_wierd_sr_high8, datasize_00_mod_11, modrm_byte[2])

    //sr_id
    `MUX_2(reg_dr_not_wierd_sr_id0_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[0], `EAX, `MM0, datasize_11_mod_11)
    `MUX_2(reg_dr_not_wierd_sr_id1_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[1], `ECX, `MM1, datasize_11_mod_11)
    `MUX_2(reg_dr_not_wierd_sr_id2_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[2], `EDX, `MM2, datasize_11_mod_11)
    `MUX_2(reg_dr_not_wierd_sr_id3_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[3], `EBX, `MM3, datasize_11_mod_11)

    `MUX_4(reg_dr_not_wierd_sr_id4_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[4], `ESP, `EAX, `MM4, `MM4, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(reg_dr_not_wierd_sr_id5_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[5], `EBP, `ECX, `MM5, `MM5, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(reg_dr_not_wierd_sr_id6_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[6], `ESI, `EDX, `MM6, `MM6, {datasize_11_mod_11, datasize_00_mod_11})
    `MUX_4(reg_dr_not_wierd_sr_id7_u, `REG_ID_W, reg_dr_not_wierd_sr_id_v[7], `EDI, `EBX, `MM7, `MM7, {datasize_11_mod_11, datasize_00_mod_11})

    `MUX_8(reg_dr_not_wierd_sr_id_u, `REG_ID_W, reg_dr_not_wierd_sr_id, 
            reg_dr_not_wierd_sr_id_v[0], reg_dr_not_wierd_sr_id_v[1], reg_dr_not_wierd_sr_id_v[2], reg_dr_not_wierd_sr_id_v[3],
            reg_dr_not_wierd_sr_id_v[4], reg_dr_not_wierd_sr_id_v[5], reg_dr_not_wierd_sr_id_v[6], reg_dr_not_wierd_sr_id_v[7],
            modrm_byte[2:0])



    /////////////// reg_dr_segment
    wire reg_seg_rm_dr_sr_rd;
    wire reg_seg_rm_dr_sr_wr;
    wire reg_seg_rm_dr_sr_high8;
    wire [`REG_ID_W-1:0] reg_seg_rm_dr_sr_id;

    assign reg_seg_rm_dr_sr_rd = 1'b1;
    assign reg_seg_rm_dr_sr_wr = 1'b0;
    assign reg_seg_rm_dr_sr_high8 = 1'b0;

    //dr_id
    `MUX_8(reg_seg_rm_dr_sr_id_u, `REG_ID_W, reg_seg_rm_dr_sr_id, 
            `ES, `CS, `SS, `DS,
            `FS, `GS, `NO_REG, `NO_REG,
            modrm_byte[5:3])


    /////////////// hardcoded_sr
    wire hardcoded_sr_sr_rd;
    wire hardcoded_sr_sr_wr;
    wire hardcoded_sr_sr_high8;
    wire [`REG_ID_W-1:0] hardcoded_sr_sr_id;

    assign hardcoded_sr_sr_rd = cs_HARDCODED_SR_RD;
    assign hardcoded_sr_sr_wr = cs_HARDCODED_SR_WR;
    assign hardcoded_sr_sr_high8 = 1'b0;
    assign hardcoded_sr_sr_id = cs_HARDCODED_SR_ID;

    /////////////// sr_else
    wire sr_else_sr_rd;
    wire sr_else_sr_wr;
    wire sr_else_sr_high8;
    wire [`REG_ID_W-1:0] sr_else_sr_id;

    assign sr_else_sr_rd = 1'b0;
    assign sr_else_sr_wr = 1'b0;
    assign sr_else_sr_high8 = 1'b0;
    assign sr_else_sr_id = NO_REG;



    //////////////selection
    wire rm_dr_no_seg_reg_valid_sr;
    wire reg_dr_not_wierd;
    wire reg_seg_rm_dr;

    wire sr_rd_ab;
    wire sr_rd_cde;
    `MUX_2(sr_rd_ab_u, 1, sr_rd_ab, 
            reg_dr_not_wierd_sr_rd, rm_dr_no_seg_reg_valid_sr_sr_rd, rm_dr_no_seg_reg_valid_sr)
    `MUX_4(sr_rd_cde_u, 1, sr_rd_cde, 
            sr_else_sr_rd, hardcoded_sr_sr_rd, reg_seg_rm_dr_sr_rd, reg_seg_rm_dr_sr_rd, 
            {reg_seg_rm_dr, cs_HARDCODED_SR})
    `MUX_2(sr_rd_u, 1, sr_rd, 
            sr_rd_cde, sr_rd_ab, sel_sr_a_or_b)

    wire sr_wr_ab;
    wire sr_wr_cde;
    `MUX_2(sr_wr_ab_u, 1, sr_wr_ab, 
            reg_dr_not_wierd_sr_wr, rm_dr_no_seg_reg_valid_sr_sr_wr, rm_dr_no_seg_reg_valid_sr)
    `MUX_4(sr_wr_cde_u, 1, sr_wr_cde, 
            sr_else_sr_wr, hardcoded_sr_sr_wr, reg_seg_rm_dr_sr_wr, reg_seg_rm_dr_sr_wr, 
            {reg_seg_rm_dr, cs_HARDCODED_SR})
    `MUX_2(sr_wr_u, 1, sr_wr, 
            sr_wr_cde, sr_wr_ab, sel_sr_a_or_b)

    wire sr_high8_ab;
    wire sr_high8_cde;
    `MUX_2(sr_high8_ab_u, 1, sr_high8_ab, 
            reg_dr_not_wierd_sr_high8, rm_dr_no_seg_reg_valid_sr_sr_high8, rm_dr_no_seg_reg_valid_sr)
    `MUX_4(sr_high8_cde_u, 1, sr_high8_cde, 
            sr_else_sr_high8, hardcoded_sr_sr_high8, reg_seg_rm_dr_sr_high8, reg_seg_rm_dr_sr_high8, 
            {reg_seg_rm_dr, cs_HARDCODED_SR})
    `MUX_2(sr_high8_u, 1, sr_high8, 
            sr_high8_cde, sr_high8_ab, sel_sr_a_or_b) 

    wire sr_id_ab;
    wire sr_id_cde;
    `MUX_2(sr_id_ab_u, `REG_ID_W, sr_id_ab, 
            reg_dr_not_wierd_sr_id, rm_dr_no_seg_reg_valid_sr_sr_id, rm_dr_no_seg_reg_valid_sr)
    `MUX_4(sr_id_cde_u, `REG_ID_W, sr_id_cde, 
            sr_else_sr_id, hardcoded_sr_sr_id, reg_seg_rm_dr_sr_id, reg_seg_rm_dr_sr_id, 
            {reg_seg_rm_dr, cs_HARDCODED_SR})
    `MUX_2(sr_id_u, `REG_ID_W, sr_id, 
            sr_id_cde, sr_id_ab, sel_sr_a_or_b)  





    //st/ld op setting
    assign ld_op_unmasked = ((modrm_byte[7:6] != 2'b11) && decode_cs_inputs.MODRM_NEEDED) || decode_cs_inputs.HARDCODED_LD_OP;
    assign st_op_unmasked = (rm_is_dr && (modrm_byte[7:6] != 2'b11)) || decode_cs_inputs.HARDCODED_ST_OP;

    assign ld_op = ld_op_unmasked && !decode_cs_inputs.LD_OP_CANCEL;
    assign st_op = st_op_unmasked && !decode_cs_inputs.ST_OP_CANCEL;

    //special_modrm_bs = ({modrm_byte[7:6], modrm_byte[2:0]} == 5'b00101 && decode_cs_inputs.MODRM_NEEDED) ? 1'b1 : 1'b0
    `AND_2(special_modrm_bs_u, 1, special_modrm_bs, modrm_case_00101, cs_MODRM_NEEDED)



endmodule
