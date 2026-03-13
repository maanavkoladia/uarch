import common_pkg::*;
import core_common_pkg::fetch_outputs_t;
import core_common_pkg::fetch_idm_ctrl_2_idm_t;
import core_common_pkg::idm_slot_req_t;
import IDM_pkg::*;

module IDM (
    input wire clk,
    input wire rst,

    //used for slot reqs, and exp_pipe_clear signal
    input  fetch_outputs_t fetch_outs_i,
    //basically feeds the state of the idm to fetch and decode
    output idm_outputs_t   idm_outs_o
);

    idm_t q;

    // --------------------------------
    // Combinational fanout to outputs
    // --------------------------------
    always_comb begin
        for (int i = 0; i < num_slots; i++) begin

            // ----- FETCH OUTPUT -----
            output_2_fetch.slot_info_list[i].valid         = q.slots[i].valid;
            output_2_fetch.slot_info_list[i].br_valid      = q.slots[i].br_valid;
            output_2_fetch.slot_info_list[i].br_eip        = q.slots[i].br_eip;
            output_2_fetch.slot_info_list[i].br_target     = q.slots[i].br_target;
            output_2_fetch.slot_info_list[i].br_xcl        = q.slots[i].br_xcl;
            output_2_fetch.slot_info_list[i].data          = q.slots[i].data;

            // ----- PREDECODE OUTPUT -----
            output_2_predecode.slot_info_list[i].valid     = q.slots[i].valid;
            output_2_predecode.slot_info_list[i].br_valid  = q.slots[i].br_valid;
            output_2_predecode.slot_info_list[i].br_eip    = q.slots[i].br_eip;
            output_2_predecode.slot_info_list[i].br_target = q.slots[i].br_target;
            output_2_predecode.slot_info_list[i].br_xcl    = q.slots[i].br_xcl;
            output_2_predecode.slot_info_list[i].data      = q.slots[i].data;
        end
    end

    // --------------------------------
    // Sequential state update
    // --------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < num_slots; i++) begin
                q.slots[i].valid     <= 0;
                q.slots[i].br_valid  <= 0;
                q.slots[i].br_eip    <= '0;
                q.slots[i].br_target <= '0;
                q.slots[i].br_xcl    <= 0;
                q.slots[i].data      <= '{default: '0};
            end
        end else begin
            for (int i = 0; i < num_slots; i++) begin
                instruction_slot_req_t curReq = inputs[i];
                if (curReq.ld_meta_data) begin
                    q.slots[i] <= '{
                        valid: curReq.valid,
                        br_valid: curReq.br_valid,
                        br_eip: curReq.br_eip,
                        br_target: curReq.br_target,
                        br_xcl: curReq.br_xcl
                    };
                end
                if (curReq.ld_data) begin
                    for (int j = 0; j < CACHE_LINES_SIZE; j++) begin
                        q.slots[j].data <= '{curReq.data[j]};
                    end
                end
            end
        end
    end

endmodule
