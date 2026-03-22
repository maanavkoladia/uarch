import core_stage_latches_pkg::*;
import common_pkg::*;
import core_common_pkg::*;
import WriteBack_pkg::*;

module reg_wb_logic(
    input wb_latches_t reg_info,
    input bool stall_flop,
    output reg_wb_logic_outputs_t outs
);


//honestly I thought there would be more to this... maybe there is
always_comb begin
    outs = '{
        dr0_data : reg_info.dr_data,
        dr0_id : reg_info.dr_id,
        dr0_we : reg_info.cs.WB_DR & ~stall_flop & reg_info.valid,

        dr1_data : reg_info.sr_data,
        dr1_id : reg_info.sr_id,
        dr1_we : reg_info.cs.WB_SR & ~stall_flop & reg_info.valid
    };
end

endmodule
