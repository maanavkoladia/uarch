package TLB_pkg;
    import common_pkg::*;

    typedef struct {
        address_t virtual_addr;
        bool write_intention;
    } tlb_inputs_t;

    typedef struct {
        address_t physical_addr;
        bool physical_addr_valid;
        bool gp_exp;
        bool pageFault;
    } tlb_outputs_t;


endpackage
