package flag_fields_pkg;

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

endpackage
