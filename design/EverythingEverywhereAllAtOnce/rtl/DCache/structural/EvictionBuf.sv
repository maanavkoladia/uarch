// Structural Verilog 2005 port of EvictionBuf.
// Reference SV: rtl/DCache/DCache_Block/EvictionBuf/EvictionBuf.sv
// Conventions: only assigns for wire aliasing; all logic via STDCell macros.
// Module name is suffixed _struct so the SV reference can coexist behind
// `ifdef USE_STRUCTURAL_EB in the parent (DCache_Block).

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

    // ---------------------------------------------------------------
    // Storage q outputs (driven by REG_RST_WE instances below)
    // ---------------------------------------------------------------
    wire         eb_valid;
    wire         eb_commiting;
    wire [14:0]  eb_address;
    wire [127:0] eb_dataLine;

    // ---------------------------------------------------------------
    // Combinational helper nets
    // ---------------------------------------------------------------
    wire         validReq;
    wire         eb_valid_bar;
    wire         LD_EB_qual;        // case 1 fires: vcache.LD_EB & ~eb.valid
    wire         LD_EB_qual_bar;
    wire         clr_qual;          // case 2 fires: ~LD_EB_qual & eb_clr_i
    wire         clr_qual_bar;
    wire         set_commit_qual;   // case 3 fires: ~LD_EB_qual & ~clr_qual & set_commiting
    wire         we_valid_path;     // valid+commiting share this OR(LD_EB_qual,clr_qual)
    wire         we_commiting;
    wire         addr_eq;           // tag match on paddr[14:4] vs eb_addr[14:4]
    wire         valid_and_validReq;

    // ---------------------------------------------------------------
    // Combinational gate netlist
    // ---------------------------------------------------------------
    `OR_2 (u_validReq,         1, validReq,        blockReq_oe_i,  blockReq_we_i)
    `INV_N(u_eb_valid_bar,     1, eb_valid,        eb_valid_bar)
    `AND_2(u_LDEB_qual,        1, LD_EB_qual,      vcache_LD_EB_i, eb_valid_bar)
    `INV_N(u_LDEB_qual_bar,    1, LD_EB_qual,      LD_EB_qual_bar)
    `AND_2(u_clr_qual,         1, clr_qual,        LD_EB_qual_bar, eb_clr_i)
    `INV_N(u_clr_qual_bar,     1, clr_qual,        clr_qual_bar)
    `AND_3(u_set_commit_qual,  1, set_commit_qual, LD_EB_qual_bar, clr_qual_bar, set_commiting_i)
    `OR_2 (u_we_valid_path,    1, we_valid_path,   LD_EB_qual,     clr_qual)
    `OR_2 (u_we_commiting,     1, we_commiting,    we_valid_path,  set_commit_qual)

    // address tag compare (bits [14:4] = 11 bits)
    `CMP_N(u_addr_eq,         11, addr_eq,         blockReq_paddr_i[14:4], eb_address[14:4])
    `AND_2(u_valid_validReq,   1, valid_and_validReq, validReq, eb_valid)
    `AND_2(u_reqHit,           1, ebOut_reqHit_o,  valid_and_validReq, addr_eq)

    // ---------------------------------------------------------------
    // Storage registers (REG_RST_WE: async active-low rst clears q to 0)
    //
    // d-input rationale (cases are mutually exclusive by construction):
    //   eb_valid     : we = LD_EB_qual | clr_qual,                    d = LD_EB_qual
    //                  (LD case writes 1; clr case writes 0; LD is the only case where d=1)
    //   eb_commiting : we = LD_EB_qual | clr_qual | set_commit_qual,  d = set_commit_qual
    //                  (set case writes 1; LD/clr cases write 0)
    //   eb_address   : we = LD_EB_qual,                               d = vcache_addrOut_i
    //   eb_dataLine  : we = LD_EB_qual,                               d = vcache_lineOut_i
    // ---------------------------------------------------------------
    `REG_RST_WE(u_eb_valid_reg,   1,   clk_i, rst_i, we_valid_path, LD_EB_qual,       eb_valid)
    `REG_RST_WE(u_eb_commit_reg,  1,   clk_i, rst_i, we_commiting,  set_commit_qual,  eb_commiting)
    `REG_RST_WE(u_eb_addr_reg,   15,   clk_i, rst_i, LD_EB_qual,    vcache_addrOut_i, eb_address)
    `REG_RST_WE(u_eb_line_reg,  128,   clk_i, rst_i, LD_EB_qual,    vcache_lineOut_i, eb_dataLine)

    // ---------------------------------------------------------------
    // Output drives (wire aliasing only)
    // ---------------------------------------------------------------
    assign ebOut_valid_o     = eb_valid;
    assign ebOut_commiting_o = eb_commiting;
    assign ebOut_addr_o      = eb_address;
    assign ebOut_lineOut_o   = eb_dataLine;
    // ebOut_reqHit_o is driven directly by u_reqHit AND_2 above

endmodule
