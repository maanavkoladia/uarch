module STQ_Q_MIO_logic(
    input bool wb_valid,
    input p_address_t st_paddr_0_mio,
    input byte_t res_buf[CACHE_LINES_SIZE_B * 2],
    input bool ST_OP,
    input bool MIO, 
    input bool write_success_mio,

    output st_q_inputs_t stq_info_mio
);

    
    //we mio queue will generate 
    assign stq_info_mio = '{
        data: '{
            valid: wb_valid & MIO & ST_OP,
            address: st_paddr_0_mio,
            bit_vec: 16'0, //not needed for mio queue
            data: res_buf[0 +: CACHE_LINES_SIZE_B]
        };
        push: wb_valid & MIO & ST_OP, //same as data valid
        pop: write_success_mio
    };



endmodule