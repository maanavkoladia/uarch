//this decode stall sthit needs to be resolved, its probably not needed

module IDM_Invalidate_Logic (
    input wire clk,
    input wire rst,

    input address_t eip,
    input bool flush,
    input bool exp_pipeclear,
    input bool decode_stall,
    input idm_outputs_t idm_meta,

    output idm_invalidate_logic_output_t out_invalidates
);

    import common_pkg::*;
    import Fetch_pkg::*;

    address_t prev_eip;

    //shoudl be bits [5:4]

    logic [$clog2(NUM_IDM_SLOTS)-1:0] eip_slot_num, prev_eip_slot_num;
    assign eip_slot_num = eip[$clog2(
        NUM_IDM_SLOTS
    )+$clog2(
        CACHE_LINES_SIZE_B
    )-1:$clog2(
        CACHE_LINES_SIZE_B
    )];
    assign prev_eip_slot_num = prev_eip[$clog2(
        NUM_IDM_SLOTS
    )+$clog2(
        CACHE_LINES_SIZE_B
    )-1:$clog2(
        CACHE_LINES_SIZE_B
    )];

    // -------------------------
    // Combinational logic
    // -------------------------
    always_comb begin
        out_invalidates = '{default: '0};

        // Global flushes
        if (flush || exp_pipeclear) begin
            out_invalidates = '{default: '1};
 
        end else begin

            // Early exit if current slot invalid
            if (!idm_meta.idm_slots[eip_slot_num].valid || decode_stall) begin
                // do nothing (all zero)
            end else begin
                bool slot_in_use_changed;
                bool will_leave_for_br;

                slot_in_use_changed = (eip_slot_num != prev_eip_slot_num);

                will_leave_for_br =
                    idm_meta.idm_slots[eip_slot_num].br_valid &&
                    (idm_meta.idm_slots[eip_slot_num].br_eip == eip);

                // Case 1: both true "we messed up"
                if (slot_in_use_changed && will_leave_for_br) begin
                    // You didn't define behavior.
                    // For now, invalidate everything.
                    out_invalidates = '{default: '1};
                end  // Case 2: slot changed only
                else if (slot_in_use_changed) begin
                    out_invalidates.invalidate[prev_eip_slot_num] = 1;
                end  // Case 3: leaving for branch
                else if (will_leave_for_br) begin

                    //should be a 2 bit wire
                    logic [$clog2(NUM_IDM_SLOTS) - 1 : 0] next_slot;
                    //shoudl wrap around naurlly ie mod not needed
                    next_slot = (eip_slot_num + 1);

                    if (idm_meta.idm_slots[next_slot].valid &&
                        idm_meta.idm_slots[eip_slot_num].br_xcl) begin

                        out_invalidates.invalidate[eip_slot_num] = 1;
                        out_invalidates.invalidate[next_slot]    = 1;

                    end
                    else if (!idm_meta.idm_slots[next_slot].valid &&
                             idm_meta.idm_slots[eip_slot_num].br_xcl) begin

                        // explicitly zero (already zero from default)
                        out_invalidates.invalidate[eip_slot_num] = 0;
                        out_invalidates.invalidate[next_slot]    = 0;

                    end else begin
                        out_invalidates.invalidate[eip_slot_num] = 1;
                    end
                end
            end
        end
    end

    // -------------------------
    // Track previous eip
    // -------------------------
    always_ff @(posedge clk) begin
        if (rst) prev_eip <= '0;
        else prev_eip <= eip;
    end

endmodule
