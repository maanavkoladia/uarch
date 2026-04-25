import RegisterRead_pkg::*;
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
    input bool special_modrm_bs,
    input uint32_t displacement,

    input logic [1:0] datasize,

    input uint32_t seg0_data,
    input segment_limit_reg_entry_t segment0_limit,
    input uint32_t seg1_data,
    input segment_limit_reg_entry_t segment1_limit,
    input bool seg1_valid,

    input bool modrm_needed,
    input bool rm_is_dr,
    input bool st_sel,
    input bool movs_op,
    input bool switch_ld_addy,

    output v_address_t ld_vaddy,
    output uint32_t seg0_limit_w_datasize,
    output uint32_t seg0_limit_wo_datasize,
    output v_address_t next_ld_vaddy, //need for finding next page for tlb
    output uint32_t ld_laddy,
    
    output v_address_t actual_st_vaddy,
    output uint32_t seg1_limit_w_datasize,
    output uint32_t seg1_limit_wo_datasize,
    output v_address_t actual_next_st_vaddy,
    output uint32_t actual_st_laddy
);  

    uint32_t displacement_out;
    uint32_t sib_or_reg;
    uint32_t seg1_limit_w_datasize_temp;
    assign seg1_limit_w_datasize = (seg1_valid) ? seg1_limit_w_datasize_temp : seg0_limit_w_datasize;

    assign #3 seg0_limit_w_datasize = (datasize[1] == 1'b1) ? 
                                        (datasize[0] == 1'b1) ? segment0_limit.limit - 32'd7 : segment0_limit.limit - 32'd3 :
                                        (datasize[0] == 1'b1) ? segment0_limit.limit - 32'd1 : segment0_limit.limit;

    assign #3 seg1_limit_w_datasize_temp = (datasize[1] == 1'b1) ? 
                                        (datasize[0] == 1'b1) ? segment1_limit.limit - 32'd7 : segment1_limit.limit - 32'd3 :
                                        (datasize[0] == 1'b1) ? segment1_limit.limit - 32'd1 : segment1_limit.limit;

    assign seg0_limit_wo_datasize = segment0_limit.limit;
    assign seg1_limit_wo_datasize = (seg1_valid) ? segment1_limit.limit : segment0_limit.limit;

    uint32_t sib_nonsense;
    uint32_t shift_result;
    assign shift_result = (SIB_IDX_data << SIB_SCALE_val);
    assign #3 sib_nonsense = shift_result + SIB_BASE_data;

    uint32_t real_seg1_data;
    assign real_seg1_data = (seg1_valid) ? seg1_data : seg0_data;

    uint32_t masked_displacement_out;
    assign masked_displacement_out = (switch_ld_addy) ? 32'b0 : displacement_out;

    uint32_t seg0val_plus_displacement, seg1val_plus_displacement;
    assign #3 seg0val_plus_displacement = masked_displacement_out + (seg0_data << 16);  //for push r/m32
    assign #3 seg1val_plus_displacement = displacement_out + (real_seg1_data << 16);    //don't think you need masked disp_out here since this si only for store address

    always_comb begin
        case({sib_needed, special_modrm_bs})
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
                displacement_out = {{24{displacement[7]}}, displacement[7:0]};
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

    v_address_t st_vaddy;
    uint32_t ld_addy_reg_data;
    uint32_t st_laddy;
    assign ld_addy_reg_data = (switch_ld_addy ? regout_sr_data : sib_or_reg);
    
    assign #3 ld_vaddy = ld_addy_reg_data + seg0val_plus_displacement;    //need this for making ss:esp the load address for pop r/m32
    assign #3 st_vaddy = sib_or_reg + seg1val_plus_displacement;

    assign #3 ld_laddy = ld_addy_reg_data + masked_displacement_out;
    assign #3 st_laddy = sib_or_reg + displacement_out;


    uint32_t shifted_sr_data, shifted_dr_data, shifted_seg1_data;
    assign shifted_seg1_data = (real_seg1_data << 16);
    assign #3 shifted_sr_data = regout_sr_data + shifted_seg1_data;
    assign #3 shifted_dr_data = regout_dr_data + shifted_seg1_data;
    
    assign actual_st_vaddy = (st_sel) ? 
                                ((movs_op) ? shifted_dr_data : shifted_sr_data) :
                                st_vaddy;
    
    assign actual_st_laddy = (st_sel) ?
                                ((movs_op) ? regout_dr_data : regout_sr_data) :
                                st_laddy;

    //next ld VPN and vaddy
    logic [VPN_BITS - 1 : 0] next_ld_VPN;
    assign #3 next_ld_VPN = sib_or_reg[VPN_UB : VPN_LB] + seg0val_plus_displacement[VPN_UB : VPN_LB] + 1'b1;
    assign next_ld_vaddy = {next_ld_VPN, {NUM_OFFSET_BITS{1'b0}}};

    //computations for all three different next st VPN and vaddy sources
    v_address_t next_st_vaddy;
    logic [VPN_BITS - 1 : 0] next_st_VPN;
    assign #3 next_st_VPN = sib_or_reg[VPN_UB : VPN_LB] + seg1val_plus_displacement[VPN_UB : VPN_LB] + 1'b1;
    assign next_st_vaddy = {next_st_VPN, {NUM_OFFSET_BITS{1'b0}}};

    v_address_t next_shifted_sr_data;
    logic [VPN_BITS - 1 : 0] next_shifted_sr_VPN;
    assign #3 next_shifted_sr_VPN = regout_sr_data[VPN_UB : VPN_LB] + shifted_seg1_data[VPN_UB : VPN_LB] + 1'b1;
    assign next_shifted_sr_data = {next_shifted_sr_VPN, {NUM_OFFSET_BITS{1'b0}}};

    v_address_t next_shifted_dr_data;
    logic [VPN_BITS - 1 : 0] next_shifted_dr_VPN;
    assign #3 next_shifted_dr_VPN = regout_dr_data[VPN_UB : VPN_LB] + shifted_seg1_data[VPN_UB : VPN_LB] + 1'b1;
    assign next_shifted_dr_data = {next_shifted_dr_VPN, {NUM_OFFSET_BITS{1'b0}}};

    assign actual_next_st_vaddy = (st_sel) ? 
                                ((movs_op) ? next_shifted_dr_data : next_shifted_sr_data) :
                                next_st_vaddy;

endmodule
