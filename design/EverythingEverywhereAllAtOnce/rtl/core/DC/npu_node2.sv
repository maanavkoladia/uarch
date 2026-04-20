import DC_pkg::*;
import DCache_common_pkg::*;


//will need two seperate module inits, one for load and one for store adds
//each module will need starting and ending address
module npu_node2 (
    input v_address_t vaddy_start,
    input uint32_t seg_limit_w_datasize,
    input logic [1:0] datasize,
    input bool write_intent,
    input bool mem_op, //this will be 
    input v_address_t next_page_vaddy,
    output npu_node2_outputs_t outputs
);

    v_address_t vaddy_end;


    assign #3 vaddy_end = (datasize[1]) ? 
                            ((datasize[0]) ? (vaddy_start + 32'd7) : (vaddy_start + 32'd3)) :
                            ((datasize[0]) ? (vaddy_start + 32'd1) : (vaddy_start));
    
    bool cross_page_access;
    assign cross_page_access = vaddy_start[VPN_LB] ^ vaddy_end[VPN_LB];

    //do not use tag here since vaddy is virtual address, rest should be same so safe to use since VIPT
    //really only need to strip out the index and bank bits, don't need the rest, jsut decided to use the existing stripping mechanism
    p_addr_dcache_fields_t vaddy_start_fields;
    assign vaddy_start_fields = '{
        tag    : vaddy_start[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : vaddy_start[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : vaddy_start[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : vaddy_start[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    p_addr_dcache_fields_t vaddy_end_fields;
    assign vaddy_end_fields =  '{
        tag    : vaddy_end[DCACHE_BANK_TAG_UB : DCACHE_BANK_TAG_LB],
        index  : vaddy_end[DCACHE_BANK_INDEX_UB : DCACHE_BANK_INDEX_LB],
        bank   : vaddy_end[DCACHE_BANK_BANK_UB : DCACHE_BANK_BANK_LB],
        offset : vaddy_end[DCACHE_BANK_OFFSET_UB : DCACHE_BANK_OFFSET_LB]
    };

    tlb_inputs_t tlb0_in;
    assign tlb0_in = '{
        virtual_addr    : vaddy_start,
        write_intention : write_intent
    };

    tlb_inputs_t tlb1_in;
    assign tlb1_in = '{
        virtual_addr    : next_page_vaddy,
        write_intention : write_intent
    };

    tlb_outputs_t tlb0_out;
    tlb_outputs_t tlb1_out;

    TLB tlb0 (.inputs(tlb0_in), .outputs(tlb0_out));
    TLB tlb1 (.inputs(tlb1_in), .outputs(tlb1_out));

    bool tlb0_pagefault, tlb0_generalprotection;
    bool tlb1_pagefault, tlb1_generalprotection;

    assign tlb0_pagefault = tlb0_out.pageFault;
    assign tlb1_pagefault = cross_page_access ? tlb1_out.pageFault : 1'b0;
    assign tlb0_generalprotection = tlb0_out.gp_exp;
    assign tlb1_generalprotection = cross_page_access ? tlb1_out.gp_exp : 1'b0;

    //don't need to check both segment translations since the limit minus datasize will impose tighter restritions
    //no need to check the case without datasize included into calculation since data size imposes tighter restirctions
    // vaddy + datasize < limit
    // vaddy < limit - datasize, if vaddy is good ie, vaddy < limit - datasize, then ofc vaddy < limit, QED (i think)
    bool segx_gp;
    assign #3 segx_gp = vaddy_start > seg_limit_w_datasize;

    // SegmentTranslation segx0 (.l_addr_i(addy0), .segValue(seg_data),
    //     .segLimit(seg_limit), .v_addr_o(vaddy0), .gp_fault_o(gp0_exp_temp_seg));
    // SegmentTranslation segx1 (.l_addr_i(addy1), .segValue(seg_data),
    //     .segLimit(seg_limit), .v_addr_o(vaddy1), .gp_fault_o(gp1_exp_temp_seg));

  

    assign outputs.PADDR0 = tlb0_out.physical_addr;

    assign outputs.bank_hi = vaddy_start_fields.index != vaddy_end_fields.index;
    assign outputs.xcl = (vaddy_start_fields.bank[0] ^ vaddy_end_fields.bank[0]) && mem_op;
    assign outputs.PADDR1 = cross_page_access ? 
                            {tlb1_out.physical_addr[$clog2(PHY_MEM_SIZE) - 1 : 4], 4'b0} :
                            {tlb0_out.physical_addr[$clog2(PHY_MEM_SIZE) - 1 : VPN_LB], vaddy_end[VPN_LB - 1 : 0]};
                            //i dont think i need to get the page offset bits for the tlb1 access since
                            //a cross page access will never cross past the first cache line in the page i think

    assign outputs.DC_PF = (tlb0_pagefault || tlb1_pagefault);
    assign outputs.DC_GP = (tlb0_generalprotection || tlb1_generalprotection || segx_gp);

    //if both addresses are valid and we are doing a ld/st op
    assign outputs.valid_mem_op = tlb0_out.physical_addr_valid && 
                                    (cross_page_access ? tlb1_out.physical_addr_valid : tlb0_out.physical_addr_valid) && mem_op;
    assign outputs.mio = tlb0_out.MIO;

endmodule
