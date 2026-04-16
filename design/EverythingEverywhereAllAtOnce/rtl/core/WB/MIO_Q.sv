module MIO_Q(
    input clk,
    input rst,
    input mio_inputs_t mio_input,
    output bool push_fail,
    output st_q_2_dcache_t outs
);


    mio_entry_t mio_q;
    bool full;
    bool empty;

    bool next_full;
    bool next_empty;

    bool valid_push;
    bool valid_pop;


    assign valid_push = mio_input.push &  (~full | mio_input.pop);
    assign valid_pop =  mio_input.pop & (~empty);
    assign push_fail = mio_input.push & (full & ~mio_input.pop);

//else if because if we have a valid push then the queue will be full no matter what
    always_comb begin
        // Default: maintain current state
        next_full = full;
        next_empty = empty;
        
        if (valid_push) begin
            next_full = 1;
            next_empty = 0;
        end
        else if (valid_pop) begin
            next_empty = 1;
            next_full = 0;
        end

    end
//work to do, if push
    always_ff @(posedge clk) begin
        if (!rst) begin
            full <= 0;
            empty <= 1;
            mio_q <= '{default: '0};
        end else begin
            if (valid_push) begin
                mio_q <= mio_input.data;  // Replace old with new, stay full
            end else if (valid_pop) begin
                mio_q.valid <= 1'b0;
            end
            full <= next_full;
            empty <= next_empty;
        end
    end

    assign outs = '{
        full: full,
        empty: empty,
        address: mio_q.address,
        bit_vec: '0,
        data: mio_q.data
    };



endmodule