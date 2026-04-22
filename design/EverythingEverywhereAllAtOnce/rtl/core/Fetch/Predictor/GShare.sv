import common_pkg::*;
import Fetch_pkg::*;
import Predictor_pkg::*;

    module GShare(
        input clk,
        input rst,
        input predictor_input_t inputs,
        output predictor_output_t outputs

    );

    

    localparam BHR_SIZE = 8;
    localparam PHT_SIZE = 1<<BHR_SIZE;
    localparam SAT_COUNT_SIZE = 2;

    logic [BHR_SIZE-1: 0] bhr_spec, bhr_real;

    logic inc_inputs[PHT_SIZE];
    logic dec_inputs[PHT_SIZE];
    logic taken[PHT_SIZE];

    logic [BHR_SIZE-1: 0] next_bhr_real;
    logic [BHR_SIZE-1: 0] next_bhr_spec;

    logic [BHR_SIZE-1: 0] pht_index_spec;
    logic [BHR_SIZE-1: 0] pht_index_update;

    logic [1:0] pht_contents_debug[PHT_SIZE];



    genvar i;
    generate
    for(i = 0; i < PHT_SIZE; i++) begin: g_two_bit
        two_bit_sat_count sat_count(
            .clk(clk),
            .rst(rst),
            .inc(inc_inputs[i]),
            .dec(dec_inputs[i]),
            .taken(taken[i])
        );
        assign pht_contents_debug[i] = g_two_bit[i].sat_count.sat_count;
    end
    endgenerate

    
    assign pht_index_spec = bhr_spec ^ inputs.spc[$clog2(CACHE_LINES_SIZE_B) +: BHR_SIZE];
                                                        //need to take bits 4 to 11 (8 bits)
    assign pht_index_update = bhr_real ^ inputs.exe_br_eip[$clog2(CACHE_LINES_SIZE_B) +: BHR_SIZE];
                                                          
    // Prediction output
    assign outputs.taken = taken[pht_index_spec];

    always_comb begin
        inc_inputs = '{default: '0};
        dec_inputs = '{default: '0};  
        next_bhr_real = bhr_real;   
        if(inputs.exe_br_valid)begin
            if(inputs.exe_br_taken)begin
                inc_inputs[pht_index_update] = 1'b1;
                next_bhr_real = {bhr_real[BHR_SIZE-2:0], 1'b1};
            end
            else begin
                dec_inputs[pht_index_update] = 1'b1;
                next_bhr_real = {bhr_real[BHR_SIZE-2:0], 1'b0};
            end 
        end
    end

    
    always_comb begin
        next_bhr_spec = bhr_spec;
        if(inputs.misprediction)
            next_bhr_spec = next_bhr_real;
        else if(inputs.btb_hit)
            next_bhr_spec = {bhr_spec[BHR_SIZE-2:0], taken[pht_index_spec]};
    end

    always_ff@(posedge clk)begin
        if(!rst)begin
            bhr_real <= '0;
            bhr_spec <= '0;
        end
        else begin
            bhr_real <= next_bhr_real;
            bhr_spec <= next_bhr_spec;
        end
    end



endmodule