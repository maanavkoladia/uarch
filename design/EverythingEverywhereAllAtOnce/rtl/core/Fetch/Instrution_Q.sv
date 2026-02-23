module Instruction_Q (
    input wire clk,
    input wire rst,

    input  instruction_q_input_t       inputs,
    output instruction_q_2_fetch_t     output_2_fetch,
    output instruction_q_2_predecode_t output_2_predecode
);

    import common_pkg::*;
    import Fetch_pkg::*;

    typedef struct {
        bool valid;
        bool br_valid;
        address_t br_eip;
        address_t br_target;
        bool br_xcl;
        byte_t data[CACHE_LINES_SIZE];

        // you may add internal-only metadata here later
        // e.g. age bits, debug tags, etc.
    } slot_t;

    typedef struct {slot_t slots[num_slots];} instr_q_t;

    instr_q_t q;

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
