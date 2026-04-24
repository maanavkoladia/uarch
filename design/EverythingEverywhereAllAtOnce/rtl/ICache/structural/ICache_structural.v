module ICache (
    input  wire         clk,
    input  wire         rst,

    // core_2_icache_t (decomposed)
    input  wire         icache_en,
    input  wire [14:0]  p_addr,
    input  wire [31:0]  v_addr_i,
    input  wire [2:0]   num_valid_IDM_slots,

    // icache_2_core_t (decomposed)
    output wire         out_hit,
    output wire [127:0] out_instruction_line,

    // dte_2_icache_t (decomposed)
    input  wire         Mem_Valid,
    input  wire         driveAddrBus,

    // icache_2_scheduler_t (decomposed)
    output wire [13:0]  out_req,

    // Shared buses
    inout  wire [31:0]  dataBus,
    inout  wire [31:0]  addrBus
);

    // ------------------------------------------------------------------
    // FSM <-> rest-of-module signals
    // ------------------------------------------------------------------
    wire S_0, S_1, S_2;
    wire LD_IC_SWAP_BUF, RD_I_VC_SWAP_BUF;
    wire busy;
    wire MakeReq;
    wire Fill0EN, Fill1EN, Fill2EN, Fill3EN;

    // Hit/miss
    wire icache_miss, icache_hit;
    wire i_vcache_hit, i_vcache_miss;
    wire i_vcache_swapBuf_V_Clr;

    // Data/tag signals from submodules
    wire [127:0] icache_dataLines;
    wire [23:0]  icache_tag;
    wire         icache_tag_V;
    wire [127:0] i_vcache_dataLines;

    // Evicted-ICache-line swap buffer registers (decomposed)
    wire         icache_swapbuf_valid;
    wire [31:0]  icache_swapbuf_lineAddr;
    wire [127:0] icache_swapbuf_line;

    // I_VCache's output swap buffer (decomposed)
    wire         i_vcache_swapBuf_valid;
    wire [31:0]  i_vcache_swapBuf_lineAddr;
    wire [127:0] i_vcache_swapBuf_line;

    // Address latches / current address
    wire [31:0]  saved_vAddr;
    wire [14:0]  saved_pAddr;
    wire [31:0]  curr_v_addr_to_use;
    wire [31:0]  addrBus_drv;

    // ------------------------------------------------------------------
    // FSM instance (already structural in gen/)
    // ------------------------------------------------------------------
    ICache_Controller_Logic icache_controller_fsm (
        .clk(clk),
        .rst(rst),
        .IC_miss_i(icache_miss),
        .I_VC_Miss_i(i_vcache_miss),
        .mem_valid_i(Mem_Valid),
        .en_i(icache_en),
        .S_0(S_0),
        .S_1(S_1),
        .S_2(S_2),
        .LD_IC_SWAP_BUF_o(LD_IC_SWAP_BUF),
        .RD_I_VC_SWAP_BUF_o(RD_I_VC_SWAP_BUF),
        .busy_o(busy),
        .MakeReq_o(MakeReq),
        .Fill0EN_o(Fill0EN),
        .Fill1EN_o(Fill1EN),
        .Fill2EN_o(Fill2EN),
        .Fill3EN_o(Fill3EN)
    );

    // ------------------------------------------------------------------
    // Current v_addr mux (saved when busy, else live from core)
    // ------------------------------------------------------------------
    `MUX_2(u_vaddr_mux, 32, curr_v_addr_to_use, v_addr_i, saved_vAddr, busy)

    // ------------------------------------------------------------------
    // Submodule instances
    // ------------------------------------------------------------------
    ICache_TagStore icache_TagStore_unit (
        .clk(clk),
        .rst(rst),
        .en(icache_en),
        .v_addr_i(curr_v_addr_to_use),
        .ld_From_I_VC_Swap(RD_I_VC_SWAP_BUF),
        .LD_IC_SWAP_BUF(LD_IC_SWAP_BUF),
        .fill3_i(Fill3EN),
        .busy(busy),
        .I_VC_SwapBuf_i_valid(i_vcache_swapBuf_valid),
        .I_VC_SwapBuf_i_lineAddr(i_vcache_swapBuf_lineAddr),
        .I_VC_SwapBuf_i_line(i_vcache_swapBuf_line),
        .currTag_o(icache_tag),
        .currLine_V(icache_tag_V)
    );

    ICache_DataStore icache_dataStore_unit (
        .rst(rst),
        .clk(clk),
        .en(icache_en),
        .v_addr_i(curr_v_addr_to_use),
        .LD_IC_SWAP_BUF(LD_IC_SWAP_BUF),
        .fill0_i(Fill0EN),
        .fill1_i(Fill1EN),
        .fill2_i(Fill2EN),
        .fill3_i(Fill3EN),
        .busy(busy),
        .ld_From_I_VC_Swap(RD_I_VC_SWAP_BUF),
        .I_VC_SwapBuf_i_valid(i_vcache_swapBuf_valid),
        .I_VC_SwapBuf_i_lineAddr(i_vcache_swapBuf_lineAddr),
        .I_VC_SwapBuf_i_line(i_vcache_swapBuf_line),
        .dataBus(dataBus),
        .currLine_o(icache_dataLines)
    );

    I_VCache i_vcache_unit (
        .clk(clk),
        .rst(rst),
        .busy_i(busy),
        .en_i(icache_en),
        .v_addr_i(curr_v_addr_to_use),
        .IC_SwapBuf_i_valid(icache_swapbuf_valid),
        .IC_SwapBuf_i_lineAddr(icache_swapbuf_lineAddr),
        .IC_SwapBuf_i_line(icache_swapbuf_line),
        .I_VC_SwapBuf_o_valid(i_vcache_swapBuf_valid),
        .I_VC_SwapBuf_o_lineAddr(i_vcache_swapBuf_lineAddr),
        .I_VC_SwapBuf_o_line(i_vcache_swapBuf_line),
        .hit_o(i_vcache_hit),
        .miss_o(i_vcache_miss),
        .dataLineOut_o(i_vcache_dataLines),
        .IC_SwapBuf_V_clr_o(i_vcache_swapBuf_V_Clr)
    );

    // ------------------------------------------------------------------
    // Hit/miss generation
    //   tag_eq     = (icache_tag == v_addr_i[31:8])
    //   icache_hit = icache_en & !busy & icache_tag_V & tag_eq
    //   icache_miss= icache_en & !busy & (!icache_tag_V | !tag_eq)
    // ------------------------------------------------------------------
    wire [23:0] v_addr_i_tag_live;
    assign v_addr_i_tag_live = v_addr_i[31:8];

    wire tag_eq, tag_neq;
    `CMP_N(u_tag_cmp, 24, tag_eq, icache_tag, v_addr_i_tag_live)
    `INV_N(u_tag_neq, 1, tag_eq, tag_neq)

    wire busy_bar;
    `INV_N(u_busy_bar, 1, busy, busy_bar)

    wire valid_and_eq;
    `AND_2(u_vaa, 1, valid_and_eq, icache_tag_V, tag_eq)
    `AND_3(u_ich,  1, icache_hit,  icache_en, busy_bar, valid_and_eq)

    wire icache_tag_V_bar, nv_or_neq;
    `INV_N(u_tv_bar, 1, icache_tag_V, icache_tag_V_bar)
    `OR_2 (u_nvor,   1, nv_or_neq, icache_tag_V_bar, tag_neq)
    `AND_3(u_icm,    1, icache_miss, icache_en, busy_bar, nv_or_neq)

    // ------------------------------------------------------------------
    // Output hit & output instruction-line mux
    // ------------------------------------------------------------------
    `OR_2(u_outhit, 1, out_hit, icache_hit, i_vcache_hit)
    `MUX_2(u_instr_mux, 128, out_instruction_line,
           icache_dataLines, i_vcache_dataLines, i_vcache_hit)

    // ------------------------------------------------------------------
    // Scheduler request (3-way binary-encoded mux)
    //   out_req = MakeReq ? (num_lt_2 ? ICACHE_HIGH_PRI : ICACHE_LOW_PRI_REQ)
    //                     : NO_REQ
    // ------------------------------------------------------------------
    wire [13:0] NO_REQ_VAL;
    wire [13:0] LOW_PRI_VAL;
    wire [13:0] HIGH_PRI_VAL;

    assign NO_REQ_VAL   = 14'b00000000000000;
    assign LOW_PRI_VAL  = 14'b00000000000010;
    assign HIGH_PRI_VAL = 14'b00000000001110;

    // num_valid_IDM_slots < 2  <=>  bit[2] = 0 AND bit[1] = 0
    wire num2_bar, num1_bar, num_lt_2;
    `INV_N(u_n2_bar, 1, num_valid_IDM_slots[2], num2_bar)
    `INV_N(u_n1_bar, 1, num_valid_IDM_slots[1], num1_bar)
    `AND_2(u_num_lt_2, 1, num_lt_2, num2_bar, num1_bar)

    wire [13:0] pri_val;
    `MUX_2(u_pri, 14, pri_val, LOW_PRI_VAL, HIGH_PRI_VAL, num_lt_2)
    `MUX_2(u_req, 14, out_req, NO_REQ_VAL, pri_val, MakeReq)

    // ------------------------------------------------------------------
    // Address bus tristate
    //   addrBus = driveAddrBus ? {17'b0, saved_pAddr} : 'z
    // ------------------------------------------------------------------
    assign addrBus_drv = {17'b0, saved_pAddr};

    wire driveAddrBus_bar;
    `INV_N(u_dab_bar, 1, driveAddrBus, driveAddrBus_bar)
    `BUS_TRISTATE(u_addrBus_drv, 32, driveAddrBus_bar, addrBus_drv, addrBus)

    // ------------------------------------------------------------------
    // Evicted-ICache-line swap buffer registers
    //   set_case  = LD_IC_SWAP_BUF & icache_tag_V
    //   we_valid  = set_case | i_vcache_swapBuf_V_Clr
    //   d_valid   = set_case & !i_vcache_swapBuf_V_Clr
    //   lineAddr, line: WE = set_case
    // ------------------------------------------------------------------
    wire set_case;
    `AND_2(u_set_case, 1, set_case, LD_IC_SWAP_BUF, icache_tag_V)

    wire we_swapbuf_v, clr_bar, d_swapbuf_v;
    `OR_2 (u_we_sb_v, 1, we_swapbuf_v, set_case, i_vcache_swapBuf_V_Clr)
    `INV_N(u_clr_bar, 1, i_vcache_swapBuf_V_Clr, clr_bar)
    `AND_2(u_d_sb_v,  1, d_swapbuf_v, set_case, clr_bar)

    `REG_RST_WE(u_swapbuf_v, 1, clk, rst, we_swapbuf_v, d_swapbuf_v, icache_swapbuf_valid)

    wire [31:0] swap_lineAddr_d;
    assign swap_lineAddr_d = {icache_tag, v_addr_i[7:4], 4'b0000};

    `REG_RST_WE(u_swapbuf_la,   32, clk, rst, set_case, swap_lineAddr_d, icache_swapbuf_lineAddr)
    `REG_RST_WE(u_swapbuf_line, 128, clk, rst, set_case, icache_dataLines, icache_swapbuf_line)

    // ------------------------------------------------------------------
    // Saved v_addr / p_addr latches (update when !busy)
    // ------------------------------------------------------------------
    wire save_v_addr;
    `INV_N(u_save_va, 1, busy, save_v_addr)

    `REG_RST_WE(u_savedv, 32, clk, rst, save_v_addr, v_addr_i, saved_vAddr)
    `REG_RST_WE(u_savedp, 15, clk, rst, save_v_addr, p_addr,   saved_pAddr)

endmodule
