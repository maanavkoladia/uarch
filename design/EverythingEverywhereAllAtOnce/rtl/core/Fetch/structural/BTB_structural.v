// Structural Verilog 2005 port of BTB.
// Reference SV: rtl/core/Fetch/structural/BTB.sv (original).
//
// Direct-mapped BTB.
//
//   address layout (32-bit, 16-byte cache lines, BTB_ENTRIES entries):
//     spc[ADDRESS_BITS-1 : INDEX_OFF+INDEX_BITS]   = tag
//     spc[INDEX_OFF+INDEX_BITS-1 : INDEX_OFF]      = index
//     spc[INDEX_OFF-1 : 0]                         = byte offset within line (= 0 for fetch)
//
//   Read (combinational on spc):
//     entry = entries[spc.index]
//     hit   = entry.valid & (entry.tag == spc.tag)
//     br_target / br_eip / XCL / br_ucond come from the selected entry
//
//   Write (synchronous on exe_br_valid, indexed by exe_br_eip):
//     entries[exe_br_eip.index] <= {tag=exe_br_eip.tag, target, eip, XCL, ucond, valid=1}
//
// Configurable BTB_ENTRIES via `define at the top of the file. Must be a
// power of 2 (the binary mux tree below relies on it).

`ifndef BTB_ENTRIES
`define BTB_ENTRIES 64
`endif

module BTB (
    input  wire        clk,
    input  wire        rst,           // active low

    input  wire [31:0] spc,

    input  wire        exe_br_valid,
    input  wire [31:0] exe_br_target,
    input  wire [31:0] exe_br_eip,
    input  wire        exe_br_XCL,
    input  wire        exe_br_ucond,

    output wire        hit,
    output wire [31:0] br_target,
    output wire [31:0] br_eip,
    output wire        XCL,
    output wire        br_ucond
);

    // ----------------------------------------------------------------
    // Sizing
    // ----------------------------------------------------------------
    localparam ADDRESS_BITS = 32;
    localparam INDEX_OFF    = 4;                       // $clog2(CACHE_LINES_SIZE_B), CACHE_LINES_SIZE_B=16
    localparam ENTRIES      = `BTB_ENTRIES;
    localparam INDEX_BITS   = $clog2(ENTRIES);
    localparam TAG_BITS     = ADDRESS_BITS - INDEX_OFF - INDEX_BITS;

    // ----------------------------------------------------------------
    // Per-entry packed layout (one storage register per entry):
    //   bits  [TAG_BITS-1            : 0           ]   tag
    //   bits  [TAG_BITS+31           : TAG_BITS    ]   br_target
    //   bits  [TAG_BITS+63           : TAG_BITS+32 ]   br_eip
    //   bit   [TAG_BITS+64                         ]   XCL
    //   bit   [TAG_BITS+65                         ]   br_ucond
    //   bit   [TAG_BITS+66                         ]   valid
    // ----------------------------------------------------------------
    localparam ENTRY_W   = TAG_BITS + 32 + 32 + 1 + 1 + 1;
    localparam OFF_TGT   = TAG_BITS;
    localparam OFF_EIP   = TAG_BITS + 32;
    localparam OFF_XCL   = TAG_BITS + 64;
    localparam OFF_UCOND = TAG_BITS + 65;
    localparam OFF_VALID = TAG_BITS + 66;

    // ----------------------------------------------------------------
    // Address field extraction (pure wire slicing — no gates)
    // ----------------------------------------------------------------
    wire [TAG_BITS-1:0]   spc_tag;
    wire [INDEX_BITS-1:0] spc_index;
    wire [TAG_BITS-1:0]   exe_tag;
    wire [INDEX_BITS-1:0] exe_index;

    assign spc_tag   = spc       [ADDRESS_BITS-1            : INDEX_OFF + INDEX_BITS];
    assign spc_index = spc       [INDEX_OFF + INDEX_BITS - 1: INDEX_OFF];
    assign exe_tag   = exe_br_eip[ADDRESS_BITS-1            : INDEX_OFF + INDEX_BITS];
    assign exe_index = exe_br_eip[INDEX_OFF + INDEX_BITS - 1: INDEX_OFF];

    // ----------------------------------------------------------------
    // Storage: ENTRIES x ENTRY_W register file.
    // entry_d is the common write-data bus shared across all entries
    // (only the entry whose write_en is high latches it).
    // ----------------------------------------------------------------
    wire [ENTRY_W-1:0] entry_q [0:ENTRIES-1];
    wire [ENTRY_W-1:0] entry_d;

    assign entry_d = {1'b1,           // valid
                      exe_br_ucond,
                      exe_br_XCL,
                      exe_br_eip,
                      exe_br_target,
                      exe_tag};

    // ----------------------------------------------------------------
    // Write decoder + per-entry write enable
    //   write_oh = 1<<exe_index
    //   write_en[i] = exe_br_valid & write_oh[i]
    // ----------------------------------------------------------------
    wire [ENTRIES-1:0] write_oh;
    wire [ENTRIES-1:0] write_en;
    `DECODER_N(u_wr_dec, INDEX_BITS, exe_index, write_oh)

    genvar i;
    generate
        for (i = 0; i < ENTRIES; i = i + 1) begin : g_entry
            `AND_2(u_we, 1, write_en[i], write_oh[i], exe_br_valid)
            `REG_RST_WE(u_reg, ENTRY_W, clk, rst, write_en[i], entry_d, entry_q[i])
        end
    endgenerate

    // ----------------------------------------------------------------
    // Read mux: select entry_q[spc_index].
    // Binary tree of 2:1 muxes, ENTRY_W bits wide, ENTRIES inputs.
    //
    // Heap layout: read_tree[1] is the root, read_tree[ENTRIES..2*ENTRIES-1]
    // are leaves. Node i has children 2*i and 2*i+1.
    // depth(i) = floor(log2(i)) = $clog2(i+1)-1.
    // Selector for level d is spc_index[INDEX_BITS-1-d].
    // ----------------------------------------------------------------
    wire [ENTRY_W-1:0] read_tree [0:2*ENTRIES-1];

    generate
        for (i = 0; i < ENTRIES; i = i + 1) begin : g_rd_leaf
            assign read_tree[ENTRIES + i] = entry_q[i];
        end
        for (i = 1; i < ENTRIES; i = i + 1) begin : g_rd_node
            localparam DEPTH   = $clog2(i + 1) - 1;
            localparam SEL_BIT = INDEX_BITS - 1 - DEPTH;
            `MUX_2(u_mux, ENTRY_W,
                   read_tree[i],
                   read_tree[2*i], read_tree[2*i + 1],
                   spc_index[SEL_BIT])
        end
    endgenerate

    // ----------------------------------------------------------------
    // Unpack the selected entry
    //
    // Each per-bit mux2$.outb at the read-tree root sees fanout 6-8 from
    // downstream consumers (CMP_N internals on the tag bits, output port
    // fanout to Fetch on the data bits). bufferH16$ (rated 16) on each bit
    // of sel_entry clears the violation; ~0.24 ns added to BTB read path.
    // ----------------------------------------------------------------
    wire [ENTRY_W-1:0]  sel_entry_raw;
    wire [ENTRY_W-1:0]  sel_entry;
    wire [TAG_BITS-1:0] sel_tag;
    wire                sel_valid;

    assign sel_entry_raw = read_tree[1];

    genvar sb;
    generate
        for (sb = 0; sb < ENTRY_W; sb = sb + 1) begin : g_buf_sel_entry
            bufferH16$ u_buf (.out(sel_entry[sb]), .in(sel_entry_raw[sb]));
        end
    endgenerate

    assign sel_tag   = sel_entry[TAG_BITS-1            : 0];
    assign br_target = sel_entry[OFF_EIP-1             : OFF_TGT];
    assign br_eip    = sel_entry[OFF_XCL-1             : OFF_EIP];
    assign XCL       = sel_entry[OFF_XCL];
    assign br_ucond  = sel_entry[OFF_UCOND];
    assign sel_valid = sel_entry[OFF_VALID];

    // ----------------------------------------------------------------
    // Hit logic: tag match AND valid
    // ----------------------------------------------------------------
    wire tag_match;
    `CMP_N(u_tag_cmp, TAG_BITS, tag_match, sel_tag, spc_tag)
    `AND_2(u_hit,     1,        hit,       tag_match, sel_valid)

endmodule
