// ============================================================================
// ACTIVE: Legacy SystemVerilog implementation.
// Reverted to legacy after the multi-module structural port broke regression.
// To re-enable the structural version: comment this module out and uncomment
// the structural one at the bottom of this file (and rewire its instantiation
// in WB.sv to flat ports).
// ============================================================================
module ST_Q_MIO_logic(
    input bool wb_valid,
    input p_address_t st_paddr_0_mio,
    input byte_t res_buf[CACHE_LINES_SIZE_B * 2],
    input bool ST_OP,
    input bool MIO,
    input bool write_success_mio,

    output mio_inputs_t mio_q_input_o
);


    //we mio queue will generate
    assign mio_q_input_o = '{
        data: '{
            valid: wb_valid & MIO & ST_OP,
            address: st_paddr_0_mio,
            data: res_buf[0 +: CACHE_LINES_SIZE_B]
        },
        push: wb_valid & MIO & ST_OP, //same as data valid
        pop: write_success_mio
    };



endmodule


// ============================================================================
// COMMENTED OUT: Pure structural port. Restore by uncommenting and commenting
// the legacy module above; also flip its WB.sv instantiation back to flat ports.
// ============================================================================
//
// // Pure structural port of ST_Q_MIO_logic.
// // Generates the mio_inputs_t-shaped signals (unrolled into flat ports) that
// // drive MIO_Q. Only valid when wb_valid & MIO & ST_OP.
// //
// // Struct unrolling map (mio_inputs_t mio_q_input_o):
// //   mio_q_input_o.data.valid    -> mio_q_input_o_data_valid       (1)
// //   mio_q_input_o.data.address  -> mio_q_input_o_data_address     (15)
// //   mio_q_input_o.data.data     -> mio_q_input_o_data_data        (128)
// //   mio_q_input_o.push          -> mio_q_input_o_push             (1)
// //   mio_q_input_o.pop           -> mio_q_input_o_pop              (1)
//
// module ST_Q_MIO_logic (
//     input  wire         wb_valid,
//     input  wire [14:0]  st_paddr_0_mio,
//     input  wire [255:0] res_buf,                // 32 bytes; only low 16 used
//     input  wire         ST_OP,
//     input  wire         MIO,
//     input  wire         write_success_mio,
//
//     output wire         mio_q_input_o_data_valid,
//     output wire [14:0]  mio_q_input_o_data_address,
//     output wire [127:0] mio_q_input_o_data_data,
//     output wire         mio_q_input_o_push,
//     output wire         mio_q_input_o_pop
// );
//
//     // valid = wb_valid & MIO & ST_OP   (also drives push)
//     wire mio_valid_w;
//     `AND_3(u_mio_valid_and, 1, mio_valid_w, wb_valid, MIO, ST_OP)
//
//     assign mio_q_input_o_data_valid   = mio_valid_w;
//     assign mio_q_input_o_push         = mio_valid_w;
//
//     // pass-throughs
//     assign mio_q_input_o_data_address = st_paddr_0_mio;
//     assign mio_q_input_o_data_data    = res_buf[127:0];
//     assign mio_q_input_o_pop          = write_success_mio;
//
// endmodule
