module TLB (
    input  tlb_inputs_t  inputs,
    output tlb_outputs_t outputs
);

    localparam int entries = 8;
    localparam int OFFSET_BITS = $clog2(PAGE_SIZE);
    localparam int VPN_BITS = ADDRESS_BITS - OFFSET_BITS;

    typedef struct {
        logic [VPN_BITS-1:0] VPN;
        logic [VPN_BITS-1:0] PFN;
        bool valid;
        bool present;
        bool r_w;  // write permission: 1 = writable
    } tlb_entries_t;

    tlb_entries_t tlb[entries];

    // init the tlb (simulation-only)
    initial begin
        // TODO: read from CSV or initialize manually
    end

    // ------------------------
    // Physical address lookup
    // ------------------------
    always_comb begin
        outputs.physical_addr = '0;
        outputs.physical_addr_valid = 0;
        for (int i = 0; i < entries; i++) begin
            if (tlb[i].valid && tlb[i].VPN == inputs.virtual_addr[ADDRESS_BITS-1:OFFSET_BITS]) begin
                outputs.physical_addr_valid = 1;
                outputs.physical_addr = {tlb[i].PFN, inputs.virtual_addr[OFFSET_BITS-1:0]};
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
