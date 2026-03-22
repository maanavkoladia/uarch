
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

    logic [$clog2(ST_Q_DEPTH):0] validEntries;
    logic [$clog2(ST_Q_DEPTH)-1:0] head;
    logic [$clog2(ST_Q_DEPTH)-1:0] tail;
    bool q_full, q_empty;
    bool valid_push;
    bool valid_pop;
    bool st_override;  // Flag indicating queue has been full

    //create the q
    st_q_entry_t q[ST_Q_DEPTH];
    assign q_full = validEntries == ST_Q_DEPTH;
    assign q_empty = validEntries == 0;

    //assign outputs
    always_comb begin
        outputs.full = q_full;
        outputs.empty = q_empty;
        outputs.head_address = q[head].address;
        outputs.bit_vec = q[head].bit_vec;
        outputs.data = q[head].data;
        outputs.push_fail = wb_in.push & (q_full & ~wb_in.pop);
        outputs.st_override = st_override;
        for(int i = 0;  i < ST_Q_DEPTH; i++)begin
            outputs.valid[i] = q[i].valid;
            outputs.address[i] = q[i].address;
        end
    end

    assign valid_push = wb_in.push &  (~q_full | wb_in.pop);
    assign valid_pop =  wb_in.pop & (~q_empty);


    //work to do, if push
    always_ff @(posedge clk) begin
        if (rst) begin
            validEntries <= 0;
            head <= 0;
            tail <= 0;
        end else begin
            if(valid_push)begin
                q[tail] <= wb_in.data;  // wb_in.data is already st_q_entry_t
                tail <= (tail + 1);
            end

            if(valid_pop)begin
                q[head].valid <= 1'b0;
                head <= (head + 1); //I dont think I need to add wrap around;
            end

            // Update valid entries counter (with guards)
            case ({valid_push, valid_pop})
                2'b00: validEntries <= validEntries;           // Neither
                2'b11: validEntries <= validEntries;           // Both (cancel out)
                2'b01: validEntries <= validEntries - 1;       // Pop only
                2'b10: validEntries <= validEntries + 1;       // Push only
                default: validEntries <= validEntries;
            endcase

        end
    end

    //full sets it
    //empty resets it
    always_ff @(posedge clk)begin
        if(rst) st_override <= 0;
        else begin
            if(q_full)st_override <= 1;
            if(q_empty) st_override <= 0;
        end
    end

    // Assertion: Check for invalid pop from empty queue
    // If this fires, there's a logic flaw in the system
    assert property (@(posedge clk) disable iff (rst)
        !(wb_in.pop & q_empty)
    ) else $error("ST_Q: Invalid pop from cache - attempted to pop from empty queue at time %0t", $time);

    /*
    typedef struct {
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_entry_t;

    typedef struct {
        st_q_entry_t data;
        bool push;
        bool pop;
    } st_q_inputs_t;

    typedef struct {
        bool full;
        bool empty;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_outputs_t;


    */

endmodule
