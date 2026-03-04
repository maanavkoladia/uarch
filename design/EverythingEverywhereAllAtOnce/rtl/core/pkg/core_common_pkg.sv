package core_common_pkg;

    import common_pkg::*;

    localparam int NUM_WB_ST_QS = 4;

    typedef enum {
        EAX = 0,
        EBX = 3,
        ECX = 1,
        EDX = 2,
        ESI = 6,
        EDI = 7,
        ESP = 4,
        EBP = 5,

        MM0 = 8,
        MM1 = 9,
        MM2 = 10,
        MM3 = 11,
        MM4 = 12,
        MM5 = 13,
        MM6 = 14,
        MM7 = 15,

        CS = 16,
        DS = 17,
        SS = 18,
        ES = 19,
        FS = 20,
        GS = 21

    } reg_ids_e;

    typedef enum {
        CF_IDX   = 0,   // Carry Flag
        PF_IDX   = 2,   // Parity Flag
        AF_IDX   = 4,   // Auxiliary Carry Flag
        ZF_IDX   = 6,   // Zero Flag
        SF_IDX   = 7,   // Sign Flag
        TF_IDX   = 8,   // Trap Flag
        IF_IDX   = 9,   // Interrupt Enable Flag
        DF_IDX   = 10,  // Direction Flag
        OF_IDX   = 11,  // Overflow Flag
        IOPL_IDX = 12,  // I/O Privilege Level (2 bits: 12-13)
        NT_IDX   = 14,  // Nested Task
        RF_IDX   = 16,  // Resume Flag
        VM_IDX   = 17,  // Virtual-8086 Mode
        AC_IDX   = 18,  // Alignment Check
        VIF_IDX  = 19,  // Virtual Interrupt Flag
        VIP_IDX  = 20,  // Virtual Interrupt Pending
        ID_IDX   = 21   // ID Flag (CPUID instruction support)
    } flags_idx_e;

    typedef uint32_t flags_t;

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

