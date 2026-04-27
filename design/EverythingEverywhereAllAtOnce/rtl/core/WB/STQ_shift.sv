module STQ_shift(
    input clk,
    input rst,
    input st_q_inputs_t wb_in,
    output st_q_outputs_t outputs
);

    st_q_entry_t q[ST_Q_DEPTH];
    logic [ST_Q_DEPTH: 0] next_push; //one hot encoding I think it will be easier for structural



    bool full, empty;
    assign full = (next_push == 5'b10000);
    assign empty = (next_push == 5'b00001);

    bool valid_push, valid_pop;
    assign valid_push = wb_in.push &  (~full | wb_in.pop);
    assign valid_pop =  wb_in.pop & (~empty);

    //q[0] is where things get popped off
    always_ff @(posedge clk)begin
        if(!rst) begin
            next_push <= 1;
            q <= '{default: '0};
        end
        else begin
            if(valid_push)begin
                if(valid_pop)begin
                    for(int i = 0; i < ST_Q_DEPTH; i++)begin
                        q[i] <= next_push[i] ? wb_in.data : q[i+1];
                    end
                end
                else begin
                    for(int i = 0; i < ST_Q_DEPTH; i++)begin
                        q[i] <= next_push[i] ? wb_in.data : q[i];
                    end
                end
            end
            else if(valid_pop)begin
                for(int i =0; i < ST_Q_DEPTH; i++)begin
                    q[i] <= q[i+1];
                end
            end
        end
    end

    always_comb begin
        outputs.full = full;
        outputs.empty = empty;
        outputs.head_address = q[0].address;
        outputs.bit_vec = q[0].bit_vec;
        outputs.head_data = q[0].data;
        outputs.push_fail = wb_in.push & (full & ~wb_in.pop);

        //this is for forwarding
        for(int i = 0;  i < ST_Q_DEPTH; i++)begin
            outputs.valid[i] = q[i].valid;
            outputs.address[i] = q[i].address;
            outputs.data[i] = q[i].data;
        end

    end



endmodule
