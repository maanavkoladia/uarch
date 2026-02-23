module Q_Ctrl_Logic (
    input address_t spc,
    input instruction_q_2_fetch_t q,
    input q_invalidate_logic_ouput_t invalid_logic_out,
    input btb_output_t btb_out,
    input predictor_output_t pred_out,
    input icache_output_t icache_out,

    output q_ctrl_logic_output_t out
);

    import Fetch_pkg::*;

    localparam int OFFSET_BITS = $clog2(CACHE_LINES_SIZE);
    localparam int SLOT_BITS = $clog2(num_slots);

    logic [SLOT_BITS-1:0] slot_num;

    assign slot_num = spc[OFFSET_BITS+SLOT_BITS-1 : OFFSET_BITS];

    always_comb begin
        out = '0;

        for (int i = 0; i < num_slots; i++) begin
            //if its currently invliad wor will be invalid from the invl ligoc
            //blkc, do work
            if (invalid_logic_out.invalidate[i] || !q.slot_info_list[i].valid) begin
                //always load bc if miss, set slot to invalid, else load meta
                //and data
                out.q_input.req[i].ld_meta_data = 1;

                //if hit and slot num same, load meta
                if ((i == slot_num) && icache_out.h_m) begin

                    out.q_input.req[i].valid = 1;

                    // BTB hit and pred taken
                    if (btb_out.hit && pred_out.taken) begin
                        out.q_input.req[i].br_valid  = 1;
                        out.q_input.req[i].br_eip    = btb_out.br_eip;
                        out.q_input.req[i].br_target = btb_out.br_target;
                        out.q_input.req[i].br_xcl    = btb_out.XCL;
                    end else begin
                        out.q_input.req[i].br_valid = 0;
                    end

                    // Data
                    out.q_input.req[i].ld_data = 1;
                    out.q_input.req[i].data    = icache_out.data;

                    out.push_success = 1;

                end else begin
                    out.q_input.req[i].valid = 0;
                end
            end
        end
    end

endmodule
