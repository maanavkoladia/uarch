package TLB_pkg;
    import common_pkg::*;

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

endpackage
