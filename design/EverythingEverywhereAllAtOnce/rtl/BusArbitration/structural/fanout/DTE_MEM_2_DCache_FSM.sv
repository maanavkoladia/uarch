// ======================================================================
// FSM : DTE_MEM_2_DCache_FSM
// Tool: fsm2rtl.py  (auto-generated -- hand-edited copy in fanout/ folder)
// Std : Verilog-2005 (IEEE 1364-2005)
// NOTE: ERROR state was synthesised automatically.
//       Any undefined transition lands here (all outputs = 0).
// ======================================================================
//
// Fanout fixes (vs original gen file):
//  - ff_0/1/2 each split into 3 copies (a/b/c) -- redistributes 11/10/9
//    internal loads on S_0/S_1/S_2 to <=4 per copy, 0 ns added.
//  - mem_valid_o and Drive_Addr_Bus_o re-driven through bufferH16$ at the
//    output port (fanout 8 / 16 external), 0.24 ns added per output.
// ======================================================================

module DTE_MEM_2_DCache_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire bank_hit_i,
    input  wire others_busy_i,
    input  wire mem_ready_i,
    output wire S_0,
    output wire S_1,
    output wire S_2,
    output wire busy_o,
    output wire mem_valid_o,
    output wire ld_req_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_0_o,
    output wire Drv_DB_1_o,
    output wire Drv_DB_2_o,
    output wire Drv_DB_3_o
);

// ----------------------------------------------------------------
// Next-state wires
// ----------------------------------------------------------------
wire NS_0;
wire NS_1;
wire NS_2;

// ----------------------------------------------------------------
// State flip-flops (triplicated to spread internal fanout)
//   *_a : NS-side internal users
//   *_b : output-side gates
//   *_c : drives output port + remaining internal users
// ----------------------------------------------------------------
wire S_0_a, S_0_b, S_0_c;
wire S_1_a, S_1_b, S_1_c;
wire S_2_a, S_2_b, S_2_c;

`REG_RST(ff_0_a, 1, clk, rst, NS_0, S_0_a)
`REG_RST(ff_0_b, 1, clk, rst, NS_0, S_0_b)
`REG_RST(ff_0_c, 1, clk, rst, NS_0, S_0_c)
`REG_RST(ff_1_a, 1, clk, rst, NS_1, S_1_a)
`REG_RST(ff_1_b, 1, clk, rst, NS_1, S_1_b)
`REG_RST(ff_1_c, 1, clk, rst, NS_1, S_1_c)
`REG_RST(ff_2_a, 1, clk, rst, NS_2, S_2_a)
`REG_RST(ff_2_b, 1, clk, rst, NS_2, S_2_b)
`REG_RST(ff_2_c, 1, clk, rst, NS_2, S_2_c)

assign S_0 = S_0_c;
assign S_1 = S_1_c;
assign S_2 = S_2_c;

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire mem_ready_i_inv;
wire others_busy_i_inv;

`INV_N(inv_S_0, 1, S_0_c, S_0_inv)
`INV_N(inv_S_1, 1, S_1_c, S_1_inv)
`INV_N(inv_S_2, 1, S_2_c, S_2_inv)
`INV_N(inv_mem_ready_i, 1, mem_ready_i, mem_ready_i_inv)
`INV_N(inv_others_busy_i, 1, others_busy_i, others_busy_i_inv)

// ----------------------------------------------------------------
// Next-state and output SOP logic
//
// Per-FF load split (each copy <= 4 loads):
//   ff_0_a : NS_0_and0, NS_1_nand1, NS_2_and1, NS_2_and2          (4)
//   ff_0_b : busy_o_nand0, mem_valid_o_nand0,
//            Drive_Addr_Bus_o_nand1, Drv_DB_0_o_and                (4)
//   ff_0_c : Drv_DB_2_o_and, ld_req_o_and, inv_S_0, output port    (3+port)
//
//   ff_1_a : NS_0_and1, NS_1_nand0, NS_2_and0, NS_2_and1           (4)
//   ff_1_b : busy_o_nand2, mem_valid_o_nand1,
//            Drive_Addr_Bus_o_nand2, Drv_DB_1_o_and                 (4)
//   ff_1_c : Drv_DB_2_o_and, inv_S_1, output port                   (2+port)
//
//   ff_2_a : NS_0_and0, NS_2_and0, NS_2_and2                        (3)
//   ff_2_b : busy_o_nand1, mem_valid_o_nand2, ld_req_o_and          (3)
//   ff_2_c : Drive_Addr_Bus_o_nand0, Drv_DB_3_o_and, inv_S_2,
//            output port                                            (3+port)
// ----------------------------------------------------------------

