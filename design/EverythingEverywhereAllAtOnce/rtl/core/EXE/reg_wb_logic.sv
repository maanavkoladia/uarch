import core_stage_latches_pkg::*;
import common_pkg::*;
import core_common_pkg::*;
import WriteBack_pkg::*;
import reg_ids_pkg::*;

module reg_wb_logic(
    input uint64_t next_dr_data,
    input reg_ids_e dr_id,
    input bool WB_DR,
    input uint64_t next_EAX,
    input uint64_t next_sr_data,
    input reg_ids_e sr_id,
    input bool WB_EAX,
    input bool WB_SR,
    input bool valid,
    input bool stall_flop,
    output reg_ids_e dr0_id_o, //dr in wb_latches
    output bool dr0_we_o,
    output uint64_t dr0_data_o,
    output reg_ids_e dr1_id_o,  //corresponds to writing to source reg
    output bool dr1_we_o,
    output uint64_t dr1_data_o
);



    assign dr0_data_o = next_dr_data;
    assign dr0_id_o = dr_id;
    assign dr0_we_o = WB_DR & ~stall_flop & valid;
    assign dr1_data_o = WB_EAX ? next_EAX : next_sr_data;
    assign dr1_id_o = WB_EAX ? EAX : sr_id;
    assign dr1_we_o = (WB_SR || WB_EAX) & ~stall_flop & valid;


endmodule
