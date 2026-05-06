// ============================================================================
// ACTIVE: Pure structural port of ST_Q_logic.
// Combinational decoder: takes one or two store entries (entry0 always, entry1
// only when ST_XCL=1) and routes each to the correct one of NUM_WB_ST_QS=4
// store queues based on physical address bits [5:4]. Pop is always wired
// straight through from write_success_<i>.
//
// Bank-collision arbitration matches the legacy SV: when entry0 and entry1
// both target the same bank, entry1 wins (legacy 'if (entry1.valid)' overwrote
// the entry0 assignment). This is a design error case (the legacy SV $error
// fires); priority here is don't-care, but kept faithful for parity.
//
// Struct unrolling map (per queue i in 0..3) for output stq_info[i]:
//   stq_info[i].push          -> stq_info_<i>_push          (1)
//   stq_info[i].pop           -> stq_info_<i>_pop           (1)
//   stq_info[i].data.valid    -> stq_info_<i>_data_valid    (1)
//   stq_info[i].data.address  -> stq_info_<i>_data_address  (15)
//   stq_info[i].data.bit_vec  -> stq_info_<i>_data_bit_vec  (16)
//   stq_info[i].data.data     -> stq_info_<i>_data_data     (128)
//
// To revert to the legacy SV implementation: comment this module out and
// uncomment the legacy block at the bottom of this file (and switch the
// WB.sv instantiation back to the struct-based one).
// ============================================================================
module ST_Q_logic (
    input  wire         wb_valid,
    input  wire [14:0]  st_paddr_0,
    input  wire [14:0]  st_paddr_1,
    input  wire [255:0] res_buf,        // 32 bytes, low half = entry0 data,
                                        //           high half = entry1 data
    input  wire [15:0]  bit_vect_0,
    input  wire [15:0]  bit_vect_1,
    input  wire         ST_OP,
    input  wire         ST_XCL,
    input  wire         MIO,
    input  wire         write_success_0,
    input  wire         write_success_1,
    input  wire         write_success_2,
    input  wire         write_success_3,

    // queue 0
    output wire         stq_info_0_push,
    output wire         stq_info_0_pop,
    output wire         stq_info_0_data_valid,
    output wire [14:0]  stq_info_0_data_address,
    output wire [15:0]  stq_info_0_data_bit_vec,
    output wire [127:0] stq_info_0_data_data,
    // queue 1
    output wire         stq_info_1_push,
    output wire         stq_info_1_pop,
    output wire         stq_info_1_data_valid,
    output wire [14:0]  stq_info_1_data_address,
    output wire [15:0]  stq_info_1_data_bit_vec,
    output wire [127:0] stq_info_1_data_data,
    // queue 2
    output wire         stq_info_2_push,
    output wire         stq_info_2_pop,
    output wire         stq_info_2_data_valid,
    output wire [14:0]  stq_info_2_data_address,
    output wire [15:0]  stq_info_2_data_bit_vec,
    output wire [127:0] stq_info_2_data_data,
    // queue 3
    output wire         stq_info_3_push,
    output wire         stq_info_3_pop,
    output wire         stq_info_3_data_valid,
    output wire [14:0]  stq_info_3_data_address,
    output wire [15:0]  stq_info_3_data_bit_vec,
    output wire [127:0] stq_info_3_data_data
);

    // -------------------------------------------------------------------
    // Per-entry validity:  entry0_valid = ST_OP & ~MIO & wb_valid
    //                      entry1_valid = ST_OP & ST_XCL & ~MIO & wb_valid
    // -------------------------------------------------------------------
    wire not_mio_w;
    `INV_N(u_inv_mio, 1, MIO, not_mio_w)

    wire entry0_valid_w;
    wire entry1_valid_w;
    `AND_3(u_entry0_valid_and, 1, entry0_valid_w, ST_OP, not_mio_w, wb_valid)
    `AND_4(u_entry1_valid_and, 1, entry1_valid_w, ST_OP, ST_XCL, not_mio_w, wb_valid)

    // -------------------------------------------------------------------
    // Bank decode from address bits [5:4] (above the 4-bit cache-line
    // offset, low 2 bits of the cache-line index).
    // -------------------------------------------------------------------
    wire [1:0] low_bank_num_w;
    wire [1:0] high_bank_num_w;
    assign low_bank_num_w  = st_paddr_0[5:4];
    assign high_bank_num_w = st_paddr_1[5:4];

    wire [3:0] low_bank_dec_w;
    wire [3:0] high_bank_dec_w;
    `DECODER_N(u_low_bank_dec,  2, low_bank_num_w,  low_bank_dec_w)
    `DECODER_N(u_high_bank_dec, 2, high_bank_num_w, high_bank_dec_w)

    // -------------------------------------------------------------------
    // Per-queue routing signals: entry0_to_<i>, entry1_to_<i>
    // -------------------------------------------------------------------
    wire entry0_to_0_w, entry0_to_1_w, entry0_to_2_w, entry0_to_3_w;
    wire entry1_to_0_w, entry1_to_1_w, entry1_to_2_w, entry1_to_3_w;
    wire entry0_to_0_raw, entry0_to_1_raw, entry0_to_2_raw, entry0_to_3_raw;
    wire entry1_to_0_raw, entry1_to_1_raw, entry1_to_2_raw, entry1_to_3_raw;

    `AND_2(u_e0_to_0, 1, entry0_to_0_raw, entry0_valid_w, low_bank_dec_w[0])
    `AND_2(u_e0_to_1, 1, entry0_to_1_raw, entry0_valid_w, low_bank_dec_w[1])
    `AND_2(u_e0_to_2, 1, entry0_to_2_raw, entry0_valid_w, low_bank_dec_w[2])
    `AND_2(u_e0_to_3, 1, entry0_to_3_raw, entry0_valid_w, low_bank_dec_w[3])

    `AND_2(u_e1_to_0, 1, entry1_to_0_raw, entry1_valid_w, high_bank_dec_w[0])
    `AND_2(u_e1_to_1, 1, entry1_to_1_raw, entry1_valid_w, high_bank_dec_w[1])
    `AND_2(u_e1_to_2, 1, entry1_to_2_raw, entry1_valid_w, high_bank_dec_w[2])
    `AND_2(u_e1_to_3, 1, entry1_to_3_raw, entry1_valid_w, high_bank_dec_w[3])

    // Each entry_to_X_w drives 1+15+16+128 = 160 mux2$ select pins (selects
    // for u_push_X + u_tmp_addr_X + u_tmp_bv_X + u_tmp_data_X for entry0,
    // and u_addr_X + u_bv_X + u_data_X for entry1). bufferH256$ is the
    // smallest H-buffer covering — single cell at 0.54 ns typ.
    bufferH256$ u_buf_e0_0 (.out(entry0_to_0_w), .in(entry0_to_0_raw));
    bufferH256$ u_buf_e0_1 (.out(entry0_to_1_w), .in(entry0_to_1_raw));
    bufferH256$ u_buf_e0_2 (.out(entry0_to_2_w), .in(entry0_to_2_raw));
    bufferH256$ u_buf_e0_3 (.out(entry0_to_3_w), .in(entry0_to_3_raw));
    bufferH256$ u_buf_e1_0 (.out(entry1_to_0_w), .in(entry1_to_0_raw));
    bufferH256$ u_buf_e1_1 (.out(entry1_to_1_w), .in(entry1_to_1_raw));
    bufferH256$ u_buf_e1_2 (.out(entry1_to_2_w), .in(entry1_to_2_raw));
    bufferH256$ u_buf_e1_3 (.out(entry1_to_3_w), .in(entry1_to_3_raw));

    // -------------------------------------------------------------------
    // Per-queue push = entry0_to_i | entry1_to_i
    // data.valid mirrors push (legacy: data field is zero unless an entry
    // routed here, in which case its valid bit is 1).
    // pop is always the dcache-side write_success_<i>.
    // -------------------------------------------------------------------
    wire stq_info_0_push_raw, stq_info_1_push_raw, stq_info_2_push_raw, stq_info_3_push_raw;
    `OR_2(u_push_0, 1, stq_info_0_push_raw, entry0_to_0_w, entry1_to_0_w)
    `OR_2(u_push_1, 1, stq_info_1_push_raw, entry0_to_1_w, entry1_to_1_w)
    `OR_2(u_push_2, 1, stq_info_2_push_raw, entry0_to_2_w, entry1_to_2_w)
    `OR_2(u_push_3, 1, stq_info_3_push_raw, entry0_to_3_w, entry1_to_3_w)
    // Each push signal feeds the ST_Q push pin + the data_valid alias = ~10
    // leaves. bufferH16$ smallest fit (0.24 ns typ).
    bufferH16$ u_buf_push_0 (.out(stq_info_0_push), .in(stq_info_0_push_raw));
    bufferH16$ u_buf_push_1 (.out(stq_info_1_push), .in(stq_info_1_push_raw));
    bufferH16$ u_buf_push_2 (.out(stq_info_2_push), .in(stq_info_2_push_raw));
    bufferH16$ u_buf_push_3 (.out(stq_info_3_push), .in(stq_info_3_push_raw));

    assign stq_info_0_data_valid = stq_info_0_push;
    assign stq_info_1_data_valid = stq_info_1_push;
    assign stq_info_2_data_valid = stq_info_2_push;
    assign stq_info_3_data_valid = stq_info_3_push;

    assign stq_info_0_pop = write_success_0;
    assign stq_info_1_pop = write_success_1;
    assign stq_info_2_pop = write_success_2;
    assign stq_info_3_pop = write_success_3;

    // -------------------------------------------------------------------
    // Per-queue data field selection.
    // For each field f in {address, bit_vec, data}, build:
    //   tmp_f_<i>      = MUX_2( {0}, entry0_f, entry0_to_<i> )
    //   stq_..._f_<i>  = MUX_2( tmp_f_<i>, entry1_f, entry1_to_<i> )
    // Priority on bank-collision is entry1 (matches legacy SV behavior
    // where the second 'if (entry1.valid)' overwrote entry0's assignment).
    // -------------------------------------------------------------------

    // entry0 / entry1 raw data fields (wires)
    wire [14:0]  entry0_address_w = st_paddr_0;
    wire [14:0]  entry1_address_w = st_paddr_1;
    wire [15:0]  entry0_bit_vec_w = bit_vect_0;
    wire [15:0]  entry1_bit_vec_w = bit_vect_1;
    wire [127:0] entry0_data_w    = res_buf[127:0];
    wire [127:0] entry1_data_w    = res_buf[255:128];

    // _raw outputs for the 4 queues' addr/bv/data muxes; per-bit bufferH16$
    // generated below drives the actual output ports (each output bit fans
    // out to ~8 leaves inside the downstream ST_Q instance).
    wire [14:0]  stq_info_0_data_address_raw, stq_info_1_data_address_raw;
    wire [14:0]  stq_info_2_data_address_raw, stq_info_3_data_address_raw;
    wire [15:0]  stq_info_0_data_bit_vec_raw, stq_info_1_data_bit_vec_raw;
    wire [15:0]  stq_info_2_data_bit_vec_raw, stq_info_3_data_bit_vec_raw;
    wire [127:0] stq_info_0_data_data_raw,    stq_info_1_data_data_raw;
    wire [127:0] stq_info_2_data_data_raw,    stq_info_3_data_data_raw;

    // ---- queue 0 ----
    wire [14:0]  tmp_addr_0_w;
    wire [15:0]  tmp_bv_0_w;
    wire [127:0] tmp_data_0_w;
    `MUX_2(u_tmp_addr_0, 15, tmp_addr_0_w, 15'd0,        entry0_address_w, entry0_to_0_w)
    `MUX_2(u_addr_0,     15, stq_info_0_data_address_raw, tmp_addr_0_w, entry1_address_w, entry1_to_0_w)
    `MUX_2(u_tmp_bv_0,   16, tmp_bv_0_w,   16'd0,        entry0_bit_vec_w, entry0_to_0_w)
    `MUX_2(u_bv_0,       16, stq_info_0_data_bit_vec_raw, tmp_bv_0_w,   entry1_bit_vec_w, entry1_to_0_w)
    `MUX_2(u_tmp_data_0, 128, tmp_data_0_w, 128'd0,       entry0_data_w,    entry0_to_0_w)
    `MUX_2(u_data_0,     128, stq_info_0_data_data_raw, tmp_data_0_w, entry1_data_w,    entry1_to_0_w)

    // ---- queue 1 ----
    wire [14:0]  tmp_addr_1_w;
    wire [15:0]  tmp_bv_1_w;
    wire [127:0] tmp_data_1_w;
    `MUX_2(u_tmp_addr_1, 15, tmp_addr_1_w, 15'd0,        entry0_address_w, entry0_to_1_w)
    `MUX_2(u_addr_1,     15, stq_info_1_data_address_raw, tmp_addr_1_w, entry1_address_w, entry1_to_1_w)
    `MUX_2(u_tmp_bv_1,   16, tmp_bv_1_w,   16'd0,        entry0_bit_vec_w, entry0_to_1_w)
    `MUX_2(u_bv_1,       16, stq_info_1_data_bit_vec_raw, tmp_bv_1_w,   entry1_bit_vec_w, entry1_to_1_w)
    `MUX_2(u_tmp_data_1, 128, tmp_data_1_w, 128'd0,       entry0_data_w,    entry0_to_1_w)
    `MUX_2(u_data_1,     128, stq_info_1_data_data_raw, tmp_data_1_w, entry1_data_w,    entry1_to_1_w)

    // ---- queue 2 ----
    wire [14:0]  tmp_addr_2_w;
    wire [15:0]  tmp_bv_2_w;
    wire [127:0] tmp_data_2_w;
    `MUX_2(u_tmp_addr_2, 15, tmp_addr_2_w, 15'd0,        entry0_address_w, entry0_to_2_w)
    `MUX_2(u_addr_2,     15, stq_info_2_data_address_raw, tmp_addr_2_w, entry1_address_w, entry1_to_2_w)
    `MUX_2(u_tmp_bv_2,   16, tmp_bv_2_w,   16'd0,        entry0_bit_vec_w, entry0_to_2_w)
    `MUX_2(u_bv_2,       16, stq_info_2_data_bit_vec_raw, tmp_bv_2_w,   entry1_bit_vec_w, entry1_to_2_w)
    `MUX_2(u_tmp_data_2, 128, tmp_data_2_w, 128'd0,       entry0_data_w,    entry0_to_2_w)
    `MUX_2(u_data_2,     128, stq_info_2_data_data_raw, tmp_data_2_w, entry1_data_w,    entry1_to_2_w)

    // ---- queue 3 ----
    wire [14:0]  tmp_addr_3_w;
    wire [15:0]  tmp_bv_3_w;
    wire [127:0] tmp_data_3_w;
    `MUX_2(u_tmp_addr_3, 15, tmp_addr_3_w, 15'd0,        entry0_address_w, entry0_to_3_w)
    `MUX_2(u_addr_3,     15, stq_info_3_data_address_raw, tmp_addr_3_w, entry1_address_w, entry1_to_3_w)
    `MUX_2(u_tmp_bv_3,   16, tmp_bv_3_w,   16'd0,        entry0_bit_vec_w, entry0_to_3_w)
    `MUX_2(u_bv_3,       16, stq_info_3_data_bit_vec_raw, tmp_bv_3_w,   entry1_bit_vec_w, entry1_to_3_w)
    `MUX_2(u_tmp_data_3, 128, tmp_data_3_w, 128'd0,       entry0_data_w,    entry0_to_3_w)
    `MUX_2(u_data_3,     128, stq_info_3_data_data_raw, tmp_data_3_w, entry1_data_w,    entry1_to_3_w)

    // ===================================================================
    // Output buffering: per-bit bufferH16$ on every output mux's data wire.
    // Each bit drives ~8 leaves inside one ST_Q instance (4 entries x 2
    // smpo/smpp data muxes = 8 mux2$ pins). bufferH16$ at 0.24 ns is the
    // smallest H-buffer that covers fanout 8.
    // ===================================================================
    genvar gi_a, gi_b, gi_d;
    generate
        for (gi_a = 0; gi_a < 15; gi_a = gi_a + 1) begin : g_addr_buf
            bufferH16$ u_b0 (.out(stq_info_0_data_address[gi_a]), .in(stq_info_0_data_address_raw[gi_a]));
            bufferH16$ u_b1 (.out(stq_info_1_data_address[gi_a]), .in(stq_info_1_data_address_raw[gi_a]));
            bufferH16$ u_b2 (.out(stq_info_2_data_address[gi_a]), .in(stq_info_2_data_address_raw[gi_a]));
            bufferH16$ u_b3 (.out(stq_info_3_data_address[gi_a]), .in(stq_info_3_data_address_raw[gi_a]));
        end
        for (gi_b = 0; gi_b < 16; gi_b = gi_b + 1) begin : g_bv_buf
            bufferH16$ u_b0 (.out(stq_info_0_data_bit_vec[gi_b]), .in(stq_info_0_data_bit_vec_raw[gi_b]));
            bufferH16$ u_b1 (.out(stq_info_1_data_bit_vec[gi_b]), .in(stq_info_1_data_bit_vec_raw[gi_b]));
            bufferH16$ u_b2 (.out(stq_info_2_data_bit_vec[gi_b]), .in(stq_info_2_data_bit_vec_raw[gi_b]));
            bufferH16$ u_b3 (.out(stq_info_3_data_bit_vec[gi_b]), .in(stq_info_3_data_bit_vec_raw[gi_b]));
        end
        for (gi_d = 0; gi_d < 128; gi_d = gi_d + 1) begin : g_data_buf
            bufferH16$ u_b0 (.out(stq_info_0_data_data[gi_d]), .in(stq_info_0_data_data_raw[gi_d]));
            bufferH16$ u_b1 (.out(stq_info_1_data_data[gi_d]), .in(stq_info_1_data_data_raw[gi_d]));
            bufferH16$ u_b2 (.out(stq_info_2_data_data[gi_d]), .in(stq_info_2_data_data_raw[gi_d]));
            bufferH16$ u_b3 (.out(stq_info_3_data_data[gi_d]), .in(stq_info_3_data_data_raw[gi_d]));
        end
    endgenerate

endmodule


// ============================================================================
// COMMENTED OUT: Legacy SystemVerilog implementation. Restore by uncommenting
// and commenting the structural module above; also flip its WB.sv
// instantiation back to the struct-based one.
// ============================================================================
//
// import core_common_pkg::*;
// import WriteBack_pkg::*;
// import common_pkg::*;
// import core_stage_latches_pkg::*;
//
// module ST_Q_logic(
//     input bool wb_valid,
//     input p_address_t st_paddr_0,
//     input p_address_t st_paddr_1,
//     input byte_t res_buf[CACHE_LINES_SIZE_B * 2],
//     input uint16_t bit_vect_0,
//     input uint16_t bit_vect_1,
//     input bool ST_OP,
//     input bool ST_XCL,
//     input bool MIO,
//     input bool write_success[NUM_WB_ST_QS],
//
//     output st_q_inputs_t stq_info[NUM_WB_ST_QS]
// );
//
//     logic [$clog2(ST_Q_DEPTH)-1: 0] low_bank_num;
//     logic [$clog2(ST_Q_DEPTH)-1: 0] high_bank_num;
//
//     byte_t st_data_low_bank[CACHE_LINES_SIZE_B];
//     byte_t st_data_high_bank[CACHE_LINES_SIZE_B];
//
//     always_comb begin
//         for(int i = 0 ; i < CACHE_LINES_SIZE_B; i++)begin
//             st_data_low_bank[i] = res_buf[i];
//             st_data_high_bank[i] = res_buf[i+CACHE_LINES_SIZE_B];
//         end
//     end
//
//     assign low_bank_num = st_paddr_0[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
//                                       $clog2(CACHE_LINES_SIZE_B)];
//
//     assign high_bank_num = st_paddr_1[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
//                                       $clog2(CACHE_LINES_SIZE_B)];
//
//     st_q_entry_t entry0;
//     st_q_entry_t entry1;
//
//     assign entry0 = '{
//                 valid : (ST_OP & ~MIO & wb_valid),
//                 address : st_paddr_0,
//                 bit_vec: bit_vect_0,
//                 data : st_data_low_bank
//             };
//
//     assign  entry1 = '{
//                 valid: (ST_OP & ST_XCL & ~MIO & wb_valid),
//                 address: st_paddr_1,
//                 bit_vec: bit_vect_1,
//                 data: st_data_high_bank
//             };
//
//     always_comb begin
//         for(int i = 0; i < NUM_WB_ST_QS; i++)begin
//             stq_info[i] = '{default : '0};
//             stq_info[i].pop = write_success[i];
//         end
//
//         if (entry0.valid) begin
//             stq_info[low_bank_num].push = 1'b1;
//             stq_info[low_bank_num].data = entry0;
//         end
//
//         if (entry1.valid) begin
//             stq_info[high_bank_num].push = 1'b1;
//             stq_info[high_bank_num].data = entry1;
//         end
//     end
//
//
//     always_comb begin
//         if (entry0.valid && entry1.valid && (low_bank_num == high_bank_num) & ST_XCL) begin
//             $error("STQ_Logic: Bank collision - XCL store with both entries mapping to same bank %0d",
//                    low_bank_num);
//         end
//     end
//
// endmodule