// NS_0 = (S_0 & !S_1 & S_2) | (!S_0 & S_1 & !S_2) | (!S_0 & !S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire NS_0_t0;
`AND_3(NS_0_and0, 1, NS_0_t0, S_0_a, S_1_inv, S_2_a)
wire NS_0_t1;
`AND_3(NS_0_and1, 1, NS_0_t1, S_0_inv, S_1_a, S_2_inv)
wire NS_0_t2;
`AND_5(NS_0_and2, 1, NS_0_t2, S_0_inv, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_3(NS_0_or, 1, NS_0, NS_0_t0, NS_0_t1, NS_0_t2)

// NS_1 = (!S_0 & S_1) | (S_0 & !S_1 & !S_2)
wire NS_1_n0;
`NAND_2(NS_1_nand0, 1, NS_1_n0, S_0_inv, S_1_a)
wire NS_1_n1;
`NAND_3(NS_1_nand1, 1, NS_1_n1, S_0_a, S_1_inv, S_2_inv)

`NAND_2(NS_1_nand, 1, NS_1, NS_1_n0, NS_1_n1)

// NS_2 = (!S_0 & S_1 & S_2) | (S_0 & S_1 & !S_2) | (S_0 & !S_1 & S_2 & !mem_ready_i) | (!S_0 & !S_1 & !S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0_inv, S_1_a, S_2_a)
wire NS_2_t1;
`AND_3(NS_2_and1, 1, NS_2_t1, S_0_a, S_1_a, S_2_inv)
wire NS_2_t2;
`AND_4(NS_2_and2, 1, NS_2_t2, S_0_a, S_1_inv, S_2_a, mem_ready_i_inv)
wire NS_2_t3;
`AND_6(NS_2_and3, 1, NS_2_t3, S_0_inv, S_1_inv, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_4(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1, NS_2_t2, NS_2_t3)

// busy_o = (S_0 & !S_2) | (!S_1 & S_2) | (S_1 & !S_2)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_0_b, S_2_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_1_inv, S_2_b)
wire busy_o_n2;
`NAND_2(busy_o_nand2, 1, busy_o_n2, S_1_b, S_2_inv)

`NAND_3(busy_o_nand, 1, busy_o, busy_o_n0, busy_o_n1, busy_o_n2)

// mem_valid_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2)  -- buffered (fanout 8 external)
wire mem_valid_o_n0;
`NAND_2(mem_valid_o_nand0, 1, mem_valid_o_n0, S_0_b, S_2_inv)
wire mem_valid_o_n1;
`NAND_2(mem_valid_o_nand1, 1, mem_valid_o_n1, S_1_b, S_2_inv)
wire mem_valid_o_n2;
`NAND_3(mem_valid_o_nand2, 1, mem_valid_o_n2, S_0_inv, S_1_inv, S_2_b)

wire mem_valid_o_pre;
`NAND_3(mem_valid_o_nand, 1, mem_valid_o_pre, mem_valid_o_n0, mem_valid_o_n1, mem_valid_o_n2)
bufferH16$ u_mem_valid_o_buf (.out(mem_valid_o), .in(mem_valid_o_pre));

// ld_req_o = (S_0 & !S_1 & S_2)
`AND_3(ld_req_o_and, 1, ld_req_o, S_0_c, S_1_inv, S_2_b)

// Drive_Addr_Bus_o = (!S_1 & S_2) | (S_0 & !S_2) | (S_1 & !S_2) | (!S_2 & req_hit_i & bank_hit_i & !others_busy_i)  -- buffered (fanout 16 external)
wire Drive_Addr_Bus_o_n0;
`NAND_2(Drive_Addr_Bus_o_nand0, 1, Drive_Addr_Bus_o_n0, S_1_inv, S_2_c)
wire Drive_Addr_Bus_o_n1;
`NAND_2(Drive_Addr_Bus_o_nand1, 1, Drive_Addr_Bus_o_n1, S_0_b, S_2_inv)
wire Drive_Addr_Bus_o_n2;
`NAND_2(Drive_Addr_Bus_o_nand2, 1, Drive_Addr_Bus_o_n2, S_1_b, S_2_inv)
wire Drive_Addr_Bus_o_n3;
`NAND_4(Drive_Addr_Bus_o_nand3, 1, Drive_Addr_Bus_o_n3, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

wire Drive_Addr_Bus_o_pre;
`NAND_4(Drive_Addr_Bus_o_nand, 1, Drive_Addr_Bus_o_pre, Drive_Addr_Bus_o_n0, Drive_Addr_Bus_o_n1, Drive_Addr_Bus_o_n2, Drive_Addr_Bus_o_n3)
bufferH16$ u_Drive_Addr_Bus_o_buf (.out(Drive_Addr_Bus_o), .in(Drive_Addr_Bus_o_pre));

// Drv_DB_0_o = (S_0 & !S_1 & !S_2)
`AND_3(Drv_DB_0_o_and, 1, Drv_DB_0_o, S_0_b, S_1_inv, S_2_inv)

// Drv_DB_1_o = (!S_0 & S_1 & !S_2)
`AND_3(Drv_DB_1_o_and, 1, Drv_DB_1_o, S_0_inv, S_1_b, S_2_inv)

// Drv_DB_2_o = (S_0 & S_1 & !S_2)
`AND_3(Drv_DB_2_o_and, 1, Drv_DB_2_o, S_0_c, S_1_c, S_2_inv)

// Drv_DB_3_o = (!S_0 & !S_1 & S_2)
`AND_3(Drv_DB_3_o_and, 1, Drv_DB_3_o, S_0_inv, S_1_inv, S_2_c)

endmodule
