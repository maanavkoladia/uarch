// Structural Verilog 2005 port of IDM_Ctrl_Logic.
// All ports are packed buses (no unpacked-array ports).
//
// Multi-element layouts:
//   idm_slot_valid       : bit i        = slot i valid                       (4 bits)
//   invalidate           : bit i        = invalidate request for slot i      (4 bits)
//   data_in              : [i*8 +: 8]   = byte i of incoming cacheline       (128 bits)
//   idm_req_ld_meta_data : bit i        = request bit for slot i             (4 bits)
//   idm_req_ld_data      : bit i        = request bit for slot i             (4 bits)
//   idm_req_valid        : bit i        = valid bit for slot i               (4 bits)
//   idm_req_br_valid     : bit i        = br_valid bit for slot i            (4 bits)
//   idm_req_br_eip       : [i*32 +: 32] = br_eip for slot i                  (128 bits)
//   idm_req_br_target    : [i*32 +: 32] = br_target for slot i               (128 bits)
//   idm_req_br_xcl       : bit i        = br_xcl for slot i                  (4 bits)
//   idm_req_data         : [i*128 +: 128] = 16-byte slot data; byte k of slot
//                                           i at [i*128 + k*8 +: 8]          (512 bits)

module IDM_Ctrl_Logic (
    input  wire        exp_mode,
    input  wire        int_mode,
    input  wire [31:0] spc,

    input  wire [3:0]   idm_slot_valid,

    input  wire [3:0]   invalidate,
    input  wire        no_writes,

    input  wire        btb_hit,
    input  wire [31:0] btb_br_target,
    input  wire [31:0] btb_br_eip,
    input  wire        btb_XCL,

    input  wire        pred_taken,

    input  wire        icache_hit,

    input  wire        spc_sel_flush_reg,

    input  wire [127:0] data_in,

    output wire [3:0]   idm_req_ld_meta_data,
    output wire [3:0]   idm_req_ld_data,
    output wire [3:0]   idm_req_valid,
    output wire [3:0]   idm_req_br_valid,
    output wire [127:0] idm_req_br_eip,
    output wire [127:0] idm_req_br_target,
    output wire [3:0]   idm_req_br_xcl,
    output wire [511:0] idm_req_data,

    output wire        push_success
);

    localparam SLOT_BITS   = 2;       // $clog2(NUM_IDM_SLOTS)
    localparam OFFSET_BITS = 4;       // $clog2(CACHE_LINES_SIZE_B)

    // ----------------------------------------------------------------
    // slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS]   (= spc[5:4])
    // slot_oh  = one-hot of slot_num
    // ----------------------------------------------------------------
    wire [SLOT_BITS-1:0] slot_num;
    wire [3:0]           slot_oh;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];
    `DECODER_N(u_slot_dec, SLOT_BITS, slot_num, slot_oh)

    // ----------------------------------------------------------------
    // Shared combinational signals
    // ----------------------------------------------------------------
    wire activation;
    wire no_writes_n;
    wire flush_reg_n;
    wire br_cond_n;

    `OR_3  (u_act,  1, activation,        icache_hit, exp_mode, int_mode)
    `INV_N (u_nnw,  1, no_writes,         no_writes_n)
    `INV_N (u_nfr,  1, spc_sel_flush_reg, flush_reg_n)
    `NAND_3(u_brcn, 1, br_cond_n,         btb_hit, pred_taken, flush_reg_n)

    // ----------------------------------------------------------------
    // Per-slot core signals (internal unpacked-style packed buses)
    // ----------------------------------------------------------------
    wire [3:0] invalidate_n;
    wire [3:0] slot_valid_n;
    wire [3:0] wr_en_n;       // active-low write enable (NAND_4 output)
    wire [3:0] wr_en;          // active-high write enable (after one INV)
    wire [3:0] br_active;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot
            // ld_meta_data[i] = invalidate[i] | ~slot_valid[i]
            //                 = ~(~invalidate[i] & slot_valid[i])
            `INV_N (u_invn, 1, invalidate[i],     invalidate_n[i])
            `NAND_2(u_ldm,  1, idm_req_ld_meta_data[i],
                    invalidate_n[i], idm_slot_valid[i])

            // wr_en_n[i] = ~(~slot_valid[i] & slot_oh[i] & activation & ~no_writes)
            // wr_en[i]   = INV(wr_en_n[i])
            `INV_N (u_svn,  1, idm_slot_valid[i], slot_valid_n[i])
            `NAND_4(u_wen,  1, wr_en_n[i],
                    slot_valid_n[i], slot_oh[i], activation, no_writes_n)
            `INV_N (u_we,   1, wr_en_n[i],        wr_en[i])

            // br_active[i] = wr_en[i] & btb_hit & pred_taken & flush_reg_n
            //              = ~wr_en_n[i] & ~br_cond_n
            //              = NOR_2(wr_en_n[i], br_cond_n)
            `NOR_2 (u_bra,  1, br_active[i],      wr_en_n[i], br_cond_n)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot scalar outputs
    // ----------------------------------------------------------------
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_scalar_out
            assign idm_req_valid[i]    = wr_en[i];
            assign idm_req_ld_data[i]  = wr_en[i];
            assign idm_req_br_valid[i] = br_active[i];

            `AND_2(u_brxcl, 1, idm_req_br_xcl[i], br_active[i], btb_XCL)
        end
    endgenerate

    // ----------------------------------------------------------------
    // Per-slot wide outputs
    //   br_eip[i]    = br_active[i] ? btb_br_eip    : 0
    //   br_target[i] = br_active[i] ? btb_br_target : 0
    //   data[i]      = wr_en[i]     ? data_in       : 0
    // ----------------------------------------------------------------
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_slot_wide_out
            wire [31:0]  slot_br_eip;
            wire [31:0]  slot_br_target;
            wire [127:0] slot_data;

            `MUX_2(u_be, 32,  slot_br_eip,
                   32'h0,  btb_br_eip,    br_active[i])
            `MUX_2(u_bt, 32,  slot_br_target,
                   32'h0,  btb_br_target, br_active[i])
            `MUX_2(u_dm, 128, slot_data,
                   128'h0, data_in,       wr_en[i])

            assign idm_req_br_eip   [i*32  +: 32 ] = slot_br_eip;
            assign idm_req_br_target[i*32  +: 32 ] = slot_br_target;
            assign idm_req_data     [i*128 +: 128] = slot_data;
        end
    endgenerate

    // ----------------------------------------------------------------
    // push_success = OR over slots of wr_en[i]
    //              = NAND_4 of wr_en_n[i]   (NAND-of-NANDs = OR)
    // ----------------------------------------------------------------
    `NAND_4(u_psucc, 1, push_success,
            wr_en_n[0], wr_en_n[1], wr_en_n[2], wr_en_n[3])

endmodule
