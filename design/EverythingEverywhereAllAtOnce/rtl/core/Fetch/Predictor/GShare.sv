import common_pkg::*;
import Fetch_pkg::*;
import Predictor_pkg::*;

    module GShare(
        input rst,
        input predictor_input_t,
        output predictor_output_t

    );

    

    localparam BHR_SIZE = 8;
    localparam PHT_SIZE = 1<<BHR_SIZE;
    localparam SAT_COUNT_SIZE = 2;

    logic [BHR-1: 0] br_spec, bhr_real;
    logic[SAT_COUNT_SIZE -1: 0] pht[PHT_SIZE];

    always_ff begin
        if(!rst)begin
            pht <= '{default: '0};
        end
        else begin
            if(exe_br_valid)begin
                if(exe_br_taken) pht[bhr_real] <= pht[bhr_real] << 1;W 
            end


        end
    end

    address_t btfn_target;
    address_t spc;

        //execute info
    bool exe_br_valid;
    address_t exe_br_target;
        //address_t exe_br_eip;
    bool exe_br_taken;
        //proably not needed
    bool exe_br_hit;
   } predictor_input_t;

endmodule