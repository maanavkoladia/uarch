package contorl_store_pkg;

    typedef enum {
        //----------------------------------------------------------
        // AAA — ASCII Adjust AL after Addition (aaa.sv)
        //----------------------------------------------------------
        AAA,

        //----------------------------------------------------------
        // ADD — Addition (add.sv)
        //  Plain variants:  full-width immediate or register
        //  Sign  variants:  imm8 sign-extended to the target width
        //----------------------------------------------------------
        // ADD8,       // ADD r/m8,  imm8 / r8
        // ADD16,      // ADD r/m16, imm16 / r16
        // ADD16sign,  // ADD r/m16, imm8 (sign-extended)
        // ADD32,      // ADD r/m32, imm32 / r32
        // ADD32sign,  // ADD r/m32, imm8 (sign-extended)
        ADD,

        //----------------------------------------------------------
        // ADC — Add with Carry (add_w_c.sv)
        //----------------------------------------------------------
        // ADC32,     // ADC r/m32, imm32 / r32
        // ADC32sign, // ADC r/m32, imm8 (sign-extended)
        ADC,

        //----------------------------------------------------------
        // AND — Bitwise AND (and.sv)
        //----------------------------------------------------------
        // AND8,       // AND r/m8,  imm8 / r8
        // AND16,      // AND r/m16, imm16 / r16
        // AND16sign,  // AND r/m16, imm8 (sign-extended)
        // AND32,      // AND r/m32, imm32 / r32
        // AND32sign,  // AND r/m32, imm8 (sign-extended)
        AND,
        //----------------------------------------------------------
        // NOT — Bitwise NOT (not.sv)
        //----------------------------------------------------------
        // NOT8,   // NOT r/m8
        // NOT16,  // NOT r/m16
        // NOT32,  // NOT r/m32
        NOT,
        //----------------------------------------------------------
        // OR — Bitwise OR (or.sv)
        //----------------------------------------------------------
        // OR8,       // OR r/m8,  imm8 / r8
        // OR16,      // OR r/m16, imm16 / r16
        // OR16sign,  // OR r/m16, imm8 (sign-extended)
        // OR32,      // OR r/m32, imm32 / r32
        // OR32sign,  // OR r/m32, imm8 (sign-extended)
        OR,
        //----------------------------------------------------------
        // SAL — Shift Arithmetic Left (sal.sv)
        //----------------------------------------------------------
        // SAL8,   // SAL r/m8,  1 / CL / imm8
        // SAL16,  // SAL r/m16, 1 / CL / imm8
        // SAL32,  // SAL r/m32, 1 / CL / imm8
        SAL,
        //----------------------------------------------------------
        // SAR — Shift Arithmetic Right (sar.sv)
        //----------------------------------------------------------
        // SAR8,   // SAR r/m8,  1 / CL / imm8
        // SAR16,  // SAR r/m16, 1 / CL / imm8
        // SAR32,  // SAR r/m32, 1 / CL / imm8
        SAR,
        //----------------------------------------------------------
        // SBB — Subtract with Borrow (sub_w_b.sv)
        //----------------------------------------------------------
        // SBB32,     // SBB r/m32, imm32 / r32
        // SBB32sign, // SBB r/m32, imm8 (sign-extended)
        SBB,
        //----------------------------------------------------------
        // BSF — Bit Scan Forward (bsf.sv)
        //----------------------------------------------------------
        // BSF16,  // BSF r16, r/m16
        // BSF32,  // BSF r32, r/m32
        BSF,
        //----------------------------------------------------------
        // SIMD — Packed / MMX operations (simd.sv)
        //----------------------------------------------------------
        PADDW,     // Add packed word integers      (mm + mm/m64, 16-bit lanes)
        PADDD,     // Add packed dword integers     (mm + mm/m64, 32-bit lanes)
        PAVGB,     // Average packed unsigned bytes (mm + mm/m64,  8-bit lanes)
        PAVGW,     // Average packed unsigned words (mm + mm/m64, 16-bit lanes)
        PACKSSWB,  // Pack 4×i16 → 8×i8  with signed saturation
        PACKSSDW,  // Pack 2×i32 → 4×i16 with signed saturation

        // COMPARE8,
        // COMPARE16,
        // COMPARE32,
        CMP,

        //NONE ALU OPERATIONS
        CALL,
        FAR_CALL,
        CMPXCHG,
        IRETD,
        MOV,
        POP,
        PUSH,
        RET,
        RET_IMM,
        RET_FAR,
        RET_FAR_IMM,
        XCHG,

        PASSA,
        PASSB

    } exe_cs_operation_type_e;

    typedef enum{
        //register 
        NOP,
        SR_REGISTER,
        DR_REGISTER, //alu or branch 
        BUFFER, //128 bits you can use this one for all alu ops
        NEIP,
        SEGMENT,
        SEXT8,
        SEGMENT_NEIP,
        IMM64, //I think for regular ALU ops the operation size is always the same or sign extended

        //I think this would just be for branches. 
        IMM32, //rel 32
        ZEXT_IMM16, //rel 16
        ZEXT_IMM8, //rel8 
        BUF32, //m32 for branch
        ZEXT_BUF16 //m16 for branch

    
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

endpackage
