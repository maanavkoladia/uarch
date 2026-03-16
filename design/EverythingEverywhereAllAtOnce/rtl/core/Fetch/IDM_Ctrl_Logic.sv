import Fetch_pkg::*;
import core_common_pkg::icache_output_t;

module IDM_Ctrl_Logic (
    input address_t spc,
    input idm_outputs_t idm,
    input idm_invalidate_logic_ouput_t invalidate_logic_out,
    input btb_output_t btb_out,
    input predictor_output_t pred_out,
    input icache_output_t icache_out, //data is for hit miss. 
    input byte_t data_in[CACHE_LINES_SIZE],
    output idm_ctrl_logic_output_t out
);

    /*
    we can probably remove the idm sending data to the controller and manage
    it all thru the invalidation logic... keeping it the same for now

    3/16: need to add exp/int integration!
    */

    localparam int OFFSET_BITS = $clog2(CACHE_LINES_SIZE);
    localparam int SLOT_BITS = $clog2(num_slots);

    logic [SLOT_BITS-1:0] slot_num;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];

    always_comb begin
        out = '0;

        for (int i = 0; i < num_slots; i++) begin
            if (invalid_logic_out.invalidate[i] || !idm.slot_info_list[i].valid) begin
                //always load bc if miss, set slot to invalid, else load meta
                //and data
                out.idm_input.req[i].ld_meta_data = 1;

                //if hit and slot num same, load meta
                if ((i == slot_num) && icache_out.hit) begin

                    out.idm_input.req[i].valid = 1;

                    // BTB hit and pred taken
                    if (btb_out.hit && pred_out.taken) begin
                        out.idm_input.req[i].br_valid  = 1;
                        out.idm_input.req[i].br_eip    = btb_out.br_eip;
                        out.idm_input.req[i].br_target = btb_out.br_target;
                        out.idm_input.req[i].br_xcl    = btb_out.XCL;
                    end else begin
                        out.idm_input.req[i].br_valid = 0;
                    end

                    // Data
                    out.idm_input.req[i].ld_data = 1;
                    out.idm_input.req[i].data    = data_in;

                    out.push_success = 1;

                end else begin
                    out.idm_input.req[i].valid = 0;
                end
            end
        end
    end

endmodule
