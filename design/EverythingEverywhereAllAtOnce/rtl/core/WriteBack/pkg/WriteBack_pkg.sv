package WriteBack_pkg;

    import common_pkg::*;
    import core_common_pkg::st_q_outputs_t;

    localparam int ST_Q_DEPTH = 4;  //needs to be a power of two

    typedef struct {
        bool valid;
        p_address_t address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
    } st_q_entry_t;

    typedef struct {
        st_q_entry_t data;
        bool push;
        bool pop;
    } st_q_inputs_t;

endpackage
