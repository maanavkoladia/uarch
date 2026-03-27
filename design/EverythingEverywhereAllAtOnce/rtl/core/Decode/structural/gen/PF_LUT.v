// ======================================================================
// Combinational block : pf_gen
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
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

module pf_gen (
    output wire num_pfs_1_o,
    output wire num_pfs_0_o,
    input  wire pf_2_i,
    input  wire pf_1_i,
    input  wire pf_0_i
);

// Inverter wires
wire pf_1_i_inv;

inv1$ inv_pf_1_i (pf_1_i_inv, pf_1_i);

// SOP logic (Quine-McCluskey minimised)

// num_pfs_1_o = (pf_1_i & pf_0_i)
and2$ num_pfs_1_o_and (num_pfs_1_o, pf_1_i, pf_0_i);

// num_pfs_0_o = (pf_2_i & pf_0_i) | (!pf_1_i & pf_0_i)
wire num_pfs_0_o_t0;
wire num_pfs_0_o_t1;

and2$ num_pfs_0_o_and0 (num_pfs_0_o_t0, pf_2_i, pf_0_i);
and2$ num_pfs_0_o_and1 (num_pfs_0_o_t1, pf_1_i_inv, pf_0_i);
or2$  num_pfs_0_o_or  (num_pfs_0_o, num_pfs_0_o_t0, num_pfs_0_o_t1);

endmodule
