package control_store_pkg;

    typedef enum {
        CF_IDX   = 0,   // Carry Flag
        PF_IDX   = 2,   // Parity Flag
        AF_IDX   = 4,   // Auxiliary Carry Flag
        ZF_IDX   = 6,   // Zero Flag
        SF_IDX   = 7,   // Sign Flag
        //TF_IDX   = 8,   // Trap Flag
        //IF_IDX   = 9,   // Interrupt Enable Flag
        DF_IDX   = 10,  // Direction Flag
        OF_IDX   = 11  // Overflow Flag
        // IOPL_IDX = 12,  // I/O Privilege Level (2 bits: 12-13)
        // NT_IDX   = 14,  // Nested Task
        // RF_IDX   = 16,  // Resume Flag
        // VM_IDX   = 17,  // Virtual-8086 Mode
        // AC_IDX   = 18,  // Alignment Check
        // VIF_IDX  = 19,  // Virtual Interrupt Flag
        // VIP_IDX  = 20,  // Virtual Interrupt Pending
        // ID_IDX   = 21   // ID Flag (CPUID instruction support)
    } flags_idx_e;

    typedef enum {
        //----------------------------------------------------------
        // AAA — ASCII Adjust AL after Addition (aaa.sv)
        //----------------------------------------------------------
        AAA          = 0,

        //----------------------------------------------------------
        // ADD — Addition (add.sv)
        //  Plain variants:  full-width immediate or register
        //  Sign  variants:  imm8 sign-extended to the target width
        //----------------------------------------------------------
        ADD          = 1,

        //----------------------------------------------------------
        // ADC — Add with Carry (add_w_c.sv)
        //----------------------------------------------------------
        ADC          = 2,

        //----------------------------------------------------------
        // AND — Bitwise AND (and.sv)
        //----------------------------------------------------------
        AND          = 3,

        //----------------------------------------------------------
        // NOT — Bitwise NOT (not.sv)
        //----------------------------------------------------------
        NOT          = 4,

        //----------------------------------------------------------
        // OR — Bitwise OR (or.sv)
        //----------------------------------------------------------
        OR           = 5,

        //----------------------------------------------------------
        // SAL — Shift Arithmetic Left (sal.sv)
        //----------------------------------------------------------
        SAL          = 6,

        //----------------------------------------------------------
        // SAR — Shift Arithmetic Right (sar.sv)
        //----------------------------------------------------------
        SAR          = 7,

        //----------------------------------------------------------
        // SBB — Subtract with Borrow (sub_w_b.sv)
        //----------------------------------------------------------
        SBB          = 8,

        //----------------------------------------------------------
        // BSF — Bit Scan Forward (bsf.sv)
        //----------------------------------------------------------
        BSF          = 9,

        //----------------------------------------------------------
        // SIMD — Packed / MMX operations (simd.sv)
        //----------------------------------------------------------
        PADDW        = 10,  // Add packed word integers      (mm + mm/m64, 16-bit lanes)
        PADDD        = 11,  // Add packed dword integers     (mm + mm/m64, 32-bit lanes)
        PAVGB        = 12,  // Average packed unsigned bytes (mm + mm/m64,  8-bit lanes)
        PAVGW        = 13,  // Average packed unsigned words (mm + mm/m64, 16-bit lanes)
        PACKSSWB     = 14,  // Pack 4×i16 → 8×i8  with signed saturation
        PACKSSDW     = 15,  // Pack 2×i32 → 4×i16 with signed saturation

        //----------------------------------------------------------
        // CMP — Compare (cmp.sv)
        //----------------------------------------------------------
        CMP          = 16,

        //----------------------------------------------------------
        // Non-ALU / Control Flow Operations
        //----------------------------------------------------------
        STD          = 17,
        CALL         = 18,
        FAR_CALL     = 19,
        CMPXCHG      = 20,
        IRETD        = 21,
        MOV          = 22,
        POP          = 23,
        PUSH         = 24,
        RET          = 25,
        RET_IMM      = 26,
        RET_FAR      = 27,
        RET_FAR_IMM  = 28,
        XCHG         = 29,
        CLD          = 30,
        CMOVC        = 31,
        JMP          = 32,
        NOP          = 33,
        ADD_DF       = 34,   // Special internal-only operation for ADD with Direction Flag handling
        MOVS         = 35,
        FAR_JMP32    = 36,
        FAR_JMP16    = 37,
        EXP_CALL     = 38
    } exe_cs_operation_type_e;

    typedef enum{
        //register
        NO_EXE = 0,
        SR_REGISTER = 1,
        DR_REGISTER = 2,    //alu or branch 
        BUFFER = 3,         //128 bits you can use this one for all alu ops
        NEIP = 4,           //PUSH and POP stuff and JMP
        EAX_REG = 5,            //CMPXCHG
        SEXT8 = 6,          //SIGN extended alu ops
        SEGMENT_NEIP =7 ,   //Far calls 
        IMM64 = 8,          //I think for regular ALU ops the operation size is always the same or sign extended
        
        //BRANCHES
        IMM32 = 9,          //rel 32
        ZEXT_IMM8 = 10,     //rel8 
        BUF32 = 11,         //m32 for branch
        ZEXT_BUF16 = 12,     //m16 for branch,
        ZEXT_IMM16 = 13,    //rel 16 for branch
        SEGMENT_EIP = 14,
        FLAGS = 15,
        EIP = 16,           //similar to NEIP but for EIP
        CMPXCHG_SEL = 17,       //cmpxchg operation
        SR_DR_SEL = 18,
        IRETD_SEL = 19      //iretd operation  p

    // How source selection works in the ALU input selector:
    //refined comment with claude so its coherent buddy
    // 1. All sources first get assigned to a 128-bit wire (srA_128/srB_128)
    //    - Most sources zero-extend:  srA_128 = {64'd0, dr_data}
    //    - Immediates zero-extend:    srA_128 = {64'd0, imm64}
    //    - Buffer uses full width:    srA_128 = res_buf_out  (for IRET's 12-byte data)
    //    - Sign-extend when needed:   srA_128 = {64'd0, 64'(signed'(imm64[7:0]))}
    //
    // 2. For ALU operations: just mask down to the operation size
    //    - ALU ops always operate on matching-size operands, so we truncate the
    //      128-bit wire to whatever size we need (8, 16, 32, or 64 bits)
    //    - Ex: ADD16 uses srA_16 and srB_16 (both are just srX_128[15:0])
    //
    // 3. For branches: different story - always work with 32-bit values
    //    - Branches need 32-bit arithmetic (like NEIP + disp8)
    //    - So we need IMM8/IMM16/IMM32 to produce 32-bit zero-extended values
    //    - Ex: IMM8 for branch → br_sel = {24'd0, imm8}, not just imm8[7:0]
    //    - That way branch resolution can always do a clean 32-bit add
    //     - basically branches have to be ZERO EXTENDED .. maybe chat made this shi too convoluted 
    //
    // Note: We DON'T need separate IMM8/IMM16 for ALU ops since those need
    // actual 8-bit/16-bit wires, which we get by truncating srX_128


    } source_selector_e;

    typedef enum logic [1:0] {
        NONE = 0,
        CTRL = 1,
        SHF = 2,
        ALU = 3
    } op_in_modrm_subset_t;

endpackage
