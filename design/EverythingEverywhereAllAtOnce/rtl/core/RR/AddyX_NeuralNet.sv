module AddyX_NeuralNet (
    input logic[1:0] data_size,
    input l_address_t addy0,
    input bool mem_op,
    input uint32_t seg_data,
    input uint32_t seg_limit,
    input write_intent,
    output neuralnet_outputs_t outputs
);

    l_address_t addy1;
    v_address_t vaddy0;
    v_address_t vaddy1;
    p_address_t paddy1_aligned_temp;
    bool addy0_valid;
    bool addy1_valid;
    bool gp0_exp_temp_tlb, gp1_exp_temp_tlb, gp0_exp_temp_seg, gp1_exp_temp_seg;
    bool mio0, mio1;

    //do not use tag here since vaddy0 is virtual address, rest should be same so safe to use
    p_addr_dcache_fields_t vaddy0_fields = '{
        tag    : vaddy0[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : vaddy0[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : vaddy0[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : vaddy0[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    p_addr_dcache_fields_t vaddy1_fields = '{
        tag    : vaddy1[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : vaddy1[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : vaddy1[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : vaddy1[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    tlb_inputs_t tlb0_in = '{
        virtual_addr    : vaddy0,
        write_intention : write_intent
    };

    tlb_inputs_t tlb1_in = '{
        virtual_addr    : vaddy1,
        write_intention : write_intent
    };

    tlb_outputs_t tlb0_out = '{
        physical_addr           : outputs.paddy,
        physical_addr_valid     : addy0_valid,
        gp_exp                  : gp0_exp_temp_tlb,
        pageFault               : outputs.pf0_exception,
        MIO                     : mio0
    };

    tlb_outputs_t tlb1_out = '{
        physical_addr           : outputs.paddy_aligned_temp,
        physical_addr_valid     : addy1_valid,
        gp_exp                  : gp1_exp_temp_tlb,
        pageFault               : outputs.pf1_exception,
        MIO                     : mio1
    };

    assign outputs.bank_hi = vaddy0_fields.index == vaddy1_fields.index;
    assign outputs.xcl = (vaddy0_fields.bank[0] ^ vaddy1_fields.bank[0]) && mem_op;
    assign outputs.paddy_aligned = {outputs.paddy_aligned_temp[$clog2(PHY_MEM_SIZE) - 1 : 4], 4'b0};

    //if both addresses are valid and we are doing a ld/st op
    assign outputs.valid_mem_op = addy0_valid && addy1_valid && mem_op;
    assign outputs.gp0_exception = gp0_exp_temp_tlb || gp0_exp_temp_seg;
    assign outputs.gp1_exception = gp1_exp_temp_tlb || gp1_exp_temp_seg;

    SegmentTranslation segx0 (.l_addr_i(addy0), .dataSize_i(2'b00), .segValue(seg_data),
        .segLimit(seg_limit), .v_addr_o(vaddy0), .gp_fault_o(gp0_exp_temp_seg));

    TLB tlb0 (.inputs(tlb0_in), .outputs(tlb0_out));

    SegmentTranslation segx0 (.l_addr_i(addy1), .dataSize_i(2'b00), .segValue(seg_data),
        .segLimit(seg_limit), .v_addr_o(vaddy1), .gp_fault_o(gp1_exp_temp_seg));

    TLB tlb0 (.inputs(tlb1_in), .outputs(tlb1_out));

    always_comb begin
        unique case(data_size)
            //want to find the last byte of the data being pulled, if 16b access, must add 1 to address
            //if 32b access, must add 3 to address to find address of last byte since byte addressable mem
            2'b00: addy1 = addy0;
            2'b01: addy1 = addy0 + 32'd1;
            2'b10: addy1 = addy0 + 32'd3;
            2'b11: addy1 = addy0 + 32'd7;
        endcase
    end

endmodule
