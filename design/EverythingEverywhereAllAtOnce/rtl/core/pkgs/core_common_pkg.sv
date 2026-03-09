package core_common_pkg;

    import common_pkg::*;

    localparam int NUM_WB_ST_QS = 4;

    typedef enum {
        //{datasize, ID}
        AL  = 0,
        AX  = 8,
        EAX = 16,
        MM0 = 24,

        CL  = 1,
        CX  = 9,
        ECX = 17,
        MM1 = 25,

        DL  = 2,
        DX  = 10,
        EDX = 18,
        MM2 = 26,

        BL  = 3,
        BX  = 11,
        EBX = 19,
        MM3 = 27,

        AH  = 4,
        SP  = 12,
        ESP = 20,
        MM4 = 28,

        CH  = 5,
        BP  = 13,
        EBP = 21,
        MM5 = 29,

        DH  = 6,
        SI  = 14,
        ESI = 22,
        MM6 = 30,

        BH  = 7,
        DI  = 15,
        EDI = 23,
        MM7 = 31,

        CS = 32,
        DS = 33,
        SS = 34,
        ES = 35,
        FS = 36,
        GS = 37

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
    

    

    typedef struct {
        
    }dc_2_dcache_t;

    typedef struct{
    }dcache_2_mem_t;


    typedef struct {
        bool valid;
        bool miss_prediction;
        p_address_t br_target;
        bool taken;
        p_address_t br_eip;
        p_address_t neip;
    } execute_outputs_br_info_t;

    typedef struct {
        bool valid;
        bool stall;
        bool flush;
        execute_outputs_br_info_t br_res_out;
    } exe_outputs_t;

    //needs to feed into dache
    typedef struct {
        bool full;
        bool empty;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_outputs_t;

    typedef struct {
        bool valid;
        bool wb_stall;

        bool DR_0_we;
        reg_ids_e DR_0_id;
        uint64_t DR_0_data;

        bool DR_1_we;
        reg_ids_e DR_1_id;  //
        uint64_t DR_1_data;  //data is supposed to be aligned
        bool st_override;
        st_q_outputs_t st_outputs[NUM_WB_ST_QS];
    } wb_outputs_t;

endpackage

