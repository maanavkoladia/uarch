// ----------------------------------------------------------------
// data_size_vec_logic -- structural Verilog 2005 port.
//
// Reference: rtl/core/DC/data_size_vec_logic.sv
//
//   shift_sr_up   = dr_upper8 & ~sr_upper8 & ~wb_sr & ~wb_eax
//   shift_sr_down = ~dr_upper8 & sr_upper8 & ~wb_sr & ~wb_eax
//
//   data_size_vec_o[0] = ((data_size==0) & ~dr_upper8) | data_size[1] | data_size[0]
//   data_size_vec_o[1] = ((data_size==0) &  dr_upper8) | data_size[1] | data_size[0]
//   data_size_vec_o[2] = data_size[1]
//   data_size_vec_o[3] = data_size[1] & data_size[0]
//
//   sr_data_size_vec_o[*] is the same shape with sr_upper8 substituted
//   for dr_upper8.
//
// ST_OP and LD_OP are on the port list to match the .sv reference but
// the original body does not reference them, so they are unused here.
//
// Off-critical-path module -- straight AND/OR with shared inverters.
// ----------------------------------------------------------------
module data_size_vec_logic (
    input  wire [1:0] data_size,
    input  wire       dr_upper8,
    input  wire       sr_upper8,
    input  wire       ST_OP,
    input  wire       LD_OP,
    input  wire       wb_sr,
    input  wire       wb_eax,

    output wire       shift_sr_up,
    output wire       shift_sr_down,
    output wire [3:0] data_size_vec_o,
    output wire [3:0] sr_data_size_vec_o
);

    // ----------------------------------------------------------------
    // Shared inverted scalars
    // ----------------------------------------------------------------
    wire not_dr_upper8;
    wire not_sr_upper8;
    wire not_wb_sr;
    wire not_wb_eax;

    `INV_N(u_inv_dr_upper8, 1, dr_upper8, not_dr_upper8)
    `INV_N(u_inv_sr_upper8, 1, sr_upper8, not_sr_upper8)
    `INV_N(u_inv_wb_sr,     1, wb_sr,     not_wb_sr)
    `INV_N(u_inv_wb_eax,    1, wb_eax,    not_wb_eax)

    // ----------------------------------------------------------------
    // shift_sr_up   = dr_upper8 & ~sr_upper8 & ~wb_sr & ~wb_eax
    // shift_sr_down = ~dr_upper8 & sr_upper8 & ~wb_sr & ~wb_eax
    // ----------------------------------------------------------------
    `AND_4(u_shift_sr_up,   1, shift_sr_up,
           dr_upper8, not_sr_upper8, not_wb_sr, not_wb_eax)

    `AND_4(u_shift_sr_down, 1, shift_sr_down,
           not_dr_upper8, sr_upper8, not_wb_sr, not_wb_eax)

    // ----------------------------------------------------------------
    // data_size == 2'b00  ⟺  NOR(data_size[1], data_size[0])
    // ----------------------------------------------------------------
    wire ds_eq0;
    `NOR_2(u_ds_eq0, 1, ds_eq0, data_size[1], data_size[0])

    // ----------------------------------------------------------------
    // data_size_vec_o[0] = (ds==0 & ~dr_upper8) | data_size[1] | data_size[0]
    // ----------------------------------------------------------------
    wire dvec0_term;
    `AND_2(u_dvec0_term, 1, dvec0_term, ds_eq0, not_dr_upper8)
    `OR_3 (u_dvec0,      1, data_size_vec_o[0],
           dvec0_term, data_size[1], data_size[0])

    // ----------------------------------------------------------------
    // data_size_vec_o[1] = (ds==0 &  dr_upper8) | data_size[1] | data_size[0]
    // ----------------------------------------------------------------
    wire dvec1_term;
    `AND_2(u_dvec1_term, 1, dvec1_term, ds_eq0, dr_upper8)
    `OR_3 (u_dvec1,      1, data_size_vec_o[1],
           dvec1_term, data_size[1], data_size[0])

    // ----------------------------------------------------------------
    // data_size_vec_o[2] = data_size[1]                     (wire alias)
    // data_size_vec_o[3] = data_size[1] & data_size[0]
    // ----------------------------------------------------------------
    assign data_size_vec_o[2] = data_size[1];
    `AND_2(u_dvec3, 1, data_size_vec_o[3], data_size[1], data_size[0])

    // ----------------------------------------------------------------
    // sr_data_size_vec_o[*] -- same shape with sr_upper8 in place of dr_upper8
    // ----------------------------------------------------------------
    wire srvec0_term;
    `AND_2(u_srvec0_term, 1, srvec0_term, ds_eq0, not_sr_upper8)
    `OR_3 (u_srvec0,      1, sr_data_size_vec_o[0],
           srvec0_term, data_size[1], data_size[0])

    wire srvec1_term;
    `AND_2(u_srvec1_term, 1, srvec1_term, ds_eq0, sr_upper8)
    `OR_3 (u_srvec1,      1, sr_data_size_vec_o[1],
           srvec1_term, data_size[1], data_size[0])

    assign sr_data_size_vec_o[2] = data_size[1];
    `AND_2(u_srvec3, 1, sr_data_size_vec_o[3], data_size[1], data_size[0])

endmodule
