module npu_node1 (
    input uint32_t register_data,   //does not need to be 64 but input since we will never pull address from mmx reg
    input uint32_t regout_sr_data,
    input uint32_t regout_dr_data,
    input uint32_t SIB_IDX_data,
    input uint32_t SIB_BASE_data,
    input uint8_t SIB_SCALE_val,
    input bool sib_needed,
    input bool disp_needed,
    input bool dispsize,
    input uint32_t displacement,

    input logic [2:0] datasize;

    input uint32_t seg0_data,
    input segment_limit_reg_entry_t segment0_limit;
    input uint32_t seg1_data,
    input segment_limit_reg_entry_t segment1_limit;
    input bool seg1_valid

    input bool modrm_needed;
    input bool rm_is_dr;
    input bool st_sel;

    output v_address_t ld_vaddy;
    output uint32_t seg0_limit_w_datasize;
    output v_address_t actual_st_vaddy;
    output uint32_t seg1_limit_w_datasize;
);

    assign seg0_limit_w_datasize = segment0_limit[datasize[1:0]];
    assign seg1_limit_w_datasize = segment1_limit[datasize[1:0]];

    uint32_t sib_nonsense;
    uint32_t shift_result;
    assign shift_result = (SIB_IDX_data << SIB_SCALE_val);
    assign #3 sib_nonsense = shift_result + SIB_BASE_data;

    uint32_t real_seg1_data = (seg1_valid) ? seg1_data : seg0_data;

    uint32_t seg0val_plus_displacement, seg1val_plus_displacement;
    assign #3 seg0val_plus_displacement = displacement_out + (seg0_data << 16);
    assign #3 seg1val_plus_displacement = displacement_out + (real_seg1_data << 16);

    always_comb begin
        case({sib_needed, disp_needed})
            2'b00: begin
                sib_or_reg = register_data;
            end
            2'b01: begin
                sib_or_reg = 32'b0;
            end
            2'b10: begin
                sib_or_reg = sib_nonsense;
            end
            2'b11: begin
                sib_or_reg = sib_nonsense;
            end
        endcase

        case({disp_needed, dispsize})
            2'b00: begin
                displacement_out = 32'b0;
            end
            2'b01: begin
                displacement_out = 32'b0;
            end
            2'b10: begin
                displacement_out = {24'b0, displacement[7:0]};
            end
            2'b11: begin
                displacement_out = displacement;
            end
        endcase
    end

    //at the end of this module, we would have need to found out the correct virtual store and load address
    //formula for virtual address = (ind*scale + base) + (displacement + segvalue<<16)
    //could be register value instead of ind*scale + base but need to know worst path for timing
    //need both a load and store address cause they could be different in CS_ST_SEL is set
    //need ot parallely process the adds for the address

        // assign staddyX_neuralnet_addy =
        // (latchesInUse.cs.ST_SEL) ?
        //     ((latchesInUse.cs.MODRM_NEEDED && latchesInUse.cs.RM_IS_DR) ? reg_out.SR_data[31:0] : reg_out.DR_data[31:0]) :
        //     addygen_out;
    // this above formula is for store address before RR was split
    // can use this but replace every option with name << 16 and pick that with mux
    //we sill essentially do the segment translation for all paths and pick the right one
    //instead of picking then translating

    assign #3 ld_vaddy = sib_or_reg + seg0val_plus_displacement;
    assign #3 st_vaddy = sib_or_reg + seg1val_plus_displacement;

    uint32_t shifted_sr_data, shifted_dr_data;
    assign #3 shifted_sr_data = regout_sr_data + (real_seg1_data << 16);
    assign #3 shifted_dr_data = regout_dr_data + (real_seg1_data << 16);
    assign actual_st_vaddy = (st_sel) ? 
                                ((modrm_needed && rm_is_dr) ? shifter_sr_data : shifted_dr_data) :
                                st_vaddy;

endmodule
