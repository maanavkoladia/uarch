module SegmentTranslation (
    input wire [31:0] l_addr_i,
    input wire [31:0] segValue,
    input wire [31:0] segLimit,

    output wire [31:0] v_addr_o,
    output wire gp_fault_o
);

    wire [15:0] upper16;
    wire cout;

    assign v_addr_o = {upper16, l_addr_i[15:0]};

    //not used in fetch so this is useless
    // gp_fault_o = (l_addr_i > segLimit)
    //   l_addr_i > segLimit  iff  NOT(segLimit >= l_addr_i)
    //   segLimit >= l_addr_i : cout of (segLimit + ~l_addr_i + 1)
    wire [31:0] l_addr_inv;
    wire [31:0] sub_seg_l_sum;
    wire        ge_seg_ge_l;
    `INV_N(u_inv_laddr, 32, l_addr_i,    l_addr_inv);
    `ADD_N(u_sub_seg_l, 32, sub_seg_l_sum, ge_seg_ge_l, segLimit, l_addr_inv, 1'b1);
    `INV_N(u_inv_ge,     1, ge_seg_ge_l, gp_fault_o);

    `ADD_N(u_upper16, 16, upper16, cout, segValue[15:0], l_addr_i[31:16], 1'b0);

endmodule

// import common_pkg::l_address_t;
// import common_pkg::v_address_t;
// import common_pkg::bool;
// import reg_ids_pkg::reg_ids_e;
// import SegmentTranslation_pkg::*;

// module SegmentTranslation (
//     input l_address_t l_addr_i,
//     input uint32_t segValue,
//     input uint32_t segLimit,

//     output v_address_t v_addr_o,
//     output bool gp_fault_o
// );
//     assign v_addr_o = (segValue << 16) + l_addr_i;
//     assign gp_fault_o = v_addr_o > segLimit;

// endmodule

