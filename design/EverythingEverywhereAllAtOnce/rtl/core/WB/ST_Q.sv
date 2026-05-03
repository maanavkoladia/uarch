import common_pkg::*;
import WriteBack_pkg::*;

module ST_Q (

    input wire clk,
    input wire rst,

    input st_q_inputs_t wb_in,

    output st_q_outputs_t outputs
);
    //head represents the front of the queue. Tail represents the back
    //heads points to the current value. Tail points to the next slot.



    logic [$clog2(ST_Q_DEPTH):0] head;
    logic [$clog2(ST_Q_DEPTH):0] tail;

    logic [$clog2(ST_Q_DEPTH)-1:0] head_ptr;
    logic [$clog2(ST_Q_DEPTH)-1:0] tail_ptr;

    assign head_ptr = head[$clog2(ST_Q_DEPTH)-1:0];
    assign tail_ptr = tail[$clog2(ST_Q_DEPTH)-1:0];

    bool q_full, q_empty;
    bool valid_push, valid_pop;


    //create the q
    st_q_entry_t q[ST_Q_DEPTH];

    // Extra bit method for full/empty...probably better for combinational logic in structural.
    assign q_full = (head[$clog2(ST_Q_DEPTH)] != tail[$clog2(ST_Q_DEPTH)]) && 
                    (head[$clog2(ST_Q_DEPTH)-1:0] == tail[$clog2(ST_Q_DEPTH)-1:0]);
    assign q_empty = (head == tail);


    assign valid_push = wb_in.push &  (~q_full | wb_in.pop);
    assign valid_pop =  wb_in.pop & (~q_empty);

    //outputs 
    always_comb begin
        outputs.full = q_full;
        outputs.empty = q_empty;
        outputs.head_address = q[head_ptr].address;
        outputs.bit_vec = q[head_ptr].bit_vec;
        outputs.data = q[head_ptr].data;
        outputs.push_fail = wb_in.push & (q_full & ~wb_in.pop);        
        //this is for the dep checks
        for(int i = 0;  i < ST_Q_DEPTH; i++)begin
            outputs.valid[i] = q[i].valid;
            outputs.address[i] = q[i].address;
        end

    end

    always_ff @(posedge clk) begin
        if (!rst) begin
            head <= 0;
            tail <= 0;
            for(int i = 0; i < ST_Q_DEPTH; i++)begin
                q[i] <= '{default : '0};
            end
        end 
        else begin
            // Push: write to tail and increment
            if(valid_push) begin
                q[tail_ptr] <= wb_in.data;  // wb_in.data is already st_q_entry_t 
                tail <= tail + 1;
            end
            if(valid_pop)begin
                q[head_ptr].valid <= 1'b0;
                head <= head + 1; 
            end 
        end
    end




    /*
    THIS IS STQ for combinational head update (not dcache arbitration pop signal)
   always_comb begin
        for (int i = 0; i < DCACHE_NUM_BLOCKS; i++) begin
            readyForNewReq[i] = (reqs_2_blocks_o[i].oe && block_hit_i[i] && !core_i.memStalling)
            || (reqs_2_blocks_o[i].we && block_hit_i[i])
            || block_idleness[i];
        end
    end
    Because of this statement. We latch in new data when we get a hit. This means that we need to start sending new data once we get the hit signal

    */

    /*
    Critical path is now cache arbhitration latches to hit signal in dcache to store queue back arbirtation back to latches.... that might be too much
    
    */
    // logic [$clog2(ST_Q_DEPTH):0] validEntries;
    // logic [$clog2(ST_Q_DEPTH)-1:0] head, next_head;
    // logic [$clog2(ST_Q_DEPTH)-1:0] tail, next_tail;

    // bool q_full, q_empty, next_q_full, next_q_empty;
    // bool valid_push, valid_pop;


    // //create the q
    // st_q_entry_t q[ST_Q_DEPTH];

    // logic [$clog2(ST_Q_DEPTH):0] next_validEntries;

    // assign q_full = (validEntries == ST_Q_DEPTH);
    // assign q_empty = (validEntries == 0);

    // assign next_q_empty = (next_validEntries == 0);
    // assign next_q_full = (next_validEntries == ST_Q_DEPTH);

    // assign valid_push = wb_in.push &  (~q_full | wb_in.pop);
    // assign valid_pop =  wb_in.pop & (~q_empty);

    // //assign outputs
    // always_comb begin
    //     outputs.full = next_q_full;
    //     outputs.empty = next_q_empty;
    //     outputs.head_address = q[next_head].address;
    //     outputs.bit_vec = q[next_head].bit_vec;
    //     outputs.data = q[next_head].data;
    //     outputs.push_fail = wb_in.push & (q_full & ~wb_in.pop);        
    //     //this is for the dep checks
    //     for(int i = 0;  i < ST_Q_DEPTH; i++)begin
    //         outputs.valid[i] = q[i].valid;
    //         outputs.address[i] = q[i].address;
    //     end

    // end

    // always_comb begin
    //     // Default assignments
    //     next_tail = tail;
    //     next_head = head;

    //     // Update valid entries counter (with guards)
    //     if(valid_push)begin
    //         next_tail = (tail + 1);
    //     end

    //     if(valid_pop)begin
    //         next_head = (head + 1); //I dont think I need to add wrap around;
    //     end

    //     case ({valid_push, valid_pop})
    //         2'b00: next_validEntries = validEntries;           // Neither
    //         2'b01: next_validEntries = validEntries - 1;       // Pop only
    //         2'b10: next_validEntries = validEntries + 1;       // Push only
    //         2'b11: next_validEntries = validEntries;           // Both (cancel out)
    //         default: next_validEntries = validEntries;
    //     endcase
        
    // end


    // //work to do, if push
    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         validEntries <= 0;
    //         head <= 0;
    //         tail <= 0;
    //         for(int i = 0; i < ST_Q_DEPTH; i++)begin
    //             q[i] <= '{default : '0};
    //         end
    //     end else begin
    //             // Update valid entries counter (with guards)
    //         if(valid_push) q[tail] <= wb_in.data;  // wb_in.data is already st_q_entry_t 
    //         if(valid_pop) q[head].valid <= 1'b0;
        
    //         tail <= next_tail;
    //         head <= next_head;
    //         validEntries <= next_validEntries;
    //     end
    // end



    // Assertion: Check for invalid pop from empty queue
    // If this fires, there's a logic flaw in the system
    // assert property (@(posedge clk) disable iff (rst)
    //     !(wb_in.pop & q_empty)
    // ) else $error("ST_Q: Invalid pop from cache - attempted to pop from empty queue at time %0t", $time);

    

endmodule
