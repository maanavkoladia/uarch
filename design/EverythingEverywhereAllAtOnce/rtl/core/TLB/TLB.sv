//this needs to be updates to supprort mio stuf now
    import common_pkg::*;
    //for tlb entries and sutff
    import TLB_pkg::*;
    import core_common_pkg::tlb_inputs_t;
    import core_common_pkg::tlb_outputs_t;

module TLB (
    input  tlb_inputs_t  inputs,
    output tlb_outputs_t outputs
);



    tlb_entries_t tlb[entries];

    // init the tlb (simulation-only)
    initial begin
        // Identity mapping for addresses 0x00000000 - 0x0000FFFF
        tlb[0].valid = 1;
        tlb[0].present = 1;
        tlb[0].VPN = 0;  // Maps page 0
        tlb[0].PFN = 0;
        tlb[0].r_w = 1;
        tlb[0].MMIO = 0;

        // Map pages 1-5 for test addresses (normal, full permissions)
        for (int i = 1; i < 6; i++) begin
            tlb[i].valid = 1;
            tlb[i].present = 1;
            tlb[i].VPN = i;
            tlb[i].PFN = i;
            tlb[i].r_w = 1;
            tlb[i].MMIO = 0;
        end

        // Entry 6: Page fault test - valid mapping but page not present
        // Maps VPN=0xFFFF (address 0x0FFFF000) - valid but not present
        tlb[6].valid = 1;
        tlb[6].present = 0;  // NOT PRESENT -> page fault
        tlb[6].VPN = 24'hFFFF;  // Maps address 0x0FFFF000-0x0FFFFFFF
        tlb[6].PFN = 24'hFFFF;
        tlb[6].r_w = 1;
        tlb[6].MMIO = 0;

        // Entry 7: GP fault test - valid, present, but read-only (no write permission)
        // Maps VPN=0xFFFE (address 0x0FFFE000) - read-only page
        tlb[7].valid = 1;
        tlb[7].present = 1;
        tlb[7].VPN = 24'hFFFE;  // Maps address 0x0FFFE000-0x0FFFEFFFF
        tlb[7].PFN = 24'hFFFE;
        tlb[7].r_w = 0;  // READ-ONLY -> GP fault on write
        tlb[7].MMIO = 0;
        
        // Note: Unmapped addresses (VPN not in TLB) will also generate page fault
        // due to default pageFault=1 when no entry matches
    end

    // ------------------------
    // Physical address lookup
    // ------------------------
    always_comb begin
        outputs.physical_addr = '0;
        outputs.physical_addr_valid = 0;
        outputs.MIO = 0;
        for (int i = 0; i < entries; i++) begin
            if (tlb[i].valid && tlb[i].VPN == inputs.virtual_addr[ADDRESS_BITS-1:OFFSET_BITS]) begin
                outputs.physical_addr_valid = 1;
                outputs.physical_addr = {tlb[i].PFN, inputs.virtual_addr[OFFSET_BITS-1:0]};
                outputs.MIO = tlb[i].MMIO;
            end
        end
    end

    // ------------------------
    // General protection exception
    // ------------------------
    always_comb begin
        outputs.gp_exp = 1;  // default: exception
        for (int i = 0; i < entries; i++) begin
            if (tlb[i].valid && tlb[i].VPN == inputs.virtual_addr[ADDRESS_BITS-1:OFFSET_BITS]) begin
                // if write, check r_w
                if (inputs.write_intention && tlb[i].r_w) outputs.gp_exp = 0;
                // if read, always allow
                else if (!inputs.write_intention) outputs.gp_exp = 0;
            end
        end
    end

    // ------------------------
    // Page fault
    // ------------------------
    always_comb begin
        outputs.pageFault = 1;  // default: page fault
        for (int i = 0; i < entries; i++) begin
            if (tlb[i].valid &&
                tlb[i].VPN == inputs.virtual_addr[ADDRESS_BITS-1:OFFSET_BITS] &&
                tlb[i].present)
            begin
                outputs.pageFault = 0;
            end
        end
    end

endmodule

