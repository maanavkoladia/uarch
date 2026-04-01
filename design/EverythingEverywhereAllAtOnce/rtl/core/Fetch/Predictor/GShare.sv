import common_pkg::*;
import Fetch_pkg::*;
import Predictor_pkg::*;

    module GShare(
        input predictor_input_t,
        output predictor_output_t

    );

    localparam BHR_SIZE = 8;
    localparam SAT_COUNT_SIZE = 2;

    logic [BHR-1: 0] BHR_SPEC, BHR_REAL;
    logic[SAT_COUNT_SIZE -1: 0] PHT[1<<BHR_SIZE]



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