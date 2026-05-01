// ----------------------------------------------------------------
// Total number of registers
// ----------------------------------------------------------------
`define NUM_REGS        (26)
`define REG_ID_W        ($clog2(`NUM_REGS))           // $clog2(26) = 5

// ----------------------------------------------------------------
// Segment registers
// ----------------------------------------------------------------
`define CS              (`REG_ID_W'd0)
`define DS              (`REG_ID_W'd1)
`define SS              (`REG_ID_W'd2)
`define ES              (`REG_ID_W'd3)
`define FS              (`REG_ID_W'd4)
`define GS              (`REG_ID_W'd5)
`define EXPS            (`REG_ID_W'd6)

// ----------------------------------------------------------------
// General-purpose registers
// ----------------------------------------------------------------
`define EAX             (`REG_ID_W'd7)
`define EBX             (`REG_ID_W'd8)
`define ECX             (`REG_ID_W'd9)
`define EDX             (`REG_ID_W'd10)
`define ESI             (`REG_ID_W'd11)
`define EDI             (`REG_ID_W'd12)
`define ESP             (`REG_ID_W'd13)
`define EBP             (`REG_ID_W'd14)

// ----------------------------------------------------------------
// MMX registers
// ----------------------------------------------------------------
`define MM0             (`REG_ID_W'd15)
`define MM1             (`REG_ID_W'd16)
`define MM2             (`REG_ID_W'd17)
`define MM3             (`REG_ID_W'd18)
`define MM4             (`REG_ID_W'd19)
`define MM5             (`REG_ID_W'd20)
`define MM6             (`REG_ID_W'd21)
`define MM7             (`REG_ID_W'd22)

// ----------------------------------------------------------------
// Special registers
// ----------------------------------------------------------------
`define ETR             (`REG_ID_W'd23)
`define ERROR_REG       (`REG_ID_W'd24)
`define NO_REG          (`REG_ID_W'd25)