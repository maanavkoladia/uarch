// ======================================================================
// Combinational block : pf_gen
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// Std : Verilog-2005 (IEEE 1364-2005)
// Lib : std_cell_macros.vh
// ======================================================================

// Truth table (expanded, from CSV)
// ----------------------------------------------------------------------------
//        pf_2_i        pf_1_i        pf_0_i  |   num_pfs_1_o   num_pfs_0_o
// ----------------------------------------------------------------------------
//             0             0             0  |             0             0
//             0             0             1  |             0             1
//             0             1             0  |             0             0
//             0             1             1  |             1             0
//             1             0             0  |             0             0
//             1             0             1  |             0             1
//             1             1             0  |             0             0
//             1             1             1  |             1             1
// ----------------------------------------------------------------------------

`include "std_cell_macros.vh"

module pf_gen (
    output wire num_pfs_1_o,
    output wire num_pfs_0_o,
    input  wire pf_2_i,
    input  wire pf_1_i,
    input  wire pf_0_i
);

// ----------------------------------------------------------------
// Inverters for negated literals
// ----------------------------------------------------------------
wire pf_1_i_inv;

`INV_N(inv_pf_1_i, 1, pf_1_i, pf_1_i_inv)

// ----------------------------------------------------------------
// SOP logic (Quine-McCluskey minimised)
// ----------------------------------------------------------------

// num_pfs_1_o = (pf_1_i & pf_0_i)
`AND_2(num_pfs_1_o_and, 1, num_pfs_1_o, pf_1_i, pf_0_i)

// num_pfs_0_o = (pf_2_i & pf_0_i) | (!pf_1_i & pf_0_i)
wire num_pfs_0_o_t0;
`AND_2(num_pfs_0_o_and0, 1, num_pfs_0_o_t0, pf_2_i, pf_0_i)
wire num_pfs_0_o_t1;
`AND_2(num_pfs_0_o_and1, 1, num_pfs_0_o_t1, pf_1_i_inv, pf_0_i)

`OR_2(num_pfs_0_o_or, 1, num_pfs_0_o, num_pfs_0_o_t0, num_pfs_0_o_t1)

endmodule
