package WriteBack_pkg;

    import common_pkg::*;
    import reg_ids_pkg::*;


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


    typedef struct {
        bool full;
        bool empty;
        bool valid[ST_Q_DEPTH];
        p_address_t address[ST_Q_DEPTH];
        p_address_t head_address;
        uint16_t bit_vec;
        byte_t data[CACHE_LINES_SIZE_B];
        bool push_fail;
        bool st_override;
    } st_q_outputs_t;

    typedef struct{
        bool full;
        bool empty;
        bool valid;
        p_address_t address;
        byte_t data[CACHE_LINES_SIZE_B];
        bool push_fail;
    }st_q_mio_outputs_t;

    typedef struct {
        reg_ids_e dr0_id; //dr in wb_latches
        bool dr0_we;
        uint64_t dr0_data;

        reg_ids_e dr1_id;  //corresponds to writing to source reg
        bool dr1_we;
        uint64_t dr1_data;
    }reg_wb_logic_outputs_t;

endpackage
