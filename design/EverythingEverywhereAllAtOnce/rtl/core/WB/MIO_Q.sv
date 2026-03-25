module MIO_Q(
    input clk,
    input rst,
    input mio_input_t mio_input,

    output mio_outputs_t outs


);
    
    //currently 1
    mio_entry_t mio_q;
    bool full;
    bool empty;

    bool valid_push;
    bool valid_pop;

    assign valid_push = mio_input.push &  (~full | mio_input.pop);
    assign valid_pop =  mio_input.pop & (~empty);

//work to do, if push
    always_ff @(posedge clk) begin
        if (rst) begin
            full <= 0;
            empty <= 1;
            mio_q <= '{default: '0};
        end else begin
            if(valid_push)begin
                mio_q <= mio_input.data; 
                full <= 1;
                empty <= 0;
            end

            if(valid_pop)begin
                mio_q.valid <= 1'b0;
                empty <= 1;
                full <= 0;
            end
        end
    end

    assign outs = '{
        full: full,
        empty: empty,
        address: mio_q.address,
        bit_vec: '0,
        data: mio_q.data
    };

    // Assertion: Check for invalid pop from empty queue
    // If this fires, there's a logic flaw in the system
    assert property (@(posedge clk) disable iff (rst)
        !(mio_q).pop & empty)
    else $error("ST_Q: Invalid pop from cache - attempted to pop from empty queue at time %0t", $time);



endmodule