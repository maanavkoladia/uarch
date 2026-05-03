// ----------------------------------------------------------------
// req_gen_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/req_gen_logic.sv
//
//   stall          = exp_stall | dep_stall
//   forward_valid  = mem_stage_we_valid_unit_o & mem_stage_next_valid_o
//   clear          = forward_valid | flush
//   set_X          = req_served_X & valid                 (X in {0,1,mio})
//
//   is_served_X next-state (priority: clear > set > hold):
//      clear ? 0 : set_X ? 1 : is_served_X
//   Reset (active-low): is_served_X = 0
//
//   mio_stall = ~req_served_mio & ~is_served_mio & MIO       & LD_OP
//   ld_0_stall = ~req_served_0   & ~is_served_0   & ~MIO      & LD_OP
//   ld_1_stall = ~req_served_1   & ~is_served_1   & ~MIO & XCL & LD_OP
//   arb_stall = (mio_stall | ld_0_stall | ld_1_stall) & valid
//
//   Cache-line-align addresses: low 4 bits forced to 0
//      ld_addr_X = { ld_addrX[14:4], 4'b0000 }              (15-bit p_address_t)
//
//   ld_addr_0_V   = ~stall & LD_OP & valid & ~MIO  & ~is_served_0   & ~flush
//   ld_addr_1_V   = ~stall & LD_OP & valid & ~MIO  & ~is_served_1   & ~flush & XCL
//   ld_addr_mio_V = ~stall & LD_OP & valid &  MIO & ~is_served_mio & ~flush
//
// Critical path notes:
//   - arb_stall and ld_addr_*_V feed the slow D-cache arbiter, so on-CP.
//   - Per plan: substitute NAND/NOR when fan-in >= 3 on CP modules.
//     - Each `~req_served_X & ~is_served_X` collapses to NOR_2 (saves 2 INVs).
//     - V-signal `~stall & ~MIO & ~is_served & ~flush` collapses to NOR_4
//       (saves 4 INVs each); the `_mio_V` form uses NOR_3 (no MIO inversion).
//   - LD_OP and valid are factored out of arb_stall so they fan in once
//     instead of three times.
// ----------------------------------------------------------------
module req_gen_logic (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid,
    input  wire        flush,
    input  wire        LD_OP,
    input  wire        XCL,
    input  wire        dep_stall,
    input  wire        exp_stall,
    input  wire        MIO,

    input  wire [14:0] ld_addr0,
    input  wire [14:0] ld_addr1,
    input  wire [14:0] ld_addrMIO,

    input  wire        req_served_0,
    input  wire        req_served_1,
    input  wire        req_served_mio,

    input  wire        mem_stage_we_valid_unit_o,
    input  wire        mem_stage_next_valid_o,

    output wire        ld_addr_0_V,
    output wire        ld_addr_1_V,
    output wire        ld_addr_mio_V,

    output wire [14:0] ld_addr_mio,
    output wire [14:0] ld_addr_0,
    output wire [14:0] ld_addr_1,
    output wire        arb_stall
);

    // ----------------------------------------------------------------
    // Sequential state: is_served_{0,1,mio}
    // ----------------------------------------------------------------
    wire is_served_0;
    wire is_served_1;
    wire is_served_mio;

    wire forward_valid;
    wire clear;

    `AND_2(u_forward_valid, 1, forward_valid,
           mem_stage_we_valid_unit_o, mem_stage_next_valid_o)
//     `OR_2 (u_clear,         1, clear, forward_valid, flush)
     assign clear = forward_valid;

    wire set_0;
    wire set_1;
    wire set_mio;
    `AND_2(u_set_0,   1, set_0,   req_served_0,   valid)
    `AND_2(u_set_1,   1, set_1,   req_served_1,   valid)
    `AND_2(u_set_mio, 1, set_mio, req_served_mio, valid)

    // Next-state muxes: clear ? 0 : set_X ? 1 : is_served_X
    wire next_is_served_0_inner, next_is_served_0;
    wire next_is_served_1_inner, next_is_served_1;
    wire next_is_served_mio_inner, next_is_served_mio;


     //`MUX_4(u_next_is_served_0, 1, next_is_served_0, is_served_0, 1'b1, 1'b0, 1'b0, {clear, set_0})
    `MUX_2(u_nxt_is_served_0_inner,   1, next_is_served_0_inner,
           is_served_0, 1'b1, set_0)


    `MUX_2(u_nxt_is_served_0,         1, next_is_served_0,
           next_is_served_0_inner, 1'b0, clear)

    `MUX_2(u_nxt_is_served_1_inner,   1, next_is_served_1_inner,
           is_served_1, 1'b1, set_1)
    `MUX_2(u_nxt_is_served_1,         1, next_is_served_1,
           next_is_served_1_inner, 1'b0, clear)

    `MUX_2(u_nxt_is_served_mio_inner, 1, next_is_served_mio_inner,
           is_served_mio, 1'b1, set_mio)
    `MUX_2(u_nxt_is_served_mio,       1, next_is_served_mio,
           next_is_served_mio_inner, 1'b0, clear)

    `REG_RST(u_is_served_0_reg,   1, clk,  (rst | !flush), next_is_served_0,   is_served_0)
    `REG_RST(u_is_served_1_reg,   1, clk,  (rst | !flush), next_is_served_1,   is_served_1)
    `REG_RST(u_is_served_mio_reg, 1, clk,  (rst | !flush), next_is_served_mio, is_served_mio)

       
//       `REG_RST_WE(u_is_served_0_reg, 1, clk, rst, (set_0 || clear) , next_is_served_0, is_served_0) 


    // ----------------------------------------------------------------
    // Local stall (combines exp/dep stalls, used in V signals only)
    // ----------------------------------------------------------------
    wire stall;
    `OR_2(u_stall, 1, stall, exp_stall, dep_stall)

    // ----------------------------------------------------------------
    // arb_stall (CP)
    //   Factored:  arb_stall = LD_OP & valid &
    //                          ( (~rs_mio & ~is_mio) & MIO
    //                          | (~rs_0   & ~is_0)   & ~MIO
    //                          | (~rs_1   & ~is_1)   & ~MIO & XCL )
    // ----------------------------------------------------------------
    wire not_mio;
    `INV_N(u_inv_mio, 1, MIO, not_mio)

    wire nor_rs_is_mio;
    wire nor_rs_is_0;
    wire nor_rs_is_1;
    `NOR_2(u_nor_rs_is_mio, 1, nor_rs_is_mio, req_served_mio, is_served_mio)
    `NOR_2(u_nor_rs_is_0,   1, nor_rs_is_0,   req_served_0,   is_served_0)
    `NOR_2(u_nor_rs_is_1,   1, nor_rs_is_1,   req_served_1,   is_served_1)

    wire mio_term;
    wire ld0_term;
    wire ld1_term;
    `AND_2(u_mio_term, 1, mio_term, nor_rs_is_mio, MIO)
    `AND_2(u_ld0_term, 1, ld0_term, nor_rs_is_0,   not_mio)
    `AND_3(u_ld1_term, 1, ld1_term, nor_rs_is_1,   XCL, not_mio)

    wire or_terms;
    `OR_3 (u_or_terms,  1, or_terms,   mio_term, ld0_term, ld1_term)
    `AND_3(u_arb_stall, 1, arb_stall,  or_terms, LD_OP, valid)

    // ----------------------------------------------------------------
    // Cache-line-align (low 4 bits forced to 0): wire concat, no gates
    // ----------------------------------------------------------------
    assign ld_addr_0   = {ld_addr0[14:4],   4'b0000};
    assign ld_addr_1   = {ld_addr1[14:4],   4'b0000};
    assign ld_addr_mio = {ld_addrMIO[14:4], 4'b0000};

    // ----------------------------------------------------------------
    // Output valids (CP):
    //   ld_addr_0_V   = NOR_4(stall, MIO, is_served_0,   flush) & LD_OP & valid
    //   ld_addr_1_V   = NOR_4(stall, MIO, is_served_1,   flush) & LD_OP & valid & XCL
    //   ld_addr_mio_V = NOR_3(stall,      is_served_mio, flush) & LD_OP & valid & MIO
    // ----------------------------------------------------------------
    wire nor4_0;
    wire nor4_1;
    wire nor3_mio;

    `NOR_4(u_nor4_0,   1, nor4_0,   stall, MIO, is_served_0, flush)
    `NOR_4(u_nor4_1,   1, nor4_1,   stall, MIO, is_served_1, flush)
    `NOR_3(u_nor3_mio, 1, nor3_mio, stall, is_served_mio, flush)

    `AND_3(u_ld_addr_0_V,   1, ld_addr_0_V,   nor4_0,   LD_OP, valid)
    `AND_4(u_ld_addr_1_V,   1, ld_addr_1_V,   nor4_1,   LD_OP, valid, XCL)
    `AND_4(u_ld_addr_mio_V, 1, ld_addr_mio_V, nor3_mio, LD_OP, valid, MIO)

endmodule
