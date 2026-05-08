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

    // fanout: attach bufferH16$ per bit of upper16 (each bit fanout=13)
    wire [15:0] upper16_pre_buf;
    `ADD_N(u_upper16, 16, upper16_pre_buf, cout, segValue[15:0], l_addr_i[31:16], 1'b0);
    bufferH16$ u_attach_sum_0  (.out(upper16[0]),  .in(upper16_pre_buf[0]));
    bufferH16$ u_attach_sum_1  (.out(upper16[1]),  .in(upper16_pre_buf[1]));
    bufferH16$ u_attach_sum_2  (.out(upper16[2]),  .in(upper16_pre_buf[2]));
    bufferH16$ u_attach_sum_3  (.out(upper16[3]),  .in(upper16_pre_buf[3]));
    bufferH16$ u_attach_sum_4  (.out(upper16[4]),  .in(upper16_pre_buf[4]));
    bufferH16$ u_attach_sum_5  (.out(upper16[5]),  .in(upper16_pre_buf[5]));
    bufferH16$ u_attach_sum_6  (.out(upper16[6]),  .in(upper16_pre_buf[6]));
    bufferH16$ u_attach_sum_7  (.out(upper16[7]),  .in(upper16_pre_buf[7]));
    bufferH16$ u_attach_sum_8  (.out(upper16[8]),  .in(upper16_pre_buf[8]));
    bufferH16$ u_attach_sum_9  (.out(upper16[9]),  .in(upper16_pre_buf[9]));
    bufferH16$ u_attach_sum_10 (.out(upper16[10]), .in(upper16_pre_buf[10]));
    bufferH16$ u_attach_sum_11 (.out(upper16[11]), .in(upper16_pre_buf[11]));
    bufferH16$ u_attach_sum_12 (.out(upper16[12]), .in(upper16_pre_buf[12]));
    bufferH16$ u_attach_sum_13 (.out(upper16[13]), .in(upper16_pre_buf[13]));
    bufferH16$ u_attach_sum_14 (.out(upper16[14]), .in(upper16_pre_buf[14]));
    bufferH16$ u_attach_sum_15 (.out(upper16[15]), .in(upper16_pre_buf[15]));

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

