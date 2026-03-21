//this decode stall sthit needs to be resolved, its probably not needed

module IDM_Invalidate_Logic (
    input wire clk,
    input wire rst,
    input address_t eip,
    input bool flush,
    input bool exp_pipeclear,
    input bool int_pipe_clear,
    input bool decode_stall,
    input idm_outputs_t idm_meta,

    output idm_invalidate_logic_output_t out_invalidates
);

    import common_pkg::*;
    import Fetch_pkg::*;

    address_t prev_eip, prev_eip_next;
    //shoudl be bits [5:4]

    logic [$clog2(NUM_IDM_SLOTS)-1:0] eip_slot_num, prev_eip_slot_num;
    assign eip_slot_num = eip[$clog2(NUM_IDM_SLOTS)+$clog2(CACHE_LINES_SIZE_B)-1
                            :$clog2(CACHE_LINES_SIZE_B)];

    assign prev_eip_slot_num = prev_eip[$clog2(NUM_IDM_SLOTS)+$clog2(CACHE_LINES_SIZE_B)-1
                                :$clog2(CACHE_LINES_SIZE_B)];

    // -------------------------
    // Combinational logic
    // -------------------------
    bool will_leave_for_br;
    bool slot_in_use_changed;
    
    assign will_leave_for_br =  idm_meta.idm_slots[eip_slot_num].br_valid &&
                                (idm_meta.idm_slots[eip_slot_num].br_eip == eip);

            //we have reached the eip of a branch
    always_comb begin
        out_invalidates = '{default: '0};
        prev_eip_next = eip;

        // Global flushes
        if (flush || exp_pipeclear || rst || int_pipe_clear) begin
            out_invalidates = '{default: '1};
            out_invalidates.no_writes = 1;
        end
        else begin
            slot_in_use_changed = (eip_slot_num != prev_eip_slot_num);
            //we have move forward to the next cache line

            // Only perform invalidations if conditions warrant it
            if(slot_in_use_changed)begin
                out_invalidates.invalidate[prev_eip_slot_num] = 1;
            end
            if(will_leave_for_br)begin
                    //should be a 2 bit wire
                    logic [$clog2(NUM_IDM_SLOTS) - 1 : 0] next_slot;
                    //shoudl wrap around naurlly ie mod not needed
                    next_slot = (eip_slot_num + 1);

                    if (idm_meta.idm_slots[next_slot].valid &&
                        idm_meta.idm_slots[eip_slot_num].br_xcl) begin
                        //we are going to a new $ we can invalidate both of these
                        out_invalidates.invalidate[eip_slot_num] = 1;
                        out_invalidates.invalidate[next_slot]    = 1;
                        prev_eip_next = idm_meta.idm_slots[eip_slot_num].br_btb_target;

                    end
                    else if (~idm_meta.idm_slots[next_slot].valid &&
                            idm_meta.idm_slots[eip_slot_num].br_xcl) begin
                        assert (1'b0)
                                else $warning(
                                    "IDM inv: XCL case hit with next_slot invalid on br xcl, eip=0x%0h",
                                    eip
                                );
                            out_invalidates.invalidate[eip_slot_num] = 0;
                            out_invalidates.invalidate[next_slot]    = 0;
                    end
                    else begin
                        out_invalidates.invalidate[eip_slot_num] = 1;
                        prev_eip_next = idm_meta.idm_slots[eip_slot_num].br_btb_target;
                    end

                end
        end
    end

    // -------------------------
    // Track previous eip
    // -------------------------
    always_ff @(posedge clk) begin
        if (rst) prev_eip <= eip;
        else prev_eip <= prev_eip_next;
    end

endmodule


/*

we had this line saying we should do nothing if
we were currently waiting for a line to come oin or if decode was stalling
I am not sure why that was needed... or at least it has to be partially incorrect

suppose 
pre_eip was on slot 0 
and your new eip is on an invalid cache line on slot 1
we still have to invalidated the previous slot 
otherwise prev_eip will catch up and then we would never invalidate that line
else begin

            // Early exit if current slot invalid
            if (!idm_meta.idm_slots[eip_slot_num].valid || decode_stall) begin
                //if we are still operating on the same cache line or decode is stalling there is no reason to change the statue of the IDM
            end else begin
                bool slot_in_use_changed;
                bool will_leave_for_br;

                slot_in_use_changed = (eip_slot_num != prev_eip_slot_num);
                //we have move forward to the next cache line

                will_leave_for_br =
                    idm_meta.idm_slots[eip_slot_num].br_valid &&
                    (idm_meta.idm_slots[eip_slot_num].br_eip == eip);
                //we have reached the eip of a branch

                // Case 1: both true "we messed up" I Dont understand why this is the case...We were probably cooking and I forgot
                if (slot_in_use_changed && will_leave_for_br) begin //
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
                        //we are going to a new $ we can invalidate both of these
                        out_invalidates.invalidate[eip_slot_num] = 1;
                        out_invalidates.invalidate[next_slot]    = 1;

                    end
                    else if (~idm_meta.idm_slots[next_slot].valid &&
                             idm_meta.idm_slots[eip_slot_num].br_xcl) begin
                        /*we need the rest of the branch to be put into the idm before moving to the target
                        I dont think this case would be reached since decode would stall anyways
                        so we wouldnt change anything regardless
                        explicitly zero (already zero from default)
                        out_invalidates.invalidate[eip_slot_num] = 0;
                        out_invalidates.invalidate[next_slot]    = 0;

                    end else begin
                        out_invalidates.invalidate[eip_slot_num] = 1;
                        //regular branch. We can inavalidate the rest of the line.
                    end
                end
            end

*/
