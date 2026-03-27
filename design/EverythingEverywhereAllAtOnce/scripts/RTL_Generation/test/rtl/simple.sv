// ======================================================================
// Combinational block : simple
// Tool: csv2rtl.py  (auto-generated -- do not hand-edit)
// ======================================================================

// Truth table (expanded, from CSV)
// ------------------------------------------------
//           a_i           b_i  |           y_o
// ------------------------------------------------
//             0             0  |             0
//             0             1  |             0
//             1             0  |             0
//             1             1  |             1
// ------------------------------------------------

module simple (
    output wire  y_o,
    input  wire a_i,
    input  wire  b_i
);

// SOP logic (Quine-McCluskey minimised)

//  y_o = (a_i &  b_i)
and2$  y_o_and ( y_o, a_i,  b_i);

endmodule
