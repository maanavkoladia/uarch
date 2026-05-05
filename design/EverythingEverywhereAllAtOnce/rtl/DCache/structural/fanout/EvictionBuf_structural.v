// Pure Verilog 2005 port of EvictionBuf.
// Reference: rtl/DCache/structural/EvictionBuf.sv
// Conventions: only assigns for wire aliasing; all logic via STDCell macros
// from lib/STDCells/STDCell_Macros.vh (globally on the include path).

module EvictionBuf (
    input  wire         clk_i,
    input  wire         rst_i,                 // active-low (REG_RST_WE convention)

    input  wire         eb_clr_i,
    input  wire         set_commiting_i,

    // unpacked from block_req_t (only fields EB consumes)
    input  wire         blockReq_oe_i,
    input  wire         blockReq_we_i,
    input  wire [14:0]  blockReq_paddr_i,      // p_address_t = $clog2(PHY_MEM_SIZE) = 15

    // unpacked from v_cache_outputs_t (only fields EB consumes)
    input  wire         vcache_LD_EB_i,
    input  wire [14:0]  vcache_addrOut_i,
    input  wire [127:0] vcache_lineOut_i,      // CACHE_LINES_SIZE_BITS = 128

    // unpacked from eb_outputs_t
    output wire         ebOut_valid_o,
    output wire         ebOut_commiting_o,
    output wire [14:0]  ebOut_addr_o,
    output wire [127:0] ebOut_lineOut_o,
    output wire         ebOut_reqHit_o
);

    wire         eb_valid;
    wire         eb_commiting;
    wire [14:0]  eb_address;
    wire [127:0] eb_dataLine;

    wire         validReq;
    wire         eb_valid_bar;
    wire         LD_EB_qual;
    wire         LD_EB_qual_bar;
    wire         clr_qual;
    wire         clr_qual_bar;
    wire         set_commit_qual;
    wire         we_valid_path;
    wire         we_commiting;
    wire         addr_eq;
    wire         valid_and_validReq;

    `OR_2 (u_validReq,         1, validReq,        blockReq_oe_i,  blockReq_we_i)
    `INV_N(u_eb_valid_bar,     1, eb_valid,        eb_valid_bar)
    // u_LDEB_qual fanout=6 (drives LD_EB_qual_bar INV + we_valid_path OR + flat).
    // bufferH16$ +0.24 ns, off cache read-hit path (EB load-from-VCache control).
    wire LD_EB_qual_pre;
    `AND_2(u_LDEB_qual,        1, LD_EB_qual_pre,  vcache_LD_EB_i, eb_valid_bar)
    bufferH16$ u_LDEB_qual_buf (.out(LD_EB_qual), .in(LD_EB_qual_pre));
    `INV_N(u_LDEB_qual_bar,    1, LD_EB_qual,      LD_EB_qual_bar)
    `AND_2(u_clr_qual,         1, clr_qual,        LD_EB_qual_bar, eb_clr_i)
    `INV_N(u_clr_qual_bar,     1, clr_qual,        clr_qual_bar)
    `AND_3(u_set_commit_qual,  1, set_commit_qual, LD_EB_qual_bar, clr_qual_bar, set_commiting_i)
    `OR_2 (u_we_valid_path,    1, we_valid_path,   LD_EB_qual,     clr_qual)
    `OR_2 (u_we_commiting,     1, we_commiting,    we_valid_path,  set_commit_qual)

    `CMP_N(u_addr_eq,         11, addr_eq,         blockReq_paddr_i[14:4], eb_address[14:4])
    `AND_2(u_valid_validReq,   1, valid_and_validReq, validReq, eb_valid)
    // u_reqHit fanout=5 (drives ebOut_reqHit_o port -> flattens to 5 flat consumers
    // in DCache_Block FSM/Bank/VCache). bufferH16$ +0.24 ns, on EB-hit path which
    // is parallel to the cache hit determination (EB hit serves stale data faster
    // when present, so a +0.24 ns delay here is masked by the slower cache path).
    wire ebOut_reqHit_pre;
    `AND_2(u_reqHit,           1, ebOut_reqHit_pre, valid_and_validReq, addr_eq)
    bufferH16$ u_reqHit_buf (.out(ebOut_reqHit_o), .in(ebOut_reqHit_pre));

    // u_eb_valid_reg.Q fanout=6 (eb_valid_bar INV, valid_and_validReq AND,
    // ebOut_valid_o port -- which fans out across Bank/VCache/EB consumers).
    // bufferH16$ at register output -- +0.24 ns. eb_valid feeds the EB hit
    // determination but the addr_eq compare is the dominant delay there.
    wire eb_valid_pre;
    `REG_RST_WE(u_eb_valid_reg,   1,   clk_i, rst_i, we_valid_path, LD_EB_qual,       eb_valid_pre)
    bufferH16$ u_eb_valid_buf (.out(eb_valid), .in(eb_valid_pre));
    `REG_RST_WE(u_eb_commit_reg,  1,   clk_i, rst_i, we_commiting,  set_commit_qual,  eb_commiting)
    `REG_RST_WE(u_eb_addr_reg,   15,   clk_i, rst_i, LD_EB_qual,    vcache_addrOut_i, eb_address)
    `REG_RST_WE(u_eb_line_reg,  128,   clk_i, rst_i, LD_EB_qual,    vcache_lineOut_i, eb_dataLine)

    assign ebOut_valid_o     = eb_valid;
    assign ebOut_commiting_o = eb_commiting;
    assign ebOut_addr_o      = eb_address;
    assign ebOut_lineOut_o   = eb_dataLine;

endmodule
