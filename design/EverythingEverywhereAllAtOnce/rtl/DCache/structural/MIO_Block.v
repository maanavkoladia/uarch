// Structural Verilog-2005 port of rtl/DCache/MIO/MIO_Block.sv
//
// Single-entry MIO block. Holds one block_req_mio_t (145 b). Picks ld over
// st when both ready. req_2_sch is a 4-way mux on (we, oe). The
// "WE_ADDR_MASK = 15'h0040" check reduces to a single-bit test of p_addr[6].

`include "STDCell_Macros.vh"
`include "DCache_common_define.vh"

module MIO_Block (
    input  wire                                       clk,
    input  wire                                       rst,                 // active-low
    input  wire                                       reqServed_FromDTE_i,
    input  wire                                       PermissionToDriveAddrBus,
    input  wire                                       permission2DriveDataBus,
    input  wire                                       ld_addr_MIO_V,
    input  wire [`P_ADDR_W                  - 1 : 0]  ld_addr_MIO,
    input  wire [`STQ_W                     - 1 : 0]  stq_info_mio,
    input  wire                                       memStage_CLR_REQ_MIO,
    inout  wire [`ADDRESS_BUS_WIDTH_BITS    - 1 : 0]  address_bus,
    inout  wire [`DATA_BUS_WIDTH_BITS       - 1 : 0]  dataBus,
    output wire [`MIO_OUT_W                 - 1 : 0]  outputs_o
);

    //==================================================================
    // stq_info_mio field views
    //==================================================================
    wire                       stq_empty;
    wire [`P_ADDR_W - 1 : 0]   stq_addr;
    wire [`CL_W     - 1 : 0]   stq_data;
    assign stq_empty = stq_info_mio[`STQ_EMPTY];
    assign stq_addr  = stq_info_mio[`STQ_ADDR_UB:`STQ_ADDR_LB];
    assign stq_data  = stq_info_mio[`STQ_DATA_UB:`STQ_DATA_LB];

    //==================================================================
    // block_req flop (145 b) and field views of current state
    //==================================================================
    wire [`BREQ_MIO_W - 1 : 0]  block_req_q;
    wire [`BREQ_MIO_W - 1 : 0]  next_block_req;

    wire                        breq_oe;
    wire                        breq_we;
    wire [`P_ADDR_W - 1 : 0]    breq_paddr;
    wire [`CL_W     - 1 : 0]    breq_data;
    assign breq_oe    = block_req_q[`BREQ_MIO_OE];
    assign breq_we    = block_req_q[`BREQ_MIO_WE];
    assign breq_paddr = block_req_q[`BREQ_MIO_PADDR_UB:`BREQ_MIO_PADDR_LB];
    assign breq_data  = block_req_q[`BREQ_MIO_DATA_UB:`BREQ_MIO_DATA_LB];

    //==================================================================
    // block_idle, readyForNewReq
    //==================================================================
    wire breq_oe_inv;
    wire breq_we_inv;
    wire block_idle;
    `INV_N(inv_breq_oe_mio, 1, breq_oe, breq_oe_inv)
    `INV_N(inv_breq_we_mio, 1, breq_we, breq_we_inv)
    `AND_2(and_block_idle,  1, block_idle, breq_oe_inv, breq_we_inv)

    wire we_done;
    wire oe_done;
    wire ready_pre;
    wire readyForNewReq;
    `AND_2(and_we_done, 1, we_done,        breq_we, reqServed_FromDTE_i)
    `AND_2(and_oe_done, 1, oe_done,        memStage_CLR_REQ_MIO, breq_oe)
    `OR_2 (or_rdy_pre,  1, ready_pre,      we_done, oe_done)
    `OR_2 (or_rdy_mio,  1, readyForNewReq, ready_pre, block_idle)

    //==================================================================
    // path values
    //   ld_val = {data=0, p_addr=ld_addr_MIO, we=0, oe=1}
    //   st_val = {data=stq_data, p_addr=stq_addr, we=1, oe=0}
    //==================================================================
    wire [`BREQ_MIO_W - 1 : 0] ld_val;
    wire [`BREQ_MIO_W - 1 : 0] st_val;
    wire [`BREQ_MIO_W - 1 : 0] zero_val;
    assign ld_val   = { 128'b0,   ld_addr_MIO, 1'b0, 1'b1 };
    assign st_val   = { stq_data, stq_addr,    1'b1, 1'b0 };
    assign zero_val = {`BREQ_MIO_W{1'b0}};

    //==================================================================
    // priority selection inside the readyForNewReq branch:
    //   if ld_addr_MIO_V        -> ld_val
    //   else if ~stq_empty      -> st_val
    //   else                    -> zero
    //==================================================================
    wire stq_empty_inv;
    `INV_N(inv_stq_empty_mio, 1, stq_empty, stq_empty_inv)

    wire [`BREQ_MIO_W - 1 : 0] inner_st_or_zero;
    wire [`BREQ_MIO_W - 1 : 0] inner_ld_or_st;
    `MUX_2(mux_inner_stz, `BREQ_MIO_W, inner_st_or_zero, zero_val,         st_val, stq_empty_inv)
    `MUX_2(mux_inner_lds, `BREQ_MIO_W, inner_ld_or_st,   inner_st_or_zero, ld_val, ld_addr_MIO_V)

    //   nextReq = readyForNewReq ? inner_ld_or_st : block_req_q
    `MUX_2(mux_nextreq_mio, `BREQ_MIO_W, next_block_req, block_req_q, inner_ld_or_st, readyForNewReq)

    //==================================================================
    // block_req flop
    //==================================================================
    `REG_RST(ff_block_req_mio, `BREQ_MIO_W, clk, rst, next_block_req, block_req_q)

    //==================================================================
    // outputs.writeSuccess  = readyForNewReq & ~ld_addr_MIO_V & ~stq_empty
    // outputs.reqServed     = readyForNewReq & ld_addr_MIO_V
    // outputs.hit_o         = reqServed_FromDTE_i & breq_oe
    //==================================================================
    wire ld_v_inv;
    `INV_N(inv_ldmio_v, 1, ld_addr_MIO_V, ld_v_inv)

    wire ws_pre;
    wire writeSuccess;
    `AND_2(and_ws_pre, 1, ws_pre,       readyForNewReq, ld_v_inv)
    `AND_2(and_ws_mio, 1, writeSuccess, ws_pre,         stq_empty_inv)

    wire reqServed;
    `AND_2(and_rs_mio, 1, reqServed, readyForNewReq, ld_addr_MIO_V)

    wire hit_o;
    `AND_2(and_hit_mio, 1, hit_o, reqServed_FromDTE_i, breq_oe)

    //==================================================================
    // dataLineOut: low 4 bytes from dataBus, top 12 bytes zero
    //==================================================================
    wire [`CL_W - 1 : 0] dataLineOut;
    assign dataLineOut = { 96'b0, dataBus };

    //==================================================================
    // req_2_sch: 4-way on {we, oe}:
    //   2'b00 -> NO_REQ
    //   2'b01 -> DCACHE_MIO_LD_FROM_SIMPLE
    //   2'b10 -> p_addr & 15'h0040 -> WR_SIMPLE else WR_COMPLEX
    //   2'b11 -> NO_REQ (illegal, kept as default)
    //
    // The mask test 15'h0040 isolates bit 6 of p_addr. Verified:
    //   bit pos: 14 ... 7 6 5 4 3 2 1 0
    //   0x0040  =  0  ... 0 1 0 0 0 0 0 0   -> bit 6 set
    //==================================================================
    wire mask_bit;
    assign mask_bit = breq_paddr[6];

    wire [`REQ_2_SCH_W - 1 : 0] wr_branch_val;
    `MUX_2(mux_wr_branch, `REQ_2_SCH_W, wr_branch_val,
           `REQ_DCACHE_MIO_WR_COMPLEX, `REQ_DCACHE_MIO_WR_SIMPLE, mask_bit)

    wire [`REQ_2_SCH_W - 1 : 0] req_2_sch;
    `MUX_4(mux_req_mio, `REQ_2_SCH_W, req_2_sch,
           `REQ_NO_REQ,                       /* 2'b00 */
           `REQ_DCACHE_MIO_LD_FROM_SIMPLE,    /* 2'b01 */
           wr_branch_val,                     /* 2'b10 */
           `REQ_NO_REQ,                       /* 2'b11 */
           {breq_we, breq_oe})

    //==================================================================
    // Address-bus tristate (active-low enable)
    //==================================================================
    wire perm_addr_inv;
    `INV_N(inv_perm_addr_mio, 1, PermissionToDriveAddrBus, perm_addr_inv)

    wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] addr_drv_32;
    assign addr_drv_32 = { {(`ADDRESS_BUS_WIDTH_BITS - `P_ADDR_W){1'b0}}, breq_paddr };

    `BUS_TRISTATE(u_addr_tri_mio, `ADDRESS_BUS_WIDTH_BITS, perm_addr_inv, addr_drv_32, address_bus)

    //==================================================================
    // Data-bus tristate (active-low enable)
    //   dataBus_drv = bytes 3..0 of block_req.st_q_data, packed.
    //==================================================================
    wire perm_data_inv;
    `INV_N(inv_perm_data_mio, 1, permission2DriveDataBus, perm_data_inv)

    wire [`DATA_BUS_WIDTH_BITS - 1 : 0] data_drv;
    assign data_drv = breq_data[`DATA_BUS_WIDTH_BITS - 1 : 0];

    `BUS_TRISTATE(u_data_tri_mio, `DATA_BUS_WIDTH_BITS, perm_data_inv, data_drv, dataBus)

    //==================================================================
    // Output bus assembly
    //==================================================================
    assign outputs_o[`MIO_OUT_WRSUCCESS]                    = writeSuccess;
    assign outputs_o[`MIO_OUT_HIT]                          = hit_o;
    assign outputs_o[`MIO_OUT_LINE_UB:`MIO_OUT_LINE_LB]     = dataLineOut;
    assign outputs_o[`MIO_OUT_REQ_UB:`MIO_OUT_REQ_LB]       = req_2_sch;
    assign outputs_o[`MIO_OUT_REQSERVED]                    = reqServed;

endmodule
