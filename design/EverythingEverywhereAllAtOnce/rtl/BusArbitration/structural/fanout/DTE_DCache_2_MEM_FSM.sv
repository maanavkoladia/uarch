// ======================================================================
// FSM : DTE_DCache_2_MEM_FSM
// Tool: fsm2rtl.py  (auto-generated -- hand-edited copy in fanout/ folder)
// Std : Verilog-2005 (IEEE 1364-2005)
// ======================================================================
// Fanout fixes:
//  - ff_0/1/2 split into 3 copies (a/b/c), 0 ns added on internal paths.
//    Clears 12 violations (3 ff x 4 instances).
// ======================================================================

module DTE_DCache_2_MEM_FSM (
    input  wire clk,
    input  wire rst,
    input  wire req_hit_i,
    input  wire bank_hit_i,
    input  wire others_busy_i,
    output wire S_0,
    output wire S_1,
    output wire S_2,
    output wire busy_o,
    output wire st_req_o,
    output wire eb_clear_o,
    output wire set_eb_commit_o,
    output wire Drive_Addr_Bus_o,
    output wire Drv_DB_0_o,
    output wire Drv_DB_1_o,
    output wire Drv_DB_2_o,
    output wire Drv_DB_3_o
);

wire NS_0;
wire NS_1;
wire NS_2;

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

wire S_0_inv;
wire S_1_inv;
wire S_2_inv;
wire others_busy_i_inv;

`INV_N(inv_S_0, 1, S_0_c, S_0_inv)
`INV_N(inv_S_1, 1, S_1_c, S_1_inv)
`INV_N(inv_S_2, 1, S_2_c, S_2_inv)
`INV_N(inv_others_busy_i, 1, others_busy_i, others_busy_i_inv)

// NS_0 = (!S_1 & S_2) | (!S_0 & S_1 & !S_2)
wire NS_0_n0;
`NAND_2(NS_0_nand0, 1, NS_0_n0, S_1_inv, S_2_a)
wire NS_0_n1;
`NAND_3(NS_0_nand1, 1, NS_0_n1, S_0_inv, S_1_a, S_2_inv)

`NAND_2(NS_0_nand, 1, NS_0, NS_0_n0, NS_0_n1)

// NS_1 = (!S_0 & S_1 & !S_2) | (S_0 & !S_1 & !S_2)
wire NS_1_n0;
`NAND_3(NS_1_nand0, 1, NS_1_n0, S_0_inv, S_1_a, S_2_inv)
wire NS_1_n1;
`NAND_3(NS_1_nand1, 1, NS_1_n1, S_0_a, S_1_inv, S_2_inv)

`NAND_2(NS_1_nand, 1, NS_1, NS_1_n0, NS_1_n1)

// NS_2 = (S_0 & !S_1 & S_2) | (!S_0 & !S_1 & !S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire NS_2_t0;
`AND_3(NS_2_and0, 1, NS_2_t0, S_0_a, S_1_inv, S_2_a)
wire NS_2_t1;
`AND_6(NS_2_and1, 1, NS_2_t1, S_0_inv, S_1_inv, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`OR_2(NS_2_or, 1, NS_2, NS_2_t0, NS_2_t1)

// busy_o = (S_1 & !S_2) | (S_0 & !S_2) | (!S_0 & !S_1 & S_2)
wire busy_o_n0;
`NAND_2(busy_o_nand0, 1, busy_o_n0, S_1_a, S_2_inv)
wire busy_o_n1;
`NAND_2(busy_o_nand1, 1, busy_o_n1, S_0_a, S_2_inv)
wire busy_o_n2;
`NAND_3(busy_o_nand2, 1, busy_o_n2, S_0_inv, S_1_inv, S_2_a)

`NAND_3(busy_o_nand, 1, busy_o, busy_o_n0, busy_o_n1, busy_o_n2)

// st_req_o = (!S_0 & !S_1 & S_2)
`AND_3(st_req_o_and, 1, st_req_o, S_0_inv, S_1_inv, S_2_b)

// eb_clear_o = (S_0 & S_1 & !S_2)
`AND_3(eb_clear_o_and, 1, eb_clear_o, S_0_b, S_1_b, S_2_inv)

// set_eb_commit_o = (!S_0 & !S_1 & S_2)
`AND_3(set_eb_commit_o_and, 1, set_eb_commit_o, S_0_inv, S_1_inv, S_2_b)

// Drive_Addr_Bus_o = (S_0 & !S_2) | (S_1 & !S_2) | (!S_0 & !S_1 & S_2) | (!S_2 & req_hit_i & bank_hit_i & !others_busy_i)
wire Drive_Addr_Bus_o_n0;
`NAND_2(Drive_Addr_Bus_o_nand0, 1, Drive_Addr_Bus_o_n0, S_0_b, S_2_inv)
wire Drive_Addr_Bus_o_n1;
`NAND_2(Drive_Addr_Bus_o_nand1, 1, Drive_Addr_Bus_o_n1, S_1_b, S_2_inv)
wire Drive_Addr_Bus_o_n2;
`NAND_3(Drive_Addr_Bus_o_nand2, 1, Drive_Addr_Bus_o_n2, S_0_inv, S_1_inv, S_2_b)
wire Drive_Addr_Bus_o_n3;
`NAND_4(Drive_Addr_Bus_o_nand3, 1, Drive_Addr_Bus_o_n3, S_2_inv, req_hit_i, bank_hit_i, others_busy_i_inv)

`NAND_4(Drive_Addr_Bus_o_nand, 1, Drive_Addr_Bus_o, Drive_Addr_Bus_o_n0, Drive_Addr_Bus_o_n1, Drive_Addr_Bus_o_n2, Drive_Addr_Bus_o_n3)

// Drv_DB_0_o = (!S_0 & !S_1 & S_2)
`AND_3(Drv_DB_0_o_and, 1, Drv_DB_0_o, S_0_inv, S_1_inv, S_2_c)

// Drv_DB_1_o = (S_0 & !S_1 & !S_2)
`AND_3(Drv_DB_1_o_and, 1, Drv_DB_1_o, S_0_b, S_1_inv, S_2_inv)

// Drv_DB_2_o = (!S_0 & S_1 & !S_2)
`AND_3(Drv_DB_2_o_and, 1, Drv_DB_2_o, S_0_inv, S_1_b, S_2_inv)

// Drv_DB_3_o = (S_0 & S_1 & !S_2)
`AND_3(Drv_DB_3_o_and, 1, Drv_DB_3_o, S_0_c, S_1_c, S_2_inv)

endmodule
