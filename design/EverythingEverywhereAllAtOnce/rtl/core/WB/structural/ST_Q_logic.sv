// ============================================================================
// ACTIVE: Legacy SystemVerilog implementation.
// Reverted to legacy after the multi-module structural port broke regression.
// To re-enable the structural version: comment this module out and uncomment
// the structural one at the bottom of this file (and rewire its instantiation
// in WB.sv to flat ports).
// ============================================================================
import core_common_pkg::*;
import WriteBack_pkg::*;
import common_pkg::*;
import core_stage_latches_pkg::*;


module ST_Q_logic(
    input bool wb_valid,
    input p_address_t st_paddr_0,
    input p_address_t st_paddr_1,
    input byte_t res_buf[CACHE_LINES_SIZE_B * 2],
    input uint16_t bit_vect_0,
    input uint16_t bit_vect_1,
    input bool ST_OP,
    input bool ST_XCL,
    input bool MIO,
    input bool write_success[NUM_WB_ST_QS],

    output st_q_inputs_t stq_info[NUM_WB_ST_QS]
);



  //STQ stuff
            //1:0
    logic [$clog2(ST_Q_DEPTH)-1: 0] low_bank_num;
    logic [$clog2(ST_Q_DEPTH)-1: 0] high_bank_num;

    byte_t st_data_low_bank[CACHE_LINES_SIZE_B];
    byte_t st_data_high_bank[CACHE_LINES_SIZE_B];

    always_comb begin
        for(int i = 0 ; i < CACHE_LINES_SIZE_B; i++)begin
            st_data_low_bank[i] = res_buf[i];
            st_data_high_bank[i] = res_buf[i+CACHE_LINES_SIZE_B];
        end
    end

                                        //5:4
    assign low_bank_num = st_paddr_0[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
                                      $clog2(CACHE_LINES_SIZE_B)];

    assign high_bank_num = st_paddr_1[$clog2(ST_Q_DEPTH)-1 + $clog2(CACHE_LINES_SIZE_B):
                                      $clog2(CACHE_LINES_SIZE_B)];


    st_q_entry_t entry0;
    st_q_entry_t entry1;

    assign entry0 = '{
                valid : (ST_OP & ~MIO & wb_valid),
                address : st_paddr_0,
                bit_vec: bit_vect_0,
                data : st_data_low_bank
            };

    assign  entry1 = '{
                valid: (ST_OP & ST_XCL & ~MIO & wb_valid),
                address: st_paddr_1,
                bit_vec: bit_vect_1,
                data: st_data_high_bank
            };

    always_comb begin
        // Initialize all queues
        for(int i = 0; i < NUM_WB_ST_QS; i++)begin
            stq_info[i] = '{default : '0};
            stq_info[i].pop = write_success[i];  // Always propagate pop signals
        end

        // Push entry0 to its bank
        if (entry0.valid) begin
            stq_info[low_bank_num].push = 1'b1;
            stq_info[low_bank_num].data = entry0;
        end

        if (entry1.valid) begin
            stq_info[high_bank_num].push = 1'b1;
            stq_info[high_bank_num].data = entry1;
        end
    end


    //Claude
    // Immediate assertion: Check for bank collision on XCL stores
    // If both entries are valid and map to same bank, you'll lose entry0
    always_comb begin
        if (entry0.valid && entry1.valid && (low_bank_num == high_bank_num) & ST_XCL) begin
            $error("STQ_Logic: Bank collision - XCL store with both entries mapping to same bank %0d",
                   low_bank_num);
        end
    end

endmodule


