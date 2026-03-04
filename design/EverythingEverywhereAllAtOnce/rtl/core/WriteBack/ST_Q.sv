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
    input wire clk,
    input wire rst,

    input st_q_inputs_t wb_in,

    output st_q_outputs_t outputs

);



endmodule
