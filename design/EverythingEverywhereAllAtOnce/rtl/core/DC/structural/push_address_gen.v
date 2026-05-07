// ----------------------------------------------------------------
// push_address_gen -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/push_address_gen.sv
//
//   end_address   = ST_PADDR_0 - 1
//   num_bytes     = (FAR_CALL || EXP_CALL) ? 8
//                 : data_size[1]           ? 4 : 2
//   start_address = ST_PADDR_0 - num_bytes
//
//   is_push_like  = (PUSH || FAR_CALL || CALL || EXP_CALL)
//
//   ST_PADDR_0_o  = is_push_like ? start_address              : ST_PADDR_0
//   ST_PADDR_1_o  = is_push_like ? (end_address & 15'h7FF0)   : ST_PADDR_1
//   ST_XCL_o      = is_push_like ? (start_address[4]^end_address[4]) : ST_XCL
//
// Widths:
//   p_address_t           = 15 bits (PHY_MEM_SIZE = 1<<15)
//   exe_cs_operation_type_e enum has no explicit type → default int (32b)
//
// Off-critical-path; straight AND/OR/MUX with shared inverters.
// ----------------------------------------------------------------
module push_address_gen (
    input  wire [14:0] ST_PADDR_0,
    input  wire [14:0] ST_PADDR_1,
    input  wire        ST_XCL,
    input  wire [1:0]  data_size,
    input  wire [31:0] OP_TYPE,

    output wire [14:0] ST_PADDR_0_o,
    output wire [14:0] ST_PADDR_1_o,
    output wire        ST_XCL_o
);

    // ----------------------------------------------------------------
    // OP_TYPE compares -- shared between is_8byte_op and is_push_like.
    //   PUSH=24, FAR_CALL=19, CALL=18, EXP_CALL=38
    // ----------------------------------------------------------------
    wire cmp_push;
    wire cmp_far_call;
    wire cmp_call;
    wire cmp_exp_call;

    `CMP_N(u_cmp_push,     32, cmp_push,     OP_TYPE, 32'd24)
    `CMP_N(u_cmp_far_call, 32, cmp_far_call, OP_TYPE, 32'd19)
    `CMP_N(u_cmp_call,     32, cmp_call,     OP_TYPE, 32'd18)
    `CMP_N(u_cmp_exp_call, 32, cmp_exp_call, OP_TYPE, 32'd38)

    // ----------------------------------------------------------------
    // is_8byte_op = (FAR_CALL || EXP_CALL)
    // ----------------------------------------------------------------
    wire is_8byte_op;
    `OR_2(u_is_8byte_op, 1, is_8byte_op, cmp_far_call, cmp_exp_call)

    // ----------------------------------------------------------------
    // num_bytes (4 bits)
    //   default = data_size[1] ? 4 : 2
    //   then    = is_8byte_op  ? 8 : default
    // ----------------------------------------------------------------
    wire [3:0] bytes_default;
    wire [3:0] num_bytes;

    `MUX_2(u_bytes_default, 4, bytes_default, 4'd2, 4'd4, data_size[1])
    `MUX_2(u_num_bytes,     4, num_bytes,     bytes_default, 4'd8, is_8byte_op)

    // ----------------------------------------------------------------
    // end_address = ST_PADDR_0 - 1
    //   In 15-bit two's complement: -1 = 15'h7FFF, so we just add 15'h7FFF
    //   with cin=0 (wraps to ST_PADDR_0 - 1 mod 2^15).
    // ----------------------------------------------------------------
    wire [14:0] end_address;
    wire        end_addr_cout;        // unused
    `ADD_N(u_end_address, 15, end_address, end_addr_cout,
           ST_PADDR_0, 15'h7FFF, 1'b0)

    // ----------------------------------------------------------------
    // start_address = ST_PADDR_0 - num_bytes
    //   = ST_PADDR_0 + ~num_bytes_ext + 1   (two's complement subtract)
    // ----------------------------------------------------------------
    wire [14:0] num_bytes_ext;
    wire [14:0] num_bytes_inv;
    wire [14:0] start_address;
    wire        start_addr_cout;      // unused

    assign num_bytes_ext = {11'b0, num_bytes};
    `INV_N(u_inv_num_bytes,  15, num_bytes_ext, num_bytes_inv)
    `ADD_N(u_start_address,  15, start_address, start_addr_cout,
           ST_PADDR_0, num_bytes_inv, 1'b1)

    // ----------------------------------------------------------------
    // is_push_like = PUSH | FAR_CALL | CALL | EXP_CALL
    //
    // Drives 15 + 15 + 1 = 31 mux selects. push_address_gen sits OFF the
    // DC critical path (its outputs feed mem_latches_next_ST_PADDR_*,
    // clocked into MEM, not the dep-check/TLB/req_gen path), so a 2-stage
    // bufferH16$ tree is the right call -- adds ~0.48 ns but irrelevant.
    //
    //   stage 1: is_push_like (raw OR_4 out, fanout 1 to s1 buffer)
    //   stage 2: is_push_like_s1 (drives 2 stage-2 buffers, fanout 2)
    //   leaves: is_push_like_a drives the 15-bit ST_PADDR_0_o MUX +
    //           the 1-bit ST_XCL_o MUX (16 loads, at bufferH16$ rated);
    //           is_push_like_b drives the 15-bit ST_PADDR_1_o MUX (15).
    // ----------------------------------------------------------------
    wire is_push_like;
    `OR_4(u_is_push_like, 1, is_push_like,
          cmp_push, cmp_far_call, cmp_call, cmp_exp_call)

    wire is_push_like_s1;
    bufferH16$ u_buf_is_push_like_s1 (.out(is_push_like_s1), .in(is_push_like));

    wire is_push_like_a;
    wire is_push_like_b;
    bufferH16$ u_buf_is_push_like_a (.out(is_push_like_a), .in(is_push_like_s1));
    bufferH16$ u_buf_is_push_like_b (.out(is_push_like_b), .in(is_push_like_s1));

    // ----------------------------------------------------------------
    // ST_PADDR_0_o = is_push_like ? start_address : ST_PADDR_0
    // ----------------------------------------------------------------
    `MUX_2(u_st_paddr_0_o, 15, ST_PADDR_0_o,
           ST_PADDR_0, start_address, is_push_like_a)

    // ----------------------------------------------------------------
    // ST_PADDR_1_o = is_push_like ? (end_address & 15'h7FF0) : ST_PADDR_1
    //   end_address & 15'h7FF0 == { end_address[14:4], 4'b0000 } -- wire concat
    // ----------------------------------------------------------------
    wire [14:0] end_address_aligned;
    assign end_address_aligned = {end_address[14:4], 4'b0000};

    `MUX_2(u_st_paddr_1_o, 15, ST_PADDR_1_o,
           ST_PADDR_1, end_address_aligned, is_push_like_b)

    // ----------------------------------------------------------------
    // ST_XCL_o = is_push_like ? (start_address[4] ^ end_address[4]) : ST_XCL
    // ----------------------------------------------------------------
    wire xcl_push_like;
    `XOR_2(u_xcl_push_like, 1, xcl_push_like,
           start_address[4], end_address[4])

    `MUX_2(u_st_xcl_o, 1, ST_XCL_o,
           ST_XCL, xcl_push_like, is_push_like_a)

endmodule
