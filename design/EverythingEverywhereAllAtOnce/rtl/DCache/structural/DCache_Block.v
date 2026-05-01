// Structural Verilog-2005 port of rtl/DCache/DCache_Block/DCache_Block.sv


module DCache_Block (
    input  wire                                       clk_i,
    input  wire                                       rst_i,
    input  wire [`BREQ_W                    - 1 : 0]  block_req_i,
    input  wire                                       mem_Valid_FromDte_i,
    input  wire                                       evictionBuf_clr_FromDTE_i,
    input  wire                                       evictionBuf_setCommiting_FromDTE_i,
    input  wire [3:0]                                 permissionToDriveDataBus_evictionBuf,
    input  wire                                       permissionToDriveAddrBus_Ld,
    input  wire                                       permissionToDriveAddrBus_eb,
    input  wire                                       st_override_for_sch_req,
    inout  wire [`DATA_BUS_WIDTH_BITS       - 1 : 0]  dataBus,
    inout  wire [`ADDRESS_BUS_WIDTH_BITS    - 1 : 0]  address_bus,
    output wire [`DCBLK_OUT_W               - 1 : 0]  outputs_o
);

    //==================================================================
    // Submodule output buses
    //==================================================================
    wire [`DCB_OUT_W - 1 : 0]  dcache_bank_outputs;
    wire [`VC_OUT_W  - 1 : 0]  vcache_outputs;
    wire [`EB_OUT_W  - 1 : 0]  eb_outputs;

    // Field views
    wire        dc_hit;
    wire [`CL_W    - 1 : 0]    dc_line;
    wire        dc_busy;
    wire        dc_makereq;
    wire        dc_eb_stalling;
    assign dc_hit         = dcache_bank_outputs[`DCB_OUT_HIT];
    assign dc_line        = dcache_bank_outputs[`DCB_OUT_LINE_UB:`DCB_OUT_LINE_LB];
    assign dc_busy        = dcache_bank_outputs[`DCB_OUT_BUSY];
    assign dc_makereq     = dcache_bank_outputs[`DCB_OUT_MAKEREQ];
    assign dc_eb_stalling = dcache_bank_outputs[`DCB_OUT_EBSTALL];

    wire        vc_hit;
    wire        vc_busy;
    wire        vc_blocked;
    wire [`CL_W - 1 : 0] vc_line;
    assign vc_hit     = vcache_outputs[`VC_OUT_HIT];
    assign vc_busy    = vcache_outputs[`VC_OUT_BUSY];
    assign vc_blocked = vcache_outputs[`VC_OUT_BEINGBLOCKED];
    assign vc_line    = vcache_outputs[`VC_OUT_LINE_UB:`VC_OUT_LINE_LB];

    wire        eb_v;
    wire        eb_commiting;
    wire [`P_ADDR_W - 1 : 0]  eb_addr;
    wire [`CL_W     - 1 : 0]  eb_line;
    assign eb_v         = eb_outputs[`EB_OUT_VALID];
    assign eb_commiting = eb_outputs[`EB_OUT_COMMITING];
    assign eb_addr      = eb_outputs[`EB_OUT_ADDR_UB:`EB_OUT_ADDR_LB];
    assign eb_line      = eb_outputs[`EB_OUT_LINE_UB:`EB_OUT_LINE_LB];

    //   block-req fields
    wire        breq_oe;
    wire        breq_we;
    wire [`P_ADDR_W - 1 : 0] breq_paddr;
    assign breq_oe    = block_req_i[`BREQ_OE];
    assign breq_we    = block_req_i[`BREQ_WE];
    assign breq_paddr = block_req_i[`BREQ_PADDR_UB:`BREQ_PADDR_LB];

    //==================================================================
    // block_busy = dc.busy | vc.busy
    //==================================================================
    wire block_busy;
    `OR_2(or_block_busy, 1, block_busy, dc_busy, vc_busy)

    //==================================================================
    // Submodule instances
    //==================================================================
    DCache_Bank dcache_bank_unit (
        .clk(clk_i),
        .rst(rst_i),
        .V_Cache_i(vcache_outputs),
        .eb_i(eb_outputs),
        .mem_Valid_FromDte_i(mem_Valid_FromDte_i),
        .blockReq_i(block_req_i),
        .block_busy_i(block_busy),
        .dataBus(dataBus),
        .outputs_o(dcache_bank_outputs)
    );

    VCache vcache_unit (
        .clk(clk_i),
        .rst(rst_i),
        .blockReq_i(block_req_i),
        .block_busy_i(block_busy),
        .eb_outs_i(eb_outputs),
        .dcache_outs_i(dcache_bank_outputs),
        .outputs_o(vcache_outputs)
    );

    EvictionBuf evictionBuf_unit (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .eb_clr_i(evictionBuf_clr_FromDTE_i),
        .set_commiting(evictionBuf_setCommiting_FromDTE_i),
        .vcache_outputs_i(vcache_outputs),
        .blockReq_i(block_req_i),
        .outputs_o(eb_outputs)
    );

    //==================================================================
    // dataLineOut = vc.hit ? vc.line : dc.line
    //==================================================================
    wire [`CL_W - 1 : 0] dataLineOut;
    `MUX_2(mux_data_line, `CL_W, dataLineOut, dc_line, vc_line, vc_hit)

    //==================================================================
    // hit_o = dc.hit | vc.hit
    //==================================================================
    wire hit_o;
    `OR_2(or_hit_o, 1, hit_o, dc_hit, vc_hit)

    //==================================================================
    // req_2_sch priority encoder
    //   p0 = dc.eb_stalling & ~eb.commiting
    //   p1 = ~p0 & vc.beingBlocked & ~eb.commiting
    //   p2 = ~p0 & ~vc.beingBlocked-or-already-handled & dc.MakeReq
    //   p3 = ~p0 & ~p1 & ~p2 & eb.valid & ~eb.commiting
    //==================================================================
    wire commiting_inv;
    `INV_N(inv_commiting, 1, eb_commiting, commiting_inv)

    wire p0;
    wire p1_pre;        // = vc.blocked & ~commiting
    wire p2_pre;        // = dc.MakeReq
    wire p3_pre;        // = eb.valid & ~commiting

    `AND_2(and_p0,     1, p0,     dc_eb_stalling, commiting_inv)
    `AND_2(and_p1_pre, 1, p1_pre, vc_blocked,     commiting_inv)
    assign p2_pre = dc_makereq;
    `AND_2(and_p3_pre, 1, p3_pre, eb_v,           commiting_inv)

    //   Inner priority muxes for p1 and p2 sub-values
    //   inner_pN = st_override ? VAL_SO : (oe ? VAL_OE : (we ? VAL_WE : NO_REQ))
    wire [`REQ_2_SCH_W - 1 : 0] inner_p1_x0;
    wire [`REQ_2_SCH_W - 1 : 0] inner_p1_x1;
    wire [`REQ_2_SCH_W - 1 : 0] inner_p1;

    `MUX_2(mux_p1_x0, `REQ_2_SCH_W, inner_p1_x0, `REQ_NO_REQ,  `REQ_DCACHE_EB_BLOCK_ST,        breq_we)
    `MUX_2(mux_p1_x1, `REQ_2_SCH_W, inner_p1_x1, inner_p1_x0,  `REQ_DCACHE_EB_BLOCKING_LD,     breq_oe)
    `MUX_2(mux_p1,    `REQ_2_SCH_W, inner_p1,    inner_p1_x1,  `REQ_DCACHE_EB_BLOCKING_ST_OVERRIDE, st_override_for_sch_req)

    wire [`REQ_2_SCH_W - 1 : 0] inner_p2_x0;
    wire [`REQ_2_SCH_W - 1 : 0] inner_p2_x1;
    wire [`REQ_2_SCH_W - 1 : 0] inner_p2;

    `MUX_2(mux_p2_x0, `REQ_2_SCH_W, inner_p2_x0, `REQ_NO_REQ,  `REQ_DCACHE_FILL_ST,             breq_we)
    `MUX_2(mux_p2_x1, `REQ_2_SCH_W, inner_p2_x1, inner_p2_x0,  `REQ_DCACHE_FILL_LD,             breq_oe)
    `MUX_2(mux_p2,    `REQ_2_SCH_W, inner_p2,    inner_p2_x1,  `REQ_DCACHE_FILL_ST_OVERRIDE,    st_override_for_sch_req)

    //   Outer priority cascade (p3 < p2_pre < p1_pre < p0)
    wire [`REQ_2_SCH_W - 1 : 0] outer_l3;
    wire [`REQ_2_SCH_W - 1 : 0] outer_l2;
    wire [`REQ_2_SCH_W - 1 : 0] outer_l1;
    wire [`REQ_2_SCH_W - 1 : 0] req_2_sch;

    `MUX_2(mux_outer_l3, `REQ_2_SCH_W, outer_l3, `REQ_NO_REQ,  `REQ_DCACHE_EB_WR,           p3_pre)
    `MUX_2(mux_outer_l2, `REQ_2_SCH_W, outer_l2, outer_l3,     inner_p2,                    p2_pre)
    `MUX_2(mux_outer_l1, `REQ_2_SCH_W, outer_l1, outer_l2,     inner_p1,                    p1_pre)
    `MUX_2(mux_outer_l0, `REQ_2_SCH_W, req_2_sch,outer_l1,     `REQ_DCACHE_EB_BLOCKING_BANK,p0)

    //==================================================================
    // Address-bus tristate driver
    //   value = perm_Ld ? p_addr : eb.addr  (zero-extended to 32 bits)
    //   enable = perm_Ld | perm_eb (active-high) -> enbar = ~enable
    //==================================================================
    wire [`P_ADDR_W - 1 : 0]               addr_value_15b;
    wire [`ADDRESS_BUS_WIDTH_BITS - 1 : 0] addr_value_32b;
    `MUX_2(mux_addr_val, `P_ADDR_W, addr_value_15b, eb_addr, breq_paddr, permissionToDriveAddrBus_Ld)
    assign addr_value_32b = { {(`ADDRESS_BUS_WIDTH_BITS - `P_ADDR_W){1'b0}}, addr_value_15b };

    wire addr_drive_en;
    wire addr_drive_enbar;
    `OR_2(or_addr_drive, 1, addr_drive_en, permissionToDriveAddrBus_Ld, permissionToDriveAddrBus_eb)
    `INV_N(inv_addr_drive_en, 1, addr_drive_en, addr_drive_enbar)

    `BUS_TRISTATE(addr_bus_tri, `ADDRESS_BUS_WIDTH_BITS, addr_drive_enbar, addr_value_32b, address_bus)

    //==================================================================
    // Data-bus eviction-buf drivers (4 x 32-bit chunks, gated per-lane)
    //==================================================================
    wire [3:0] perm2DriveDataBus_bar;
    `INV_N(inv_perm_drive, 4, permissionToDriveDataBus_evictionBuf, perm2DriveDataBus_bar)

    `BUS_TRISTATE(memBus_tri_0, 32, perm2DriveDataBus_bar[0], eb_line[31:0],   dataBus)
    `BUS_TRISTATE(memBus_tri_1, 32, perm2DriveDataBus_bar[1], eb_line[63:32],  dataBus)
    `BUS_TRISTATE(memBus_tri_2, 32, perm2DriveDataBus_bar[2], eb_line[95:64],  dataBus)
    `BUS_TRISTATE(memBus_tri_3, 32, perm2DriveDataBus_bar[3], eb_line[127:96], dataBus)

    //==================================================================
    // Output bus assembly
    //==================================================================
    assign outputs_o[`DCBLK_OUT_LINE_UB:`DCBLK_OUT_LINE_LB] = dataLineOut;
    assign outputs_o[`DCBLK_OUT_HIT]                        = hit_o;
    assign outputs_o[`DCBLK_OUT_EBADDR_UB:`DCBLK_OUT_EBADDR_LB] = eb_addr;
    assign outputs_o[`DCBLK_OUT_REQ_UB:`DCBLK_OUT_REQ_LB]   = req_2_sch;

endmodule
