module ST_Q (
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
    /*

    //assumming no push to full
    //assuming no pop to emtpy
    //
    //push to head pop from tail
    */

    input wire clk,
    input wire rst,

    input st_q_inputs_t wb_in,

    output st_q_outputs_t outputs
);

    import common_pkg::*;
    import WriteBack_pkg::*;

    logic [$clog2(ST_Q_DEPTH)] validEntries;
    logic [$clog2(ST_Q_DEPTH)] head;
    logic [$clog2(ST_Q_DEPTH)] tail;
    bool full, empty;

    //create the q
    st_q_entry_t q[ST_Q_DEPTH];
    assign q_full = validEntries == ST_Q_DEPTH;
    assign q_empty = validEntries == 0;

    assign outputs = '{
            full: q_full,
            empty: q_empty,
            address: q[tail].address,
            bit_vec: q[tail].bit_vec,
            data: q[tail].data
        };

    //work to do, if push,
    always_ff @(posedge clk) begin
        if (rst) begin
            validEntries <= 0;
            head <= 0;
            tail <= 0;
        end else begin
            if (pop) tail <= tail + 1;

            if (push) begin
                head <= head + 1;
                q[head+1] <= '{address: wb_in.address, bit_vec : wb_in.bit_vec, data : wb_in.data};
            end

            case ({
                push, pop
            })
                2'b00, 2'b11: validEntries <= validEntries;
                2'b01: validEntries <= validEntries - 1;
                2'b10: validEntries <= validEntries + 1;
            endcase

        end
    end

endmodule
