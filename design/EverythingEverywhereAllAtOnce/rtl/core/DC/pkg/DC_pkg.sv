package DC_pkg;
    import common_pkg::*;
    import RegisterRead_pkg::*;

    typedef struct {
        bool DC_PF;
        bool DC_GP;
        bool valid_mem_op;
        p_address_t PADDR1;
        bool bank_hi;
        bool xcl;
        p_address_t PADDR0;
        bool mio;
    } npu_node2_outputs_t;

endpackage
