// EXE structural local defines.
// Widths and constants used by all *_structural.v files in this directory.
// Mirrors enum encodings in rtl/core/pkgs/{control_store,reg_ids}_pkg.sv.

`ifndef EXE_STRUCTURAL_DEFINES_VH
`define EXE_STRUCTURAL_DEFINES_VH

// ---- Width parameters ----
`define EXE_STRUCT_OP_W       6   // exe_cs_operation_type_e: 0..39 → 6 bits
`define EXE_STRUCT_SRC_SEL_W  5   // source_selector_e: 0..19 → 5 bits
`define EXE_STRUCT_REG_ID_W   5   // reg_ids_e: 0..25 → 5 bits
`define EXE_STRUCT_P_ADDR_W   15  // p_address_t = $clog2(PHY_MEM_SIZE=32768) = 15 bits

// ---- exe_cs_operation_type_e encodings ----
`define EXE_OP_AAA          6'd0
`define EXE_OP_ADD          6'd1
`define EXE_OP_ADC          6'd2
`define EXE_OP_AND          6'd3
`define EXE_OP_NOT          6'd4
`define EXE_OP_OR           6'd5
`define EXE_OP_SAL          6'd6
`define EXE_OP_SAR          6'd7
`define EXE_OP_SBB          6'd8
`define EXE_OP_BSF          6'd9
`define EXE_OP_PADDW        6'd10
`define EXE_OP_PADDD        6'd11
`define EXE_OP_PAVGB        6'd12
`define EXE_OP_PAVGW        6'd13
`define EXE_OP_PACKSSWB     6'd14
`define EXE_OP_PACKSSDW     6'd15
`define EXE_OP_CMP          6'd16
`define EXE_OP_STD          6'd17
`define EXE_OP_CALL         6'd18
`define EXE_OP_FAR_CALL     6'd19
`define EXE_OP_CMPXCHG      6'd20
`define EXE_OP_IRETD        6'd21
`define EXE_OP_MOV          6'd22
`define EXE_OP_POP          6'd23
`define EXE_OP_PUSH         6'd24
`define EXE_OP_RET          6'd25
`define EXE_OP_RET_IMM      6'd26
`define EXE_OP_RET_FAR      6'd27
`define EXE_OP_RET_FAR_IMM  6'd28
`define EXE_OP_XCHG         6'd29
`define EXE_OP_CLD          6'd30
`define EXE_OP_CMOVC        6'd31
`define EXE_OP_JMP          6'd32
`define EXE_OP_NOP          6'd33
`define EXE_OP_ADD_DF       6'd34
`define EXE_OP_MOVS         6'd35
`define EXE_OP_FAR_JMP32    6'd36
`define EXE_OP_FAR_JMP16    6'd37
`define EXE_OP_EXP_CALL     6'd38
`define EXE_OP_REP_CMP      6'd39

// ---- source_selector_e encodings ----
`define EXE_SRC_NO_EXE       5'd0
`define EXE_SRC_SR_REGISTER  5'd1
`define EXE_SRC_DR_REGISTER  5'd2
`define EXE_SRC_BUFFER       5'd3
`define EXE_SRC_NEIP         5'd4
`define EXE_SRC_EAX_REG      5'd5
`define EXE_SRC_SEXT8        5'd6
`define EXE_SRC_SEGMENT_NEIP 5'd7
`define EXE_SRC_IMM64        5'd8
`define EXE_SRC_IMM32        5'd9
`define EXE_SRC_ZEXT_IMM8    5'd10
`define EXE_SRC_BUF32        5'd11
`define EXE_SRC_ZEXT_BUF16   5'd12
`define EXE_SRC_ZEXT_IMM16   5'd13
`define EXE_SRC_SEGMENT_EIP  5'd14
`define EXE_SRC_FLAGS        5'd15
`define EXE_SRC_EIP          5'd16
`define EXE_SRC_CMPXCHG_SEL  5'd17
`define EXE_SRC_SR_DR_SEL    5'd18
`define EXE_SRC_IRETD_SEL    5'd19

// ---- reg_ids_e encodings (subset used) ----
`define EXE_REG_CS    5'd0
`define EXE_REG_EAX   5'd7

// ---- flag bit indices in flags_reg ----
`define EXE_FLAG_CF_IDX  0
`define EXE_FLAG_PF_IDX  2
`define EXE_FLAG_AF_IDX  4
`define EXE_FLAG_ZF_IDX  6
`define EXE_FLAG_SF_IDX  7
`define EXE_FLAG_DF_IDX  10
`define EXE_FLAG_OF_IDX  11

`endif
