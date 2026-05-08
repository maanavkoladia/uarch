// =============================================================================
// mem_miss_stall_logic  (structural Verilog-2005 port of mem_miss_stall_logic.sv)
//
//   Pure gate-level. No always blocks, no operators, no ternaries.
//   Built only from the macros in lib/STDCells/STDCell_Macros.vh.
//
//   Struct fields from the original SystemVerilog interface are unrolled into
//   individual flat ports.
// =============================================================================

module mem_miss_stall_logic (
    input  wire        valid,
    input  wire        LD_XCL,
    input  wire        LD_OP,
    input  wire        MIO,

    input  wire        hit_0,
    input  wire        hit_1,
    input  wire        hit_2,
    input  wire        hit_3,
    input  wire        hit_MIO,

    input  wire        hit_buf_v_0,
    input  wire        hit_buf_v_1,
    input  wire        hit_buf_v_2,
    input  wire        hit_buf_v_3,
    input  wire        hit_buf_mio_v,

    input  wire [1:0]  bank_num_0,
    input  wire [1:0]  bank_num_1,

    output wire        miss_stall
);

    // -------------------------------------------------------------------------
    // Inverters for negated literals
    // -------------------------------------------------------------------------
    wire MIO_n;
    wire LD_OP_n;       // unused as a literal but generated for clarity
    wire hit_0_n;
    wire hit_1_n;
    wire hit_2_n;
    wire hit_3_n;
    wire hit_MIO_n;
    wire hit_buf_v_0_n;
    wire hit_buf_v_1_n;
    wire hit_buf_v_2_n;
    wire hit_buf_v_3_n;
    wire hit_buf_mio_v_n;

    `INV_N(inv_MIO,            1, MIO,            MIO_n)
    `INV_N(inv_LD_OP,          1, LD_OP,          LD_OP_n)
    `INV_N(inv_hit_0,          1, hit_0,          hit_0_n)
    `INV_N(inv_hit_1,          1, hit_1,          hit_1_n)
    `INV_N(inv_hit_2,          1, hit_2,          hit_2_n)
    `INV_N(inv_hit_3,          1, hit_3,          hit_3_n)
    `INV_N(inv_hit_MIO,        1, hit_MIO,        hit_MIO_n)
    `INV_N(inv_hit_buf_v_0,    1, hit_buf_v_0,    hit_buf_v_0_n)
    `INV_N(inv_hit_buf_v_1,    1, hit_buf_v_1,    hit_buf_v_1_n)
    `INV_N(inv_hit_buf_v_2,    1, hit_buf_v_2,    hit_buf_v_2_n)
    `INV_N(inv_hit_buf_v_3,    1, hit_buf_v_3,    hit_buf_v_3_n)
    `INV_N(inv_hit_buf_mio_v,  1, hit_buf_mio_v,  hit_buf_mio_v_n)

    // -------------------------------------------------------------------------
    // bank_num decode -> per-port one-hot (against literal 2'd0..2'd3)
    // -------------------------------------------------------------------------
    wire bnk0_eq_0;
    wire bnk0_eq_1;
    wire bnk0_eq_2;
    wire bnk0_eq_3;
    wire bnk1_eq_0;
    wire bnk1_eq_1;
    wire bnk1_eq_2;
    wire bnk1_eq_3;

    `CMP_N(cmp_bnk0_0, 2, bnk0_eq_0, bank_num_0, 2'd0)
    `CMP_N(cmp_bnk0_1, 2, bnk0_eq_1, bank_num_0, 2'd1)
    `CMP_N(cmp_bnk0_2, 2, bnk0_eq_2, bank_num_0, 2'd2)
    `CMP_N(cmp_bnk0_3, 2, bnk0_eq_3, bank_num_0, 2'd3)

    `CMP_N(cmp_bnk1_0, 2, bnk1_eq_0, bank_num_1, 2'd0)
    `CMP_N(cmp_bnk1_1, 2, bnk1_eq_1, bank_num_1, 2'd1)
    `CMP_N(cmp_bnk1_2, 2, bnk1_eq_2, bank_num_1, 2'd2)
    `CMP_N(cmp_bnk1_3, 2, bnk1_eq_3, bank_num_1, 2'd3)

    // -------------------------------------------------------------------------
    // ld_miss : (bank_num_0 == i) & ~hits[i] & ~hit_buf_v[i] & LD_OP & ~MIO
    //   Per-port AND_5, then OR_4 across the 4 ports.
    // -------------------------------------------------------------------------
    wire ld_miss_0;
    wire ld_miss_1;
    wire ld_miss_2;
    wire ld_miss_3;
    wire ld_miss;

    `AND_5(and_ld_miss_0, 1, ld_miss_0, bnk0_eq_0, hit_0_n, hit_buf_v_0_n, LD_OP, MIO_n)
    `AND_5(and_ld_miss_1, 1, ld_miss_1, bnk0_eq_1, hit_1_n, hit_buf_v_1_n, LD_OP, MIO_n)
    `AND_5(and_ld_miss_2, 1, ld_miss_2, bnk0_eq_2, hit_2_n, hit_buf_v_2_n, LD_OP, MIO_n)
    `AND_5(and_ld_miss_3, 1, ld_miss_3, bnk0_eq_3, hit_3_n, hit_buf_v_3_n, LD_OP, MIO_n)

    `OR_4(or_ld_miss, 1, ld_miss, ld_miss_0, ld_miss_1, ld_miss_2, ld_miss_3)

    // -------------------------------------------------------------------------
    // xcl_miss : (bank_num_1 == i) & ~hits[i] & ~hit_buf_v[i] & LD_OP & LD_XCL & ~MIO
    //   Per-port AND_6, then OR_4 across the 4 ports.
    // -------------------------------------------------------------------------
    wire xcl_miss_0;
    wire xcl_miss_1;
    wire xcl_miss_2;
    wire xcl_miss_3;
    wire xcl_miss;

    `AND_6(and_xcl_miss_0, 1, xcl_miss_0, bnk1_eq_0, hit_0_n, hit_buf_v_0_n, LD_OP, LD_XCL, MIO_n)
    `AND_6(and_xcl_miss_1, 1, xcl_miss_1, bnk1_eq_1, hit_1_n, hit_buf_v_1_n, LD_OP, LD_XCL, MIO_n)
    `AND_6(and_xcl_miss_2, 1, xcl_miss_2, bnk1_eq_2, hit_2_n, hit_buf_v_2_n, LD_OP, LD_XCL, MIO_n)
    `AND_6(and_xcl_miss_3, 1, xcl_miss_3, bnk1_eq_3, hit_3_n, hit_buf_v_3_n, LD_OP, LD_XCL, MIO_n)

    `OR_4(or_xcl_miss, 1, xcl_miss, xcl_miss_0, xcl_miss_1, xcl_miss_2, xcl_miss_3)

    // -------------------------------------------------------------------------
    // mio_miss : MIO & ~hit_MIO & ~hit_buf_mio_v & LD_OP
    // -------------------------------------------------------------------------
    wire mio_miss;

    `AND_4(and_mio_miss, 1, mio_miss, MIO, hit_MIO_n, hit_buf_mio_v_n, LD_OP)

    // -------------------------------------------------------------------------
    // miss_stall = (mio_miss | ld_miss | xcl_miss) & valid
    // -------------------------------------------------------------------------
    wire any_miss;

    `OR_3(or_any_miss,    1, any_miss,   mio_miss, ld_miss, xcl_miss)
    // fanout: redirect and_miss_stall AND_2 output to staging wire, attach bufferH16$
    wire miss_stall_pre_buf;
    `AND_2(and_miss_stall, 1, miss_stall_pre_buf, any_miss, valid)
    bufferH16$ u_attach_miss_stall (.out(miss_stall), .in(miss_stall_pre_buf));

endmodule
