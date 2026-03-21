import Fetch_pkg::*;
import core_common_pkg::*;
import interconnect_pkg::icache_2_core_t;

module IDM_Ctrl_Logic (
    input rst,
    input exp_mode,
    input int_mode,
    input exp_pipe_clear,
    input address_t spc,
    input idm_outputs_t idm_i,
    input idm_invalidate_logic_output_t invalidate_logic_outs_i,
    input btb_output_t btb_out_i,
    input predictor_output_t pred_out_i,
    input icache_2_core_t icache_out_i, //data is for hit miss.
    input spc_sel_logic_output_t spc_sel_logic_out_i, //just for flush reg
    input byte_t data_in[CACHE_LINES_SIZE_B],
    output idm_ctrl_logic_output_t out
);

    /*
    we can probably remove the idm sending data to the controller and manage
    it all thru the invalidation logic... keeping it the same for now

    3/16: need to add exp/int integration!
    */

    localparam int OFFSET_BITS = $clog2(CACHE_LINES_SIZE_B);
    localparam int SLOT_BITS = $clog2(NUM_IDM_SLOTS);

    logic [SLOT_BITS-1:0] slot_num;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];

    always_comb begin
        out = '{default: '0};

        for (int i = 0; i < NUM_IDM_SLOTS; i++) begin
            if (invalidate_logic_outs_i.invalidate[i] || !idm_i.idm_slots[i].valid) begin
                //always load bc if miss, set slot to invalid, else load meta
                //and data
                out.idm_input.req[i].ld_meta_data = 1;

                //if hit and we are opertating on the slot where the data will go
                if ((i == slot_num) && (icache_out_i.hit | exp_mode | int_mode) & ~invalidate_logic_outs_i.no_writes) begin //forgot if exp_mode or pipeclear actually flushes things

                    out.idm_input.req[i].valid = 1;

                    // BTB hit and pred taken
                    if(btb_out_i.hit && pred_out_i.taken & ~spc_sel_logic_out_i.flush_reg)begin
                        out.idm_input.req[i].br_valid  = 1;
                        out.idm_input.req[i].br_eip    = btb_out_i.br_eip;
                        out.idm_input.req[i].br_target = btb_out_i.br_target;
                        out.idm_input.req[i].br_xcl    = btb_out_i.XCL;
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
