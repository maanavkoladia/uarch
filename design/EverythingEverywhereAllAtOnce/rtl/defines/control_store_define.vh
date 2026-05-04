// ================================================================
// flags_idx_e
//   Bit-position indices into the EFLAGS register.
//   Max value = 11 (OF) -> 4 bits.
// ================================================================
`define FLAGS_IDX_W     4

`define CF_IDX          (`FLAGS_IDX_W'd0)   // Carry Flag
`define PF_IDX          (`FLAGS_IDX_W'd2)   // Parity Flag
`define AF_IDX          (`FLAGS_IDX_W'd4)   // Auxiliary Carry Flag
`define ZF_IDX          (`FLAGS_IDX_W'd6)   // Zero Flag
`define SF_IDX          (`FLAGS_IDX_W'd7)   // Sign Flag
`define DF_IDX          (`FLAGS_IDX_W'd10)  // Direction Flag
`define OF_IDX          (`FLAGS_IDX_W'd11)  // Overflow Flag

// ================================================================
// exe_cs_operation_type_e
//   Total enumerators = 40 (0..39) -> 6 bits.
// ================================================================
`define NUM_EXE_OPS     (40)
`define EXE_OP_W        6

// ----------------------------------------------------------------
// ALU / arithmetic
// ----------------------------------------------------------------
`define AAA         (`EXE_OP_W'd0)
`define ADD         (`EXE_OP_W'd1)
`define ADC         (`EXE_OP_W'd2)
`define AND         (`EXE_OP_W'd3)
`define NOT         (`EXE_OP_W'd4)
`define OR          (`EXE_OP_W'd5)
`define SAL         (`EXE_OP_W'd6)
`define SAR         (`EXE_OP_W'd7)
`define SBB         (`EXE_OP_W'd8)
`define BSF         (`EXE_OP_W'd9)

// ----------------------------------------------------------------
// SIMD / MMX
// ----------------------------------------------------------------
`define PADDW       (`EXE_OP_W'd10)
`define PADDD       (`EXE_OP_W'd11)
`define PAVGB       (`EXE_OP_W'd12)
`define PAVGW       (`EXE_OP_W'd13)
`define PACKSSWB    (`EXE_OP_W'd14)
`define PACKSSDW    (`EXE_OP_W'd15)

// ----------------------------------------------------------------
// Compare
// ----------------------------------------------------------------
`define CMP         (`EXE_OP_W'd16)

// ----------------------------------------------------------------
// Non-ALU / control flow / data movement
// ----------------------------------------------------------------
`define STD         (`EXE_OP_W'd17)
`define CALL        (`EXE_OP_W'd18)
`define FAR_CALL    (`EXE_OP_W'd19)
`define CMPXCHG     (`EXE_OP_W'd20)
`define IRETD       (`EXE_OP_W'd21)
`define MOV         (`EXE_OP_W'd22)
`define POP         (`EXE_OP_W'd23)
`define PUSH        (`EXE_OP_W'd24)
`define RET         (`EXE_OP_W'd25)
`define RET_IMM     (`EXE_OP_W'd26)
`define RET_FAR     (`EXE_OP_W'd27)
`define RET_FAR_IMM (`EXE_OP_W'd28)
`define XCHG        (`EXE_OP_W'd29)
`define CLD         (`EXE_OP_W'd30)
`define CMOVC       (`EXE_OP_W'd31)
`define JMP         (`EXE_OP_W'd32)
`define NOP         (`EXE_OP_W'd33)
`define ADD_DF      (`EXE_OP_W'd34)
`define MOVS        (`EXE_OP_W'd35)
`define FAR_JMP32   (`EXE_OP_W'd36)
`define FAR_JMP16   (`EXE_OP_W'd37)
`define EXP_CALL    (`EXE_OP_W'd38)
`define REP_CMP     (`EXE_OP_W'd39)

// ================================================================
// source_selector_e
//   Total enumerators = 20 (0..19) -> 5 bits.
// ================================================================
`define NUM_SRC_SELS    20
`define SRC_SEL_W       5

// ----------------------------------------------------------------
// Register / buffer / immediate sources
// ----------------------------------------------------------------
`define NO_EXE      (`SRC_SEL_W'd0)
`define SR_REGISTER (`SRC_SEL_W'd1)
`define DR_REGISTER (`SRC_SEL_W'd2)
`define BUFFER      (`SRC_SEL_W'd3)
`define NEIP        (`SRC_SEL_W'd4)
`define EAX_REG     (`SRC_SEL_W'd5)
`define SEXT8       (`SRC_SEL_W'd6)
`define SEGMENT_NEIP (`SRC_SEL_W'd7)
`define IMM64       (`SRC_SEL_W'd8)

// ----------------------------------------------------------------
// Branch sources
// ----------------------------------------------------------------
`define IMM32       (`SRC_SEL_W'd9)
`define ZEXT_IMM8   (`SRC_SEL_W'd10)
`define BUF32       (`SRC_SEL_W'd11)
`define ZEXT_BUF16  (`SRC_SEL_W'd12)
`define ZEXT_IMM16  (`SRC_SEL_W'd13)
`define SEGMENT_EIP (`SRC_SEL_W'd14)
`define FLAGS       (`SRC_SEL_W'd15)
`define EIP         (`SRC_SEL_W'd16)
`define CMPXCHG_SEL (`SRC_SEL_W'd17)
`define SR_DR_SEL   (`SRC_SEL_W'd18)
`define IRETD_SEL   (`SRC_SEL_W'd19)

// ================================================================
// op_in_modrm_subset_t (explicit 2-bit enum in the package)
// ================================================================
`define OP_IN_MODRM_W   2

`define NONE       (`OP_IN_MODRM_W'd0)
`define CTRL       (`OP_IN_MODRM_W'd1)
`define SHF        (`OP_IN_MODRM_W'd2)
`define ALU        (`OP_IN_MODRM_W'd3)

`endif
