module data_size_vec_logic(
    input logic [1:0] data_size,
    input bool dr_upper8,
    input bool sr_upper8,
    input bool ST_OP,
    input bool LD_OP,
    input bool wb_sr,
    input bool wb_eax,

    output shift_sr_up,
    output shift_sr_down,
    output logic[3:0] data_size_vec_o,
    output logic[3:0] sr_data_size_vec_o
);


    assign shift_sr_up = dr_upper8 & ~sr_upper8 & ~wb_sr & ~wb_eax;
    assign shift_sr_down = ~dr_upper8 & sr_upper8 & ~wb_sr & ~wb_eax;

    always_comb begin
        data_size_vec_o[0] = 0;
        data_size_vec_o[1] = 0;

        //if we are doing a regular AL operation OR any store op then we are changing the lower 8 bits
        if(data_size == 0 && ~dr_upper8)
            data_size_vec_o[0] = 1;
        //otherwise we are doing an add to ah
        else if((data_size == 0 & dr_upper8)) //no store op
            data_size_vec_o[1] = 1;

        if(data_size[1] | data_size[0])begin
            data_size_vec_o[0] = 1;
            data_size_vec_o[1] = 1;
        end

        data_size_vec_o[2] = data_size[1];
        data_size_vec_o[3] = data_size[1] & data_size[0];
    end

    always_comb begin
        sr_data_size_vec_o[0] = 0;
        sr_data_size_vec_o[1] = 0;

        if(data_size == 0 && ~sr_upper8)
            sr_data_size_vec_o[0] = 1;

        else if((data_size == 0 & sr_upper8)) //no store op
            sr_data_size_vec_o[1] = 1;

        if(data_size[1] | data_size[0])begin
            sr_data_size_vec_o[0] = 1;
            sr_data_size_vec_o[1] = 1;
        end

        sr_data_size_vec_o[2] = data_size[1];
        sr_data_size_vec_o[3] = data_size[1] & data_size[0];
    end

endmodule