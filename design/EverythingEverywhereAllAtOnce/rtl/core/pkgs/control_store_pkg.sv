package contorl_store_pkg;

    typedef enum {
        //----------------------------------------------------------
        // AAA — ASCII Adjust AL after Addition (aaa.sv)
        //----------------------------------------------------------
        AAA_OP,

        //----------------------------------------------------------
        // ADD — Addition (add.sv)
        //  Plain variants:  full-width immediate or register
        //  Sign  variants:  imm8 sign-extended to the target width
        //----------------------------------------------------------
        ADD8,       // ADD r/m8,  imm8 / r8
        ADD16,      // ADD r/m16, imm16 / r16
        ADD16sign,  // ADD r/m16, imm8 (sign-extended)
        ADD32,      // ADD r/m32, imm32 / r32
        ADD32sign,  // ADD r/m32, imm8 (sign-extended)

        //----------------------------------------------------------
        // ADC — Add with Carry (add_w_c.sv)
        //----------------------------------------------------------
        ADC32,     // ADC r/m32, imm32 / r32
        ADC32sign, // ADC r/m32, imm8 (sign-extended)

        //----------------------------------------------------------
        // AND — Bitwise AND (and.sv)
        //----------------------------------------------------------
        AND8,       // AND r/m8,  imm8 / r8
        AND16,      // AND r/m16, imm16 / r16
        AND16sign,  // AND r/m16, imm8 (sign-extended)
        AND32,      // AND r/m32, imm32 / r32
        AND32sign,  // AND r/m32, imm8 (sign-extended)

        //----------------------------------------------------------
        // NOT — Bitwise NOT (not.sv)
        //----------------------------------------------------------
        NOT8,   // NOT r/m8
        NOT16,  // NOT r/m16
        NOT32,  // NOT r/m32

        //----------------------------------------------------------
        // OR — Bitwise OR (or.sv)
        //----------------------------------------------------------
        OR8,       // OR r/m8,  imm8 / r8
        OR16,      // OR r/m16, imm16 / r16
        OR16sign,  // OR r/m16, imm8 (sign-extended)
        OR32,      // OR r/m32, imm32 / r32
        OR32sign,  // OR r/m32, imm8 (sign-extended)

        //----------------------------------------------------------
        // SAL — Shift Arithmetic Left (sal.sv)
        //----------------------------------------------------------
        SAL8,   // SAL r/m8,  1 / CL / imm8
        SAL16,  // SAL r/m16, 1 / CL / imm8
        SAL32,  // SAL r/m32, 1 / CL / imm8

        //----------------------------------------------------------
        // SAR — Shift Arithmetic Right (sar.sv)
        //----------------------------------------------------------
        SAR8,   // SAR r/m8,  1 / CL / imm8
        SAR16,  // SAR r/m16, 1 / CL / imm8
        SAR32,  // SAR r/m32, 1 / CL / imm8

        //----------------------------------------------------------
        // SBB — Subtract with Borrow (sub_w_b.sv)
        //----------------------------------------------------------
        SBB32,     // SBB r/m32, imm32 / r32
        SBB32sign, // SBB r/m32, imm8 (sign-extended)

        //----------------------------------------------------------
        // BSF — Bit Scan Forward (bsf.sv)
        //----------------------------------------------------------
        BSF16,  // BSF r16, r/m16
        BSF32,  // BSF r32, r/m32

        //----------------------------------------------------------
        // SIMD — Packed / MMX operations (simd.sv)
        //----------------------------------------------------------
        PADDW,     // Add packed word integers      (mm + mm/m64, 16-bit lanes)
        PADDD,     // Add packed dword integers     (mm + mm/m64, 32-bit lanes)
        PAVGB,     // Average packed unsigned bytes (mm + mm/m64,  8-bit lanes)
        PAVGW,     // Average packed unsigned words (mm + mm/m64, 16-bit lanes)
        PACKSSWB,  // Pack 4×i16 → 8×i8  with signed saturation
        PACKSSDW,  // Pack 2×i32 → 4×i16 with signed saturation

        COMPARE8,
        COMPARE16,
        COMPARE32,
        PASSA,
        PASSB

    } exe_cs_operation_type_e;

    typedef enum{
        SR_REGISTER,
        DR_REGISTER,
        IMM,
        BUFFER,
        NEIP,
        SEGMENT
    } source_selector_e;

endpackage
