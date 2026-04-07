module data_size_vec_logic(
    input logic [1:0] data_size,
    input bool upper8,
    input bool ST_OP,
    input LD_OP,

    output rh_into_mem_o,
    output mem_into_rh_o,
    output logic[3:0] data_size_vec_o
);

    
    

    //how do we need to know if we need to shift up mem or shift down rh
    //if we are doing a store op that means mem is our dr which means we need to shift rh down
    //if we are doing a load op but not a store op that means mem is a source and not the DR
    //this means we are adding into AH which means we need to shift mem up to match ah
    assign rh_into_mem_o = ST_OP & upper8;
    assign mem_into_rh_o = LD_OP & ~ST_OP & upper8;   

    always_comb begin
        data_size_vec_logic[0] = 0;
        data_size_vec_logic[1] = 0;

        //if we are doing a regular AL operation OR any store op then we are changing the lower 8 bits
        if((data_size == 0 && ~upper8) || ST_OP)
            data_size_vec_o[0] = 1;
        //otherwise we are doing an add to ah 
        else if((data_size == 0 & upper8))
            data_size_vec_o[1] = 1;

        if(data_size[1] | data_size[0])begin
            data_size_vec_o[0] = 1;
            data_size_vec_o[1] = 1;
        end

        data_size_vec_o[2] = data_size[1];
        data_size_vec_o[3] = data_size[1] & data_size[0];
    end



endmodule