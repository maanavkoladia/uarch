//value_i comes from buffer ALWAYS
//SP will ALWAYS come from SR
//DR output latches <- value
//SR <- SP

module pop_op(
    input  logic [63:0] value_i, // value at stack (to restore)
    input  logic [63:0] sp_i,    // value of ESP (stack pointer)
    input  logic[63:0] curr_dr,
    // never writing to mem
    input [3:0] data_size,
    output logic [63:0] dr_o,  // data to restore from stack
    output logic [63:0] sr_o,     // stack pointer update
    // no flag update
    output logic [63:0] res_buf
);


    logic [2:0] num_bytes;
    always_comb begin
            // Map data_size to byte count
        num_bytes = 2;
        if(data_size    [2])
            num_bytes = 4;
    end
    uint32_t merged_res;
    assign merged_res[7:0] = data_size[0] ? value_i[7:0] : curr_dr[7:0];
    assign merged_res[15:8] = data_size[1] ? value_i[15:8] : curr_dr[15:8];
    assign merged_res[31:16] = data_size[2] ? value_i[31:16] : curr_dr[31:16];


    assign dr_o = {32'd0, merged_res[31:0]};
    assign sr_o   = {32'd0, sp_i[31:0] + num_bytes};
    assign res_buf = {32'd0, merged_res[31:0]};

endmodule