// ============================================================================
// COMMENTED OUT: Pure structural port. Restore by uncommenting and commenting
// the legacy module above; also flip its WB.sv instantiation back to flat ports.
// ============================================================================
//
// // Pure structural port of ST_Q_logic.
// // Combinational decoder: takes one or two store entries (entry0 always, entry1
// // only when ST_XCL=1) and routes each to the correct one of NUM_WB_ST_QS=4
// // store queues based on physical address bits [5:4]. Pop is always wired
// // straight through from write_success_<i>.
// //
// // Bank-collision arbitration matches the legacy SV: when entry0 and entry1
// // both target the same bank, entry1 wins (legacy 'if (entry1.valid)' overwrote
// // the entry0 assignment). This is a design error case (the legacy SV $error
// // fires); priority here is don't-care, but kept faithful for parity.
//
// module ST_Q_logic (
//     input  wire         wb_valid,
//     input  wire [14:0]  st_paddr_0,
//     input  wire [14:0]  st_paddr_1,
//     input  wire [255:0] res_buf,
//     input  wire [15:0]  bit_vect_0,
//     input  wire [15:0]  bit_vect_1,
//     input  wire         ST_OP,
//     input  wire         ST_XCL,
//     input  wire         MIO,
//     input  wire         write_success_0,
//     input  wire         write_success_1,
//     input  wire         write_success_2,
//     input  wire         write_success_3,
//
//     // queue 0
//     output wire         stq_info_0_push,
//     output wire         stq_info_0_pop,
//     output wire         stq_info_0_data_valid,
//     output wire [14:0]  stq_info_0_data_address,
//     output wire [15:0]  stq_info_0_data_bit_vec,
//     output wire [127:0] stq_info_0_data_data,
//     // queue 1
//     output wire         stq_info_1_push,
//     output wire         stq_info_1_pop,
//     output wire         stq_info_1_data_valid,
//     output wire [14:0]  stq_info_1_data_address,
//     output wire [15:0]  stq_info_1_data_bit_vec,
//     output wire [127:0] stq_info_1_data_data,
//     // queue 2
//     output wire         stq_info_2_push,
//     output wire         stq_info_2_pop,
//     output wire         stq_info_2_data_valid,
//     output wire [14:0]  stq_info_2_data_address,
//     output wire [15:0]  stq_info_2_data_bit_vec,
//     output wire [127:0] stq_info_2_data_data,
//     // queue 3
//     output wire         stq_info_3_push,
//     output wire         stq_info_3_pop,
//     output wire         stq_info_3_data_valid,
//     output wire [14:0]  stq_info_3_data_address,
//     output wire [15:0]  stq_info_3_data_bit_vec,
//     output wire [127:0] stq_info_3_data_data
// );
//
//     wire not_mio_w;
//     `INV_N(u_inv_mio, 1, MIO, not_mio_w)
//
//     wire entry0_valid_w;
//     wire entry1_valid_w;
//     `AND_3(u_entry0_valid_and, 1, entry0_valid_w, ST_OP, not_mio_w, wb_valid)
//     `AND_4(u_entry1_valid_and, 1, entry1_valid_w, ST_OP, ST_XCL, not_mio_w, wb_valid)
//
//     wire [1:0] low_bank_num_w;
//     wire [1:0] high_bank_num_w;
//     assign low_bank_num_w  = st_paddr_0[5:4];
//     assign high_bank_num_w = st_paddr_1[5:4];
//
//     wire [3:0] low_bank_dec_w;
//     wire [3:0] high_bank_dec_w;
//     `DECODER_N(u_low_bank_dec,  2, low_bank_num_w,  low_bank_dec_w)
//     `DECODER_N(u_high_bank_dec, 2, high_bank_num_w, high_bank_dec_w)
//
//     wire entry0_to_0_w, entry0_to_1_w, entry0_to_2_w, entry0_to_3_w;
//     wire entry1_to_0_w, entry1_to_1_w, entry1_to_2_w, entry1_to_3_w;
//     `AND_2(u_e0_to_0, 1, entry0_to_0_w, entry0_valid_w, low_bank_dec_w[0])
//     `AND_2(u_e0_to_1, 1, entry0_to_1_w, entry0_valid_w, low_bank_dec_w[1])
//     `AND_2(u_e0_to_2, 1, entry0_to_2_w, entry0_valid_w, low_bank_dec_w[2])
//     `AND_2(u_e0_to_3, 1, entry0_to_3_w, entry0_valid_w, low_bank_dec_w[3])
//     `AND_2(u_e1_to_0, 1, entry1_to_0_w, entry1_valid_w, high_bank_dec_w[0])
//     `AND_2(u_e1_to_1, 1, entry1_to_1_w, entry1_valid_w, high_bank_dec_w[1])
//     `AND_2(u_e1_to_2, 1, entry1_to_2_w, entry1_valid_w, high_bank_dec_w[2])
//     `AND_2(u_e1_to_3, 1, entry1_to_3_w, entry1_valid_w, high_bank_dec_w[3])
//
//     `OR_2(u_push_0, 1, stq_info_0_push, entry0_to_0_w, entry1_to_0_w)
//     `OR_2(u_push_1, 1, stq_info_1_push, entry0_to_1_w, entry1_to_1_w)
//     `OR_2(u_push_2, 1, stq_info_2_push, entry0_to_2_w, entry1_to_2_w)
//     `OR_2(u_push_3, 1, stq_info_3_push, entry0_to_3_w, entry1_to_3_w)
//
//     assign stq_info_0_data_valid = stq_info_0_push;
//     assign stq_info_1_data_valid = stq_info_1_push;
//     assign stq_info_2_data_valid = stq_info_2_push;
//     assign stq_info_3_data_valid = stq_info_3_push;
//
//     assign stq_info_0_pop = write_success_0;
//     assign stq_info_1_pop = write_success_1;
//     assign stq_info_2_pop = write_success_2;
//     assign stq_info_3_pop = write_success_3;
//
//     wire [14:0]  entry0_address_w = st_paddr_0;
//     wire [14:0]  entry1_address_w = st_paddr_1;
//     wire [15:0]  entry0_bit_vec_w = bit_vect_0;
//     wire [15:0]  entry1_bit_vec_w = bit_vect_1;
//     wire [127:0] entry0_data_w    = res_buf[127:0];
//     wire [127:0] entry1_data_w    = res_buf[255:128];
//
//     // ---- queue 0 ----
//     wire [14:0]  tmp_addr_0_w;
//     wire [15:0]  tmp_bv_0_w;
//     wire [127:0] tmp_data_0_w;
//     `MUX_2(u_tmp_addr_0, 15, tmp_addr_0_w, 15'd0,        entry0_address_w, entry0_to_0_w)
//     `MUX_2(u_addr_0,     15, stq_info_0_data_address, tmp_addr_0_w, entry1_address_w, entry1_to_0_w)
//     `MUX_2(u_tmp_bv_0,   16, tmp_bv_0_w,   16'd0,        entry0_bit_vec_w, entry0_to_0_w)
//     `MUX_2(u_bv_0,       16, stq_info_0_data_bit_vec, tmp_bv_0_w,   entry1_bit_vec_w, entry1_to_0_w)
//     `MUX_2(u_tmp_data_0, 128, tmp_data_0_w, 128'd0,       entry0_data_w,    entry0_to_0_w)
//     `MUX_2(u_data_0,     128, stq_info_0_data_data, tmp_data_0_w, entry1_data_w,    entry1_to_0_w)
//
//     // ---- queue 1 ----
//     wire [14:0]  tmp_addr_1_w;
//     wire [15:0]  tmp_bv_1_w;
//     wire [127:0] tmp_data_1_w;
//     `MUX_2(u_tmp_addr_1, 15, tmp_addr_1_w, 15'd0,        entry0_address_w, entry0_to_1_w)
//     `MUX_2(u_addr_1,     15, stq_info_1_data_address, tmp_addr_1_w, entry1_address_w, entry1_to_1_w)
//     `MUX_2(u_tmp_bv_1,   16, tmp_bv_1_w,   16'd0,        entry0_bit_vec_w, entry0_to_1_w)
//     `MUX_2(u_bv_1,       16, stq_info_1_data_bit_vec, tmp_bv_1_w,   entry1_bit_vec_w, entry1_to_1_w)
//     `MUX_2(u_tmp_data_1, 128, tmp_data_1_w, 128'd0,       entry0_data_w,    entry0_to_1_w)
//     `MUX_2(u_data_1,     128, stq_info_1_data_data, tmp_data_1_w, entry1_data_w,    entry1_to_1_w)
//
//     // ---- queue 2 ----
//     wire [14:0]  tmp_addr_2_w;
//     wire [15:0]  tmp_bv_2_w;
//     wire [127:0] tmp_data_2_w;
//     `MUX_2(u_tmp_addr_2, 15, tmp_addr_2_w, 15'd0,        entry0_address_w, entry0_to_2_w)
//     `MUX_2(u_addr_2,     15, stq_info_2_data_address, tmp_addr_2_w, entry1_address_w, entry1_to_2_w)
//     `MUX_2(u_tmp_bv_2,   16, tmp_bv_2_w,   16'd0,        entry0_bit_vec_w, entry0_to_2_w)
//     `MUX_2(u_bv_2,       16, stq_info_2_data_bit_vec, tmp_bv_2_w,   entry1_bit_vec_w, entry1_to_2_w)
//     `MUX_2(u_tmp_data_2, 128, tmp_data_2_w, 128'd0,       entry0_data_w,    entry0_to_2_w)
//     `MUX_2(u_data_2,     128, stq_info_2_data_data, tmp_data_2_w, entry1_data_w,    entry1_to_2_w)
//
//     // ---- queue 3 ----
//     wire [14:0]  tmp_addr_3_w;
//     wire [15:0]  tmp_bv_3_w;
//     wire [127:0] tmp_data_3_w;
//     `MUX_2(u_tmp_addr_3, 15, tmp_addr_3_w, 15'd0,        entry0_address_w, entry0_to_3_w)
//     `MUX_2(u_addr_3,     15, stq_info_3_data_address, tmp_addr_3_w, entry1_address_w, entry1_to_3_w)
//     `MUX_2(u_tmp_bv_3,   16, tmp_bv_3_w,   16'd0,        entry0_bit_vec_w, entry0_to_3_w)
//     `MUX_2(u_bv_3,       16, stq_info_3_data_bit_vec, tmp_bv_3_w,   entry1_bit_vec_w, entry1_to_3_w)
//     `MUX_2(u_tmp_data_3, 128, tmp_data_3_w, 128'd0,       entry0_data_w,    entry0_to_3_w)
//     `MUX_2(u_data_3,     128, stq_info_3_data_data, tmp_data_3_w, entry1_data_w,    entry1_to_3_w)
//
// endmodule
