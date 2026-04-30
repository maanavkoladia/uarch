// Structural Verilog-2005 port of rtl/DCache/DCache_Block/EvictionBuf/EvictionBuf.sv
//
// Single-entry eviction buffer for the VCache. Holds one dirty cache line
// while it waits to be written back to main memory.
//
// Storage: { dataLine[127:0], address[14:0], valid, commiting } = 145 bits.
// Hit = validReq & eb.valid & (blockReq.p_addr[14:4] == eb.address[14:4]).
//
// State transitions (priority, on posedge clk_i):
//   1. load_action  = LD_EB & ~valid           : capture lineOut/addrOut, valid<=1, commiting<=0
//   2. clear_action = ~load_action & eb_clr_i  : valid<=0, commiting<=0
//   3. commit_action= ~load_action & ~eb_clr_i & set_commiting : commiting<=1
//   else hold.

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module EvictionBuf (
    input  wire                       clk_i,
    input  wire                       rst_i,            // active-low
    input  wire                       eb_clr_i,
    input  wire                       set_commiting,
    input  wire [`BREQ_W   - 1 : 0]   blockReq_i,
    input  wire [`VC_OUT_W - 1 : 0]   vcache_outputs_i,
    output wire [`EB_OUT_W - 1 : 0]   outputs_o
);

    //------------------------------------------------------------------
    // Field extraction from packed inputs (pure slicing, no logic)
    //------------------------------------------------------------------
    wire         breq_oe;
    wire         breq_we;
    wire [`P_ADDR_W - 1 : 0] breq_paddr;
    wire         vc_LD_EB;
    wire [`P_ADDR_W - 1 : 0] vc_addrOut;
    wire [`CL_W    - 1 : 0]  vc_lineOut;

    assign breq_oe     = blockReq_i[`BREQ_OE];
    assign breq_we     = blockReq_i[`BREQ_WE];
    assign breq_paddr  = blockReq_i[`BREQ_PADDR_UB:`BREQ_PADDR_LB];
    assign vc_LD_EB    = vcache_outputs_i[`VC_OUT_LD_EB];
    assign vc_addrOut  = vcache_outputs_i[`VC_OUT_ADDR_UB:`VC_OUT_ADDR_LB];
    assign vc_lineOut  = vcache_outputs_i[`VC_OUT_LINE_UB:`VC_OUT_LINE_LB];

    //------------------------------------------------------------------
    // Storage flop outputs
    //------------------------------------------------------------------
    wire                       eb_valid_q;
    wire                       eb_commiting_q;
    wire [`P_ADDR_W - 1 : 0]   eb_address_q;
    wire [`CL_W    - 1 : 0]    eb_dataLine_q;

    //------------------------------------------------------------------
    // Action decode
    //------------------------------------------------------------------
    wire eb_valid_inv;
    wire load_action;        // = LD_EB & ~valid
    wire load_action_inv;
    wire eb_clr_inv;
    wire clear_action;       // = ~load & eb_clr
    wire commit_pre;         // = ~load & ~eb_clr
    wire commit_action;      // = commit_pre & set_commiting
    wire valid_we;           // = load | clear
    wire commiting_we;       // = load | clear | commit_action

    `INV_N(inv_valid,    1, eb_valid_q,   eb_valid_inv)
    `AND_2(and_load,     1, load_action,  vc_LD_EB,        eb_valid_inv)

    `INV_N(inv_load,     1, load_action,  load_action_inv)
    `INV_N(inv_clr,      1, eb_clr_i,     eb_clr_inv)
    `AND_2(and_clear,    1, clear_action, load_action_inv, eb_clr_i)
    `AND_2(and_commitpre,1, commit_pre,   load_action_inv, eb_clr_inv)
    `AND_2(and_commitact,1, commit_action,commit_pre,      set_commiting)

    `OR_2 (or_valid_we,  1, valid_we,     load_action,     clear_action)
    `OR_3 (or_commiting_we, 1, commiting_we, load_action, clear_action, commit_action)

    //------------------------------------------------------------------
    // Storage flops
    //   d_valid     = load_action  (1 on load, 0 on clear; otherwise WE=0 holds)
    //   d_commiting = commit_action (1 on commit; 0 on load/clear)
    //------------------------------------------------------------------
    `REG_RST_WE(ff_valid,    1,                        clk_i, rst_i, valid_we,     load_action,  eb_valid_q)
    `REG_RST_WE(ff_commiting,1,                        clk_i, rst_i, commiting_we, commit_action, eb_commiting_q)
    `REG_RST_WE(ff_addr,    `P_ADDR_W,                 clk_i, rst_i, load_action,  vc_addrOut,   eb_address_q)
    `REG_RST_WE(ff_line,    `CL_W,                     clk_i, rst_i, load_action,  vc_lineOut,   eb_dataLine_q)

    //------------------------------------------------------------------
    // Hit detection: 11-bit equality on p_addr[14:4] vs address_q[14:4].
    // Split into 6-bit + 5-bit compares (MPS_COMP_EQ supports 2,3,4,5,6,8,9).
    //------------------------------------------------------------------
    wire validReq;
    wire cmp_lo;             // bits [9:4]   (6 bits)
    wire cmp_hi;             // bits [14:10] (5 bits)
    wire cmp_eq;             // cmp_lo & cmp_hi
    wire valid_and_eq;
    wire hit;

    `OR_2 (or_validReq,  1, validReq, breq_oe, breq_we)
    `CMP_N(cmp_eblo,     6, cmp_lo,   breq_paddr[9:4],  eb_address_q[9:4])
    `CMP_N(cmp_ebhi,     5, cmp_hi,   breq_paddr[14:10],eb_address_q[14:10])
    `AND_2(and_cmp,      1, cmp_eq,   cmp_lo,           cmp_hi)
    `AND_2(and_vand,     1, valid_and_eq, eb_valid_q,   cmp_eq)
    `AND_2(and_hit,      1, hit,      validReq,         valid_and_eq)

    //------------------------------------------------------------------
    // Output bus assembly
    //------------------------------------------------------------------
    assign outputs_o[`EB_OUT_VALID]                          = eb_valid_q;
    assign outputs_o[`EB_OUT_COMMITING]                      = eb_commiting_q;
    assign outputs_o[`EB_OUT_ADDR_UB:`EB_OUT_ADDR_LB]        = eb_address_q;
    assign outputs_o[`EB_OUT_LINE_UB:`EB_OUT_LINE_LB]        = eb_dataLine_q;
    assign outputs_o[`EB_OUT_REQHIT]                         = hit;

endmodule